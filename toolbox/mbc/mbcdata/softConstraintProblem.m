classdef softConstraintProblem




    properties(SetAccess=private)

Aineq

Bineq

LB

UB

X0

NumLinearConstraints

        NumVars=0;

        NumSlacks=0;

SlackJacobian



SlackLinearJacobian


SlackObjWeight

SoftConstraints


OptimStore

FeasRelativeFactor

ConstraintScale


        IsInfeasible=false;

        DoDisplay=false;

NonlinearConstraints
    end

    properties(Dependent,SetAccess=private)
NumTotalVars
    end


    methods
        function obj=softConstraintProblem(optimstore,x0,FeasibilityWeighting,DoDisplay)



            if nargin<3
                FeasibilityWeighting=1;
            end
            if nargin<4
                DoDisplay=false;
            end

            obj.DoDisplay=DoDisplay;
            obj.OptimStore=optimstore;
            cscale=scaleConstraints(obj.OptimStore,x0);
            obj.ConstraintScale=cscale;

            [lb,ub]=getBounds(obj.OptimStore);
            [A,B]=getLinearConstraints(obj.OptimStore,x0);
            obj=initialize(obj,x0,A,B,lb,ub);
            obj.NumVars=numel(x0);
            obj.FeasRelativeFactor=calcRelFeasError(obj);


            obj=softConstraintJacobian(obj);

            s0=evalulateSlacks(obj,x0);
            obj.NumSlacks=numel(s0);
            s0=max(s0,1e-4);
            obj.X0=[x0,s0];


            if~isempty(A)
                Aslack=[A,-obj.SlackLinearJacobian];
            else
                Aslack=[];
            end




            obj.NumVars=numel(x0);
            nSlacks=numel(s0);
            lb(obj.NumVars+1:obj.NumVars+nSlacks)=0;
            ub(obj.NumVars+1:obj.NumVars+nSlacks)=Inf;

            obj=initialize(obj,obj.X0,Aslack,B,lb,ub);

            obj.FeasRelativeFactor=calcRelFeasError(obj);


            ItemNames=getConstraintNames(optimstore.OptimRunner,'inequality');
            if~isScalarFreeVariables(optimstore)
                conTabGrads=getConstraintNames(optimstore.OptimRunner,'tablegradient');
                ItemNames=setdiff(ItemNames,conTabGrads,'stable');
            end
            conBoundary=getConstraintNames(optimstore.OptimRunner,'linearboundary');
            obj.NonlinearConstraints=setdiff(ItemNames,conBoundary,'stable');



            obj.SlackObjWeight=zeros(1,sum(getNumObjectives(obj.OptimStore)));
            if~isempty(s0)
                obj.SlackObjWeight=zeros(1,length(getObjectives(obj.OptimStore)));
                f0=evaluateAllObjectives(obj,[x0,zeros(size(s0))]);
                obj.SlackObjWeight=FeasibilityWeighting*max(abs(f0),1e-4)/max(sum(s0),1);
            end
            obj=simplifyConstraints(obj);
        end

        function n=get.NumTotalVars(obj)

            n=obj.NumVars+obj.NumSlacks;
        end

        function problem=problemStruct(obj,solver,options)


            if nargin<3
                options=optimoptions(solver);
            end
            problem=createProblemStruct(solver);
            if isfield(problem,'objective')
                problem.objective=@(x)evaluateObjective(obj,x);
            else
                problem.fitnessfcn=@(x)evaluateObjective(obj,x);
            end
            problem.nonlcon=@(x)evaluateConstraints(obj,x);

            problem.Aineq=obj.Aineq;
            if~(strcmp(solver,'fmincon')&&strcmp(options.Algorithm,'interior-point'))

                problem.Aineq=full(problem.Aineq);
            end
            problem.bineq=obj.Bineq;
            problem.x0=obj.X0;
            problem.lb=obj.LB;
            problem.ub=obj.UB;
            if nargin>2
                problem.options=options;
            else
                problem.options=optimoptions(solver);
            end

        end

        function obj=initialize(obj,x0,A,B,lb,ub)


            obj.Aineq=A;
            obj.Bineq=B;
            obj.LB=lb;
            obj.UB=ub;
            obj.X0=x0;

        end
        function s=getSlacks(obj,x)

            s=full(x(:,end-obj.NumSlacks+1:end));

        end

        function[x,bestfun,exitFlag,outstruct,sfinal]=getBaseSolution(obj,bs,bestfun,exitFlag,outstruct,options,IndexCont)


            absTolCon=obj.FeasRelativeFactor*options.TolCon;
            if isfield(outstruct,'bestfeasible')&&~isempty(outstruct.bestfeasible)&&...
                outstruct.bestfeasible.constrviolation<=options.TolCon&&...
                (outstruct.constrviolation>options.TolCon||...
                outstruct.bestfeasible.fval<bestfun)




                if numel(bs)==numel(outstruct.bestfeasible.x)
                    bs=outstruct.bestfeasible.x;
                else

                    bs(IndexCont)=outstruct.bestfeasible.x;
                end
                bestfun=outstruct.bestfeasible.fval;

                if outstruct.constrviolation<options.TolCon
                    exitFlag=13;
                else
                    exitFlag=14;
                end

                outstruct.constrviolation=outstruct.bestfeasible.constrviolation;
                outstruct.firstorderopt=outstruct.bestfeasible.firstorderopt;



                msg=createExitMsg({'optimlib:commonMsgs:FeasiblePointOutputStruct'},{},false,false);
                outstruct.message=msg;
            end

            x=bs(1:obj.NumVars);
            sfinal=bs(obj.NumVars+1:end);

            if obj.NumSlacks>0
                bestfun=evaluateAllObjectives(obj,[x,zeros(size(sfinal))]);
            end


            sfinal=evalulateSlacks(obj,x);
            xs=[x,sfinal];

            [convals,ceq]=evaluateAllConstraints(obj,xs);

            unscaledProblem=obj;
            unscaledProblem.ConstraintScale=1;
            unscaledConstraints=evaluateAllConstraints(obj,[x,zeros(size(sfinal))]);

            outstruct.constrviolation=max(max(unscaledConstraints),0);
            hasSoftSolution=outstruct.constrviolation>absTolCon&sfinal>absTolCon;


            outstruct.feasRelativeFactor=obj.FeasRelativeFactor;
            if any(hasSoftSolution)
                unscaledSlacks=initialSlacks(unscaledProblem,x);
                outstruct.softConstraints=strjoin(obj.SoftConstraints(hasSoftSolution),',');
                outstruct.maxSoftConstraint=max(full(unscaledSlacks));
            else

                outstruct.softConstraints='<none>';
                outstruct.maxSoftConstraint=0;
            end

            if all(convals<=absTolCon)&&all(abs(ceq)<=absTolCon)
                if obj.NumSlacks>0&&any(hasSoftSolution)


                    exitFlag=12;
                    outstruct.message='Solution has active soft constraints';
                elseif exitFlag<=0


                    exitFlag=11;
                    outstruct.message='Optimization stopped at a feasible solution';
                end
            else

            end

        end

        function s=evalulateSlacks(obj,x)



            if~isempty(obj.Aineq)&&~isempty(obj.SlackLinearJacobian)
                if numel(x)<size(obj.Aineq,2)

                    A=obj.Aineq(:,1:end-obj.NumSlacks);
                else
                    A=obj.Aineq;
                end
                sLin=max(max((A*x(:)-obj.Bineq).*obj.SlackLinearJacobian,[],1),0);
                sLin=sLin(1:obj.NumLinearConstraints);
            else
                sLin=[];
            end
            c0=evaluateIneqCon(obj.OptimStore,x);
            if~isempty(c0)&&~isempty(obj.SlackJacobian)
                sNonLin=max(max(c0(:).*obj.SlackJacobian,[],1),0);
                sNonLin=sNonLin(obj.NumLinearConstraints+1:end);
            else
                sNonLin=[];
            end

            s=full([sLin,sNonLin]);

        end

        function f=evaluateAllObjectives(obj,x)
            objNames=getObjectives(obj.OptimStore);
            f=zeros(size(objNames));
            for i=1:length(objNames)
                f(i)=evaluateObjective(obj,x,i);
            end

        end
        function[convals,ceq]=evaluateAllConstraints(obj,x)

            [c0,ceq]=evaluateConstraints(obj,x);
            if~isempty(obj.Aineq)
                convals=[obj.Aineq*x(:)-obj.Bineq;c0(:)]';
            else
                convals=c0(:)';
            end

        end

        function s=initialSlacks(obj,x)

            s=zeros(size(x,1),obj.NumSlacks);
            if obj.NumSlacks>0
                for i=1:size(x,1)
                    s(i,:)=evalulateSlacks(obj,x(i,:));
                end
            end
        end

        function[y,yg]=evaluateObjective(obj,x,objIndex)



            if nargin<3
                objIndex=1;
            end

            nSlacks=size(obj.SlackJacobian,2);
            s=x(:,obj.NumVars+1:end);
            x=x(:,1:obj.NumVars);
            if isfinite(obj.SlackObjWeight)

                objNames=getObjectives(obj.OptimStore);
                if nargout>1
                    [y,yg]=evaluateObjective(obj.OptimStore,x,objNames(objIndex));

                    yg=[yg;obj.SlackObjWeight(objIndex)*ones(nSlacks,1)];
                else
                    y=evaluateObjective(obj.OptimStore,x,objNames(objIndex));
                    yg=[];
                end
                ObjectiveFuncTypes=getObjectiveType(obj.OptimStore);
                switch ObjectiveFuncTypes{objIndex}
                case 'max'

                    y=-y;
                    if~isempty(yg)
                        yg=-yg;

                        yg(end-nSlacks+1:end)=obj.SlackObjWeight(objIndex);
                    end
                case 'min'
                otherwise
                    error(message('mbc:mbcOSfmincon:InvalidState'));
                end
                if~isempty(s)
                    y=y+obj.SlackObjWeight(objIndex)*sum(s,2);
                end
            else

                y=sum(s);
                yg=[zeros(length(x),1);ones(nSlacks,1)];
            end
        end


        function[c,ceq,cg,cgeq]=evaluateConstraints(obj,x)



            s=x(:,obj.NumVars+1:end);
            x=x(:,1:obj.NumVars);
            nSlacks=size(s,2);
            c=[];
            cg=[];
            if nargout>2

                if~isempty(obj.NonlinearConstraints)
                    [c,cg]=evaluateConstraint(obj.OptimStore.OptimRunner,x,obj.NonlinearConstraints);
                    cg=cg./obj.ConstraintScale;
                end

                [ceq,cgeq]=evaluateEqCon(obj.OptimStore,x);
                if obj.NumSlacks>0
                    cg=[cg;-obj.SlackJacobian'];
                    cgeq=[cgeq;zeros(nSlacks,size(cgeq,1))];
                end
            else
                c=evaluateIneqCon(obj.OptimStore,x);
                ceq=evaluateEqCon(obj.OptimStore,x);
            end
            if~isempty(c)
                c=c./obj.ConstraintScale;
            end
            if nSlacks>0
                tol=0;


                c=c-(obj.SlackJacobian*s')'+tol;
            end
        end


        function[x,optimValues]=outputFcn(obj,x,optimValues,state,doDisplay)



            if nargin<5
                doDisplay=obj.DoDisplay;
            end

            sCurrent=full(x(end-obj.NumSlacks+1:end));
            x=full(x(:,1:end-obj.NumSlacks));


            if doDisplay&&any(strcmp(state,{'iter','testing'}))&&rem(optimValues.iteration,10)==0
                displaySlacks(obj,sCurrent);
            end

            if obj.NumSlacks>0

                optimValues.fval=optimValues.fval-sum(sCurrent.*obj.SlackObjWeight);
            end
            optimValues.feasRelativeFactor=obj.FeasRelativeFactor;
        end


        function displaySlacks(obj,s)


            if~isempty(s)
                s=full(s);

                [OK,loc]=ismember(obj.SoftConstraints,obj.NonlinearConstraints);
                if any(OK)
                    s(OK)=s(OK).*obj.ConstraintScale(loc(OK));
                end
                tbl=array2table(s,'VariableNames',obj.SoftConstraints);
                fprintf('\nSoft constraint violations (max %g): \n',max(s));
                disp(tbl);
                fprintf('\n');
            end
        end

        function obj=softConstraintJacobian(obj)




            or=obj.OptimStore.OptimRunner;
            [conNames,~,isSoft]=getConstraintNames(or,'includebounds');
            [~,idxIneq]=getConstraintNames(or,'inequality');
            [~,idxBdry]=getConstraintNames(or,'linearboundary');
            conNamesIneq=conNames(idxIneq&~idxBdry);
            isSoftIneq=isSoft(idxIneq&~idxBdry);
            [conNamesTG,idxTG,isSoftTG]=getConstraintNames(or,'tablegradient');
            [~,idxBnds]=getConstraintNames(or,'bounds');
            [~,idxLinear]=getConstraintNames(or,'linear');

            ncon=numConstraints(or);
            idxLinearCon=idxLinear(~idxBnds);
            ncon(idxLinearCon|idxBdry(~idxBnds))=[];

            idxIneq(idxBdry|idxBnds|idxLinear)=[];
            idxTG(idxBdry|idxBnds|idxLinear)=[];
            nlin=ncon(idxTG);
            nl=numel(nlin);


            nlTotal=sum(nlin);
            A=obj.Aineq;
            if nlTotal<size(A,1)

                nlin=[size(A,1)-nlTotal,nlin];
                nl=numel(nlin);
                nlTotal=sum(nlin);
                isSoftTG=[false,isSoftTG];
                conNamesTG=[{''},conNamesTG];
            end

            if nl==0
                Jlin=sparse(nlTotal,0);
            else
                Jcols=arrayfun(@(i,n)repmat(i,1,n),1:numel(nlin),nlin,'UniformOutput',false);
                Jcols=[Jcols{:}];








                Jlin=sparse(1:sum(nlin),Jcols,ones(1,nlTotal),nlTotal,nl);

                Jlin=Jlin(:,isSoftTG);
            end

            nl=size(Jlin,2);


            idxIneq=idxIneq&~idxTG;
            isSoftIneq(idxTG)=[];
            conNamesIneq(idxTG)=[];
            ncon=ncon(idxIneq);
            if~isempty(ncon)
                Jcols=arrayfun(@(i,n)repmat(i,1,n),1:numel(ncon),ncon,'UniformOutput',false);
                Jcols=[Jcols{:}];


                nc=sum(ncon);








                Jnonlin=sparse(1:sum(ncon),Jcols,ones(1,nc),nc,numel(ncon));
                Jnonlin=Jnonlin(:,isSoftIneq);
                ncon=ncon(isSoftIneq);
                Jnonlin=[sparse(nc,size(Jlin,2)),Jnonlin];
            else
                Jnonlin=sparse(nlTotal,0);
            end

            Jlin=[Jlin,sparse(nlTotal,numel(ncon))];

            softConstraints=[conNamesTG(isSoftTG),conNamesIneq(isSoftIneq)];

            obj.SlackLinearJacobian=Jlin;
            obj.SlackJacobian=Jnonlin;
            obj.NumLinearConstraints=nl;
            obj.SoftConstraints=softConstraints;
        end

        function feasRelativeFactor=calcRelFeasError(obj)




            [nlcon,nleq]=evaluateConstraints(obj,obj.X0);


            cInEq_all=[nlcon,obj.LB-obj.X0,obj.X0-obj.UB];
            if~isempty(obj.Aineq)

                cInEq_all=[cInEq_all,(obj.Aineq*obj.X0(:)-obj.Bineq)'];
            end
            nlpPrimalFeasError=norm(max(cInEq_all,0),Inf);
            if~isempty(nleq)

                nlpPrimalFeasError=max(nlpPrimalFeasError,norm(nleq,Inf));
            end

            feasRelativeFactor=max(1,nlpPrimalFeasError);
        end


        function obj=simplifyConstraints(obj)


            if~isempty(obj.Aineq)

                [A,b,lb,ub,exitFlag,msg]=callPresolve(obj);
                if obj.DoDisplay&&~isempty(msg)
                    fprintf('%s\n',msg);
                end
                lb=lb(:)';
                ub=ub(:)';

                obj.IsInfeasible=~isempty(exitFlag)&&exitFlag<0;
                isModified=~isequal(A,obj.Aineq)||~isequal(lb,obj.LB)||~isequal(ub,obj.UB);
                if obj.DoDisplay&&obj.IsInfeasible
                    fprintf('Infeasible constraints detected.\n');
                end
                if isModified
                    if obj.DoDisplay

                        fprintf('Constraints modified:\n %d linear inequalities (%d)\n',size(A,1),size(obj.Aineq,1));

                        numLBChanged=nnz(lb~=obj.LB);
                        numUBChanged=nnz(ub~=obj.UB);
                        numFixed=nnz(lb==ub);
                        fprintf(' %d lower bounds changed\n %d upper bounds changed\n %d fixed variables\n',numLBChanged,numUBChanged,numFixed);
                    end
                    if~obj.IsInfeasible



                        obj.Aineq=A;
                        obj.Bineq=b;
                        obj.LB=lb;
                        obj.UB=ub;

                        obj=bringInside(obj);
                        if obj.NumSlacks>0
                            obj.Aineq=A;
                            obj.SlackLinearJacobian=A(:,end-obj.NumSlacks+1:end);
                        end
                    end
                end
            end

        end

        function obj=bringInside(obj,x0)


            if nargin<2
                x0=obj.X0;
            end
            r=obj.UB-obj.LB;

            aboveUB=x0>=obj.UB;
            x0(aboveUB)=obj.UB(aboveUB)-r(aboveUB)/100;
            belowUB=x0<=obj.LB;
            x0(belowUB)=obj.LB(belowUB)+r(belowUB)/100;
            obj.X0=x0;

        end

        function obj=makeConstraintsFeasible(obj)













            if~isempty(obj.Aineq)&&any(obj.Aineq*obj.X0(:)-obj.Bineq>1e-6)



                x0=obj.X0;
                A=obj.Aineq;
                B=obj.Bineq;
                lb=obj.LB;
                ub=obj.UB;



                qpopts=optimoptions('quadprog');
                qpopts.Display='none';




                tol=1e-4;
                scale=max(abs(lb),abs(ub))';

                [c0,cg0]=obj.evaluateConstraints(x0);

                if~isempty(cg0)

                    Aqp=[A;cg0'];
                    Bqp=[B-A*x0(:);-c0(:)];
                else
                    Aqp=A;
                    Bqp=B-A*x0(:);
                end

                n=numel(x0);
                [qpdeltaX0,~,qpExitFlag]=quadprog(spdiags(1./scale.^2,0,n,n),zeros(1,n),...
                Aqp,Bqp,[],[],lb-x0+tol,ub-x0-tol,...
                [],qpopts);
                if qpExitFlag<0

                    Aqp=A;
                    Bqp=B-A*x0(:);
                    [qpdeltaX0,~,qpExitFlag]=quadprog(spdiags(1./scale.^2,0,n,n),zeros(1,n),...
                    Aqp,Bqp,[],[],lb-x0+tol,ub-x0-tol,...
                    [],qpopts);
                end
                if qpExitFlag>0

                    qpX0=x0(:)+qpdeltaX0;


                    x0=qpX0(:)';
                    obj.X0=x0;
                    if obj.DoDisplay
                        fprintf('\nInitial parameters adjusted for convex hull boundary and table gradient constraints.\n\n');
                    end

                end
            end
        end

    end

    methods(Access=private)
        function[Aineq,bineq,lb,ub,exitFlag,msg]=callPresolve(obj)


            options=optimset(optimset('fmincon'));
            if~obj.DoDisplay
                options.Display='none';
            end
            computeLambda=false;
            makeExitMsg=true;

            requestedTransforms=2:6;


            H=[];
            f=ones(1,size(obj.Aineq,2))';
            [~,~,Aineq,bineq,~,~,lb,ub,transforms,restoreData,exitFlag,msg]=...
            presolve(H,f,obj.Aineq,obj.Bineq,[],[],obj.LB(:),obj.UB(:),options,computeLambda,requestedTransforms,makeExitMsg);
            if size(Aineq,2)<restoreData.nVarOrig




                A=spalloc(size(Aineq,1),restoreData.nVarOrig,nnz(Aineq));
                A(:,restoreData.varsInProblem)=Aineq;
                Aineq=A;


                fullLB=zeros(1,restoreData.nVarOrig);
                fullUB=fullLB;

                fixedVars=cat(1,transforms.varIdx);
                values=cat(1,transforms.primalVals);
                fullLB(fixedVars)=values;
                fullUB(fixedVars)=values;


                fullLB(restoreData.varsInProblem)=lb;
                fullUB(restoreData.varsInProblem)=ub;

                lb=fullLB;
                ub=fullUB;
            end
        end
    end

end




