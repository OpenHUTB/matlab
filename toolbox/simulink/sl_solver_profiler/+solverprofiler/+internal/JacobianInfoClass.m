classdef JacobianInfoClass<handle

    properties(SetAccess=private)
JacobianTimes
TJacobian
TMass
TFactor
CondNum
Stiffness
LimitingStateTable
    end

    methods

        function obj=JacobianInfoClass(pd)
            obj.JacobianTimes=[];
            obj.TJacobian=[];
            obj.TMass=[];
            obj.TFactor=[];
            obj.CondNum=[];
            obj.Stiffness=[];
            obj.LimitingStateTable=[];

            noJacobian=false;
            if isempty(pd)
                noJacobian=true;
            else
                if isfield(pd,'jacobianTimes')
                    obj.JacobianTimes=pd.jacobianTimes;
                end
                if isempty(obj.JacobianTimes)
                    noJacobian=true;
                end
            end


            if noJacobian
                return;
            end


            if~isfield(pd.odeInfo,'miterAssemInfo')||...
                ~isfield(pd.odeInfo,'jacobianInfo')||...
                isempty(pd.odeInfo.miterAssemInfo)||...
                isempty(pd.odeInfo.jacobianInfo)
                return;
            else
                obj.TJacobian=[pd.odeInfo.jacobianInfo.t];
                obj.TFactor=pd.odeInfo.miterAssemInfo.t;
                if~isempty(pd.odeInfo.massMatrixInfo)
                    obj.TMass=[pd.odeInfo.massMatrixInfo.t];
                end
            end


            tAnalysis=obj.TJacobian;

            for i=1:length(tAnalysis)
                t=tAnalysis(i);
                jInd=find(obj.TJacobian<=t,1,'last');
                if isempty(jInd),continue;end
                J=pd.odeInfo.jacobianInfo(jInd).matrix;
                if~isempty(obj.TMass)
                    mInd=find(obj.TMass<=t,1,'last');
                    if isempty(mInd),continue;end
                    M=pd.odeInfo.massMatrixInfo(mInd).matrix;
                else
                    M=eye(size(J));
                end
                gInd=find(obj.TFactor<=t,1,'last');
                if isempty(gInd),continue;end
                hGamma=pd.odeInfo.miterAssemInfo.hGamma(gInd);
                Miter=M-hGamma*J;

                [V,D]=eig(full(Miter));
                D=(real(diag(D)));

                obj.Stiffness(i)=abs(max(abs(D))/min(abs(D)));
                obj.CondNum(i)=cond(full(Miter));


                [~,ind]=max(D);
                [~,ind]=max(abs(V(:,ind)));
                obj.LimitingStateTable(i,1)=t;
                obj.LimitingStateTable(i,2)=ind;
            end


            if~isempty(obj.LimitingStateTable)
                inds=obj.LimitingStateTable(:,2)==0;
                obj.LimitingStateTable(inds,:)=[];
            end
        end


        function delete(obj)
            obj.JacobianTimes=[];
            obj.TJacobian=[];
            obj.TMass=[];
            obj.TFactor=[];
            obj.CondNum=[];
            obj.Stiffness=[];
            obj.LimitingStateTable=[];
        end

        function value=getJacobianTimes(obj)
            value=obj.JacobianTimes;
        end

        function[stateIdxList,counts]=getJacobianTable(obj,timeRange)
            if isempty(obj.LimitingStateTable)
                stateIdxList=[];
                counts=[];
                return;
            end

            t=obj.LimitingStateTable(:,1);
            inds=t>=timeRange(1)&t<=timeRange(2);
            if isempty(inds)
                stateIdxList=[];
                counts=[];
                return;
            end
            stats=obj.LimitingStateTable(inds,:);
            states=stats(:,2);

            if length(unique(states))==1
                counts=length(states);
                stateIdxList=states(1);
            else
                [counts,stateIdxList]=hist(states,unique(states));
                [counts,order]=sort(counts,'descend');
                stateIdxList=stateIdxList(order);
            end
        end
    end

end