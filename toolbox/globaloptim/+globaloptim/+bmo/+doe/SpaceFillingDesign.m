



classdef SpaceFillingDesign<handle




    properties(SetAccess=private,GetAccess=public)

        retcode=0
        errmsg=''
        SampleCount=0

nvar
pop_range
generatorAlgorithm

options
        DistanceFcn=[];
        MinSampleDistance=0;
problem




        TrialMgr=[];

qrng
    end

    methods

        function self=SpaceFillingDesign(problem,options,TrialMgr)











            self.options=options;
            self.problem=problem;
            if nargin>2
                self.TrialMgr=TrialMgr;
            end

            self.nvar=numel(problem.lb);
            if isfield(problem,'pop_range')

                self.pop_range=problem.pop_range';
            else


                self.pop_range=[problem.lb(:),problem.ub(:)];
            end
            if isfield(options,'DistanceFcn')
                self.DistanceFcn=options.DistanceFcn;
            end
            if isfield(options,'MinSampleDistance')
                self.MinSampleDistance=options.MinSampleDistance;
            end


            self.qrng=globaloptim.internal.QRandGenerator();
            if self.qrng.MAX_QRAND_DIMS>self.nvar
                self.generatorAlgorithm='deterministic';
            else
                self.generatorAlgorithm='random';
            end


            globaloptim.internal.generatePointSpread(self.generatorAlgorithm,...
            1,1,0,1,self.qrng,'reset');
        end


        function points=generateDesign(self,nPts,AllData)




            if nargin<3
                AllData=[];
            end
            if~isempty(AllData)
                oldData=AllData.getIndependentVariable;
            else
                oldData=[];
            end


            if~isempty(self.TrialMgr)
                trials=self.TrialMgr.getPendingTrials();
            else
                trials=[];
            end
            if~isempty(trials)
                oldData=[oldData;vertcat(trials.(self.TrialMgr.varName))];
            end

            optProb=self.problem;
            lr=self.pop_range(:,1);
            ur=self.pop_range(:,2);

            done=false;
            failCount=0;

            nTrial=nPts;
            nconst=optProb.mineq_cheap;
            generator=self.generatorAlgorithm;


            if self.SampleCount~=0
                self.qrng.Offset=self.SampleCount;
            elseif self.nvar~=1&&self.SampleCount==0

                self.qrng.Offset=0;
            end


            points=globaloptim.internal.generatePointSpread(generator,...
            nTrial,self.nvar,lr,ur,self.qrng)';
            self.SampleCount=self.SampleCount+nTrial;


            points=globaloptim.bmo.boundAndRound(points,optProb,...
            oldData,self.options);


            points=self.removeClosePoints(points,oldData);

            oldData=[points;oldData];


            while~done


                if nconst==0&&size(points,1)==nPts
                    done=true;
                    break;
                end

                if nconst>0


                    pick_best_feasible();
                else

                    create_linear_integer_feasible();
                end
            end

            if~isempty(points)
                infeas=self.check_infeasible(points);
                if any(infeas)
                    if self.options.Verbosity>=3
                        fprintf('Removing %d infeasible random point(s) out of %d.\n',...
                        nnz(infeas),length(infeas));
                    end
                    points(infeas,:)=[];
                end
            end


            function create_linear_integer_feasible()


                nTrial=nPts-size(points,1);
                if nTrial==0
                    done=true;
                    return;
                end
                morePoints=globaloptim.internal.generatePointSpread(generator,...
                nTrial,self.nvar,lr,ur,self.qrng)';
                self.SampleCount=self.SampleCount+nTrial;


                morePoints=globaloptim.bmo.boundAndRound(morePoints,optProb,...
                oldData,self.options);


                morePoints=self.removeClosePoints(morePoints,oldData);
                points=[points;morePoints];

                if size(points,1)>=nPts
                    done=true;
                    points=points(1:nPts,:);
                    return
                else

                    oldData=[morePoints;oldData];
                    failCount=failCount+1;
                    if failCount>10
                        done=true;
                    end
                end


                if mod(failCount+1,2)==0
                    nTrial=2*(nPts-size(points,1));
                end
            end


            function pick_best_feasible()
                constVal=optProb.constrfun(points);
                if size(constVal,1)~=size(points,1)
                    error(message('globaloptim:bmo:cheapConstraintSizeMismatch',...
                    size(constVal,1),size(constVal,2),size(points,1),nconst))
                end

                feas=sum(constVal<=self.options.ConstraintTolerance,2)==nconst;
                if sum(feas)>=nPts
                    done=true;
                    if nconst>0
                        points=points(feas,:);
                        nTrial=sum(feas);
                        bestPoints=[];
                        bestVal=-inf;
                        for i=1:1000
                            p=randperm(nTrial);
                            p=p(1:(nPts));
                            des=points([p,nTrial+1:end],:);
                            dists=self.DistanceFcn(des);
                            dists(1:nPts+1:nPts^2)=inf;
                            val=min(dists(:));
                            if val>bestVal
                                bestVal=val;
                                bestPoints=des;
                            end
                        end
                        points=bestPoints;
                    end
                    return;
                else
                    failCount=failCount+1;
                end


                if mod(failCount+1,10)==0
                    nTrial=2*nTrial;
                end
                points=globaloptim.internal.generatePointSpread(generator,...
                nTrial,self.nvar,lr,ur,self.qrng)';
                self.SampleCount=self.SampleCount+nTrial;


                points=globaloptim.bmo.boundAndRound(points,optProb,[],self.options);
            end

        end

        function infeas=check_infeasible(self,points)


            infeas=~globaloptim.internal.validate.isTrialFeasible(...
            points,...
            self.problem.Aineq,self.problem.bineq,...
            self.problem.Aeq,self.problem.beq,...
            self.problem.lb,self.problem.ub,...
            self.options.LinearConstraintTolerance);

            if self.problem.mInt>0

                int_index=self.problem.vartype;
                temp=abs(points(:,int_index)-round(points(:,int_index)))>...
                self.options.IntegerTolerance;
                integer_infeas=all(temp,2);
                infeas=infeas|integer_infeas;
            end
        end

        function points=removeClosePoints(self,points,oldCand)

            if~isempty(points)&&...
                ~isempty(self.DistanceFcn)&&self.MinSampleDistance>eps

                allDist=self.DistanceFcn(points)+1e6*eye(size(points,1));
                mindist=min(allDist,[],2);
                to_keep=mindist>=self.MinSampleDistance;
                if~any(to_keep)

                    to_keep(1)=true;
                end
                points=points(to_keep,:);


                if~isempty(oldCand)
                    allDist=self.DistanceFcn(points,oldCand);
                    mindist=min(allDist,[],2);
                    to_keep=mindist>=self.MinSampleDistance;
                    points=points(to_keep,:);
                end
            end
        end


        function xx=randomPoint(self)




            optProb=self.problem;
            lr=self.pop_range(:,1);
            ur=self.pop_range(:,2);
            nconst=optProb.mineq_cheap;

            TF=false;
            while~TF
                xx=lr'+(ur-lr)'.*rand(1,self.nvar);
                if nconst==0
                    TF=true;
                else
                    constVal=optProb.constrfun(xx);
                    if max(constVal)<=0
                        TF=true;
                    end
                end
            end
        end


        function restoreState(~,~)
        end

    end

end