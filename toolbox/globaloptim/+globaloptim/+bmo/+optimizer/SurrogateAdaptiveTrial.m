classdef SurrogateAdaptiveTrial<handle

    properties(SetAccess=private,GetAccess=public)
problem
options
TrialMgr
MinlpProbData
surrogates
        state=struct('surrogateReset',false,...
        'exitflag',0,...
        'msg','',...
        'surrogateOK',false);

        Data=struct('scaledConstMargins',[],...
        'constMargin',[],...
        'marginInit',0.005,...
        'marginMax',0.005,...
...
        'constFailTol',[],...
        'constFailCounter',0,...
        'constSuccTol',[],...
        'constSuccCounter',0,...
...
        'DistanceTolerance',[],...
...
        'samplingRadius',[],...
        'scaledSamplingRadius',[],...
        'sigmaMin',1e-5,...
        'sigmaMax',0.8,...
        'sigmaInit',0.2,...
...
        'rhoPhase1',[0.1,0.05,0.01,0.005,0.001,0.0005],...
        'rhoPhase2',[0.01,0.001,0.0005],...
        'nextRho',1,...
...
        'failTol',[],...
        'failCounter',0,...
        'succTol',3,...
        'succCounter',0,...
        'restartTol',[],...
        'restartCounter',0,...
        'notEnoughTrialsCounter',0,...
...
        'numCand',[],...
        'maxNumCand',5000,...
        'minNumCand',[],...
        'numAdaptiveSamples',1,...
...
        'nextWeight',1,...
        'nextSampler',1,...
        'Counter',0);

        samplers={'random','random','ortho','gps'};
        AlwaysHonorInteger=true;
        NeverRefineTrial=false;

        haveInteger=false;


        refineTrialNow=false;
        shallowSearchNodeLimit=1;
        deepSearchNodeLimit=1;
        SampleCount=0;
    end

    properties(Access=public)
PollPointGenerator
    end
    properties(Hidden,Constant)
        varName='X';
        weights=[0.3,0.5,0.8,0.95];

        maxTries=10;
        restartWhenTrialsTooClose=true
        adaptiveNumCand=true;

        useQuasi=false;
    end

    methods

        function self=SurrogateAdaptiveTrial(problem,options,TrialMgr)

            self.problem=problem;
            self.options=options;
            self.TrialMgr=TrialMgr;

            if~isfield(self.options,'AdaptiveSampleBatchSize')
                self.Data.numAdaptiveSamples=1;
            else
                self.Data.numAdaptiveSamples=max(1,self.options.AdaptiveSampleBatchSize);
            end


            nvar=self.problem.nvar;
            self.Data.minNumCand=min(100*nvar,self.Data.maxNumCand);

            self.Data.DistanceTolerance=self.options.MinSampleDistance;
            self.Data.failTol=max(5,nvar);
            self.Data.restartTol=self.options.MaxStallIterations;
            self.Data.constFailTol=ceil(2*sqrt(nvar));
            self.Data.constSuccTol=ceil(2*sqrt(nvar));

            if~isfield(self.options,'BatchUpdateInterval')
                self.Data.numAdaptivePoints=1;
            else
                self.Data.numAdaptivePoints=max(1,self.options.BatchUpdateInterval);
            end


            self.Data.sigmaInit=self.Data.sigmaInit*ones(nvar,1);

            self.haveInteger=self.problem.mInt>0;
            if~self.haveInteger

                self.AlwaysHonorInteger=false;
            else
                self.Data.sigmaInit(self.problem.vartype)=0.5;


                self.shallowSearchNodeLimit=...
                min(1000,5*sum(self.problem.range(self.problem.vartype)));
                self.deepSearchNodeLimit=...
                min(5000,20*sum(self.problem.range(self.problem.vartype)));
            end

            if isfield(self.options,'CheapConstraint')&&...
                ~isempty(self.options.CheapConstraint)

                self.NeverRefineTrial=true;
            end

            if~self.NeverRefineTrial
                self.trialRefinementChecks();
            end
            if(self.problem.mineq_cheap+self.problem.mineq_expensive==0&&...
                self.problem.mInt==0&&isempty(self.problem.Aineq)&&...
                isempty(self.problem.Aeq))&&...
                strcmpi(self.options.AdaptiveSampler,'random')

                self.samplers={'random'};

                self.NeverRefineTrial=true;
            end
            self.initParams();


        end


        function X=proposeEvaluations(self,trialData,surrogates,...
            incumbent)

            self.surrogates=surrogates;

            if self.problem.nobj_expensive>0
                objSurrogates=@(x)surrogates(x,'Fval');
            else
                objSurrogates=[];
            end

            if self.problem.mineq_expensive>0
                constrSurrogates=@(x)surrogates(x,'Ineq');
            else
                constrSurrogates=[];
            end



            refineBeforeRestart=self.Data.restartCounter==self.Data.restartTol-1;

            oldCand=[trialData.getIndependentVariable();self.Data.Xpend];


            X=self.proposeAllPoints(trialData,objSurrogates,...
            constrSurrogates,incumbent,oldCand,refineBeforeRestart);
            if~any(isnan(X))

                self.Data.Counter=self.Data.Counter+size(X,1);
            end

            if self.Data.numAdaptivePoints==1





                self.advanceWeights();
            end


            self.advanceSampler();






            if~isempty(X)
                infeas=self.check_infeasible(X);
                if any(infeas)
                    if self.options.Verbosity>=3
                        fprintf('Removing %d infeasible adaptive point(s) out of %d.\n',...
                        nnz(infeas),length(infeas));
                    end
                    X(infeas,:)=[];
                end
            elseif self.options.Verbosity>=3
                disp('Try random sampler.');
            end

        end


        function updateSolverData(self,incumbent,current,...
            infeas_improved,feas_improved)















            trials=self.TrialMgr.getPendingTrials();
            if~isempty(trials)
                self.Data.Xpend=vertcat(trials.(self.varName));
            else
                self.Data.Xpend=[];
            end

            if~strcmpi(current.flag,'adaptive')


                return;
            end

            tolCon=self.options.ConstraintTolerance;
            tolFun=self.options.ObjectiveImprovementThreshold;


            if self.problem.mineq_expensive>0

                if current.constrviolation<=tolCon

                    self.Data.constSuccCounter=self.Data.constSuccCounter+1;
                    self.Data.constFailCounter=0;


                    self.Data.notEnoughTrialsCounter=max(0,self.Data.notEnoughTrialsCounter-1);


                    if self.Data.constSuccCounter==self.Data.constSuccTol
                        self.Data.constMargin=self.Data.constMargin/2;
                        self.Data.constSuccCounter=0;
                    end
                else
                    self.Data.constFailCounter=self.Data.constFailCounter+1;
                    self.Data.constSuccCounter=0;

                    if self.Data.constFailCounter==self.Data.constFailTol
                        self.Data.constMargin=...
                        min(self.Data.marginMax,2*self.Data.constMargin);
                        self.Data.constFailCounter=0;
                    end
                end
            end

            if incumbent.constrviolation<=tolCon

                deltaF=abs(incumbent.fval-current.fval);

                if(~isempty(deltaF)&&feas_improved&&...
                    deltaF>tolFun*max(1,abs(incumbent.fval)))

                    self.Data.succCounter=self.Data.succCounter+1;
                    self.Data.failCounter=0;
                    self.Data.restartCounter=0;


                    self.Data.notEnoughTrialsCounter=max(0,self.Data.notEnoughTrialsCounter-1);

                    if self.Data.succCounter==self.Data.succTol
                        self.Data.samplingRadius=...
                        min(self.Data.sigmaMax,2*self.Data.samplingRadius);

                        self.Data.succCounter=0;
                        if self.adaptiveNumCand
                            self.Data.numCand=min(self.Data.minNumCand,ceil(self.Data.numCand/2));
                        end
                    end

                else

                    self.Data.failCounter=self.Data.failCounter+1;
                    self.Data.restartCounter=self.Data.restartCounter+1;
                    self.Data.succCounter=0;

                    if self.Data.failCounter==self.Data.failTol

                        self.Data.samplingRadius=...
                        max(self.Data.sigmaMin,self.Data.samplingRadius*0.5);

                        self.Data.failCounter=0;
                        if self.adaptiveNumCand
                            self.Data.numCand=min(self.Data.maxNumCand,ceil(self.Data.numCand*2));
                        end

                    end
                end


            elseif infeas_improved&&...
                current.constrviolation<...
                (incumbent.constrviolation-sqrt(tolCon)*incumbent.constrviolation)

                self.Data.restartCounter=0;


                self.Data.notEnoughTrialsCounter=max(0,self.Data.notEnoughTrialsCounter-1);


            else
                self.Data.restartCounter=self.Data.restartCounter+1;

            end

            if self.Data.restartCounter>=self.Data.restartTol
                if self.options.Verbosity>=3
                    disp('Adaptive sampler did not improve incumbent.fval; reset surrogate.');
                end
                self.state.surrogateReset=true;
                return;
            end

            self.Data.scaledSamplingRadius=self.Data.samplingRadius.*self.problem.range;

            intVar=self.problem.vartype;
            self.Data.scaledSamplingRadius(intVar)=...
            max(self.Data.scaledSamplingRadius(intVar),min(self.problem.range(intVar),2));

            self.Data.scaledConstMargins=...
            self.Data.constMargin*max(tolCon,min(self.problem.range));

        end


        function reset(self)
            self.initParams();
        end

        function restoreState(~,~)


        end

    end

    methods(Access=private)

        function X=proposeAllPoints(self,trialData,objSurrogates,...
            constrSurrogates,incumbent,oldCand,refineBeforeRestart)













            nvar=self.problem.nvar;
            sampler=self.samplers{self.Data.nextSampler};

            X=self.proposeAndQualifyPoints(trialData,objSurrogates,...
            constrSurrogates,incumbent,[],oldCand,sampler,@dualGoal);



            if~self.state.surrogateOK
                return;
            end


            if~isempty(X)&&self.haveInteger&&self.AlwaysHonorInteger
                X=globaloptim.bmo.boundAndRound(X,self.problem,oldCand,self.options);
                if isempty(X)


                    self.checkNotEnoughTrialsCondition();
                end
            end


            if self.state.exitflag~=0
                return;
            end





            if self.NeverRefineTrial
                return;
            end



            if self.state.surrogateReset


                refineBeforeRestart=true;
            end


            if refineBeforeRestart

                self.refineTrialNow=true;
                self.options.TreeSearchOptions.NodeLimit=...
                self.deepSearchNodeLimit;
            elseif mod(self.Data.Counter,2*nvar)==0

                self.refineTrialNow=true;
                self.options.TreeSearchOptions.NodeLimit=...
                self.shallowSearchNodeLimit;
            else
                self.refineTrialNow=false;
                return;
            end


            if isempty(X)
                X=incumbent.X;
            end


            nPointsToRefine=1;
            cand=X(1:nPointsToRefine,:);

            for ii=1:nPointsToRefine
                if refineBeforeRestart

                    x0=incumbent.X;
                    SR=[];
                else
                    x0=cand(ii,:);
                    SR=self.Data.scaledSamplingRadius;
                end
                xRefined=globaloptim.bmo.refineTrial(self.surrogates,...
                x0,self.MinlpProbData,...
                SR,self.options);
                if~isempty(xRefined)
                    X=[xRefined;X];
                    X=uniquetol(X,1e-10,'ByRows',true);
                end
            end

            if self.haveInteger

                X=globaloptim.bmo.boundAndRound(X,self.problem,oldCand,self.options);
            end

            if isempty(xRefined)
                if self.options.Verbosity>=3
                    fprintf('(MI)NLP solver did not generate any adaptive point.\n');
                end
                return;
            end

            if self.Data.numAdaptivePoints==1&&size(X,1)>1



                X=self.proposeAndQualifyPoints(trialData,objSurrogates,...
                constrSurrogates,incumbent,X,oldCand,[],@blindGoal);
            end

        end


        function X=proposeAndQualifyPoints(self,trialData,objSurrogates,...
            constrSurrogates,incumbent,Xin,oldCand,method,meritFcn)



            tolCon=self.options.ConstraintTolerance;



            if incumbent.constrviolation>tolCon

                phase=1;
            elseif isempty(objSurrogates)

                X=[];
                self.state.exitflag=1;
                self.state.surrogateReset=true;
                return;
            elseif~isempty(objSurrogates)

                phase=2;
            end


            solverData=self.Data;
            numPoints=solverData.numAdaptivePoints;
            optProb=self.problem;
            dim=self.problem.nvar;

            nconst_cheap=optProb.mineq_cheap;
            evalCount=trialData.getEvalCount();

            if~self.state.surrogateOK



                self.state.surrogateOK=verifySurrogate(Xin,[]);
                if~self.state.surrogateOK
                    X=[];
                    return;
                end
            end

            done=false;
            cand=[];
            if~isempty(method)

                count=1;
                nPoints=self.Data.numCand;

                while~done&&count<self.maxTries



                    if nconst_cheap>0

                        candNew=globaloptim.bmo.trialPoints(self,nPoints,...
                        incumbent.(self.varName),Xin,method,evalCount,...
                        oldCand);

                        constVal=optProb.constrfun(candNew);
                        if size(constVal,1)~=size(candNew,1)
                            error(message('globaloptim:bmo:cheapConstraintSizeMismatch',...
                            size(constVal,1),size(constVal,2),size(candNew,1),nconst_cheap))
                        end

                        feas=sum(constVal<=tolCon,2)==nconst_cheap;
                        cand=[cand;candNew(feas,:)];


                        if size(cand,1)>=numPoints
                            done=true;
                        end

                        count=count+1;
                    else

                        cand=globaloptim.bmo.trialPoints(self,nPoints,...
                        incumbent.(self.varName),Xin,method,evalCount,...
                        oldCand);
                        done=true;
                    end
                    self.SampleCount=self.SampleCount+size(cand,1);
                end

            elseif size(Xin,1)>0
                done=true;
            end



            cand=[Xin;cand];


            if~done



                X=[];
                self.state.exitflag=-2;
                self.state.msg=getString(message('globaloptim:bmo:infeasibleCheapConstraints'));
                if self.options.Verbosity>=3
                    disp(self.state.msg);
                end
                return;
            end

            if size(cand,1)==0


                X=[];
                self.checkNotEnoughTrialsCondition();
                return;
            end
            X=zeros(numPoints,dim);
            toRemove=false(numPoints,1);

            if phase==1
                phase1();
            else
                phase2();
            end

            X(toRemove,:)=[];

            if self.options.Verbosity>=5
                fprintf('Created %g trial points using the AdaptiveSampler\n',...
                size(cand,1));

                fprintf('   Points needed %g, accepted %g\n',numPoints,size(X,1));
            end


            function phase1()


                surrPred=constrSurrogates(cand);
                num_Infeas=sum(surrPred>tolCon,2);

                for i=1:numPoints

                    minViolations=min(num_Infeas);
                    ind=find(num_Infeas==minViolations);

                    if length(ind)>1


                        maxViolation=max(surrPred(ind,:),[],2);
                        [~,ind2]=min(maxViolation);
                        ind=ind(ind2);
                    end
                    X(i,:)=cand(ind,:);
                    num_Infeas(ind)=inf;


                    if numPoints>1
                        self.advanceWeights()
                    end
                end
            end


            function phase2()



                [TF,candVal,candDist]=evaluateSurrogatesAndDistance();
                if~TF
                    return;
                end


                for ii=1:min(numPoints,size(cand,1))
                    if ii>1

                        temp=min(self.options.DistanceFcn(cand,X(ii-1,:),...
                        solverData.DistanceTolerance),[],2);

                        candDist=min([candDist,temp],[],2);
                    end



                    w=self.weights(self.Data.nextWeight);
                    merit=meritFcn(w,candVal,candDist,solverData.DistanceTolerance);
                    [~,bestInd]=min(merit);

                    if isinf(merit(bestInd))

                        toRemove(ii:end)=true;

                        if ii<max(1,round(0.1*min(numPoints,size(cand,1))))





                            self.Data.notEnoughTrialsCounter=...
                            ceil(self.Data.notEnoughTrialsCounter+...
                            0.02*self.options.MinSurrogatePoints);
                        end
                        self.checkNotEnoughTrialsCondition();
                        break;
                    else

                        X(ii,:)=cand(bestInd,:);
                        candVal(bestInd)=inf;
                    end

                    if numPoints>1
                        self.advanceWeights()
                    end
                end
            end


            function[TF,candVal,candDist]=evaluateSurrogatesAndDistance()
                TF=true;
                candVal=[];candDist=[];
                if optProb.mineq_expensive>0
                    surrPred=constrSurrogates(cand);


                    if isempty(surrPred(:))
                        toRemove(:)=true;
                        if self.options.Verbosity>=3
                            disp('Surrogate (constraints) evaluation failed; possibly points are not well-poised.');
                        end
                        TF=false;
                        return;
                    end
                    num_Infeas=sum(surrPred>tolCon,2);
                    minViolations=min(num_Infeas);


                    ind=find(num_Infeas==minViolations);
                    cand=cand(ind,:);
                end


                candVal=objSurrogates(cand);
                candDist=min(self.options.DistanceFcn(cand,oldCand,...
                solverData.DistanceTolerance),[],2);



                if isempty(candVal)||all(~isfinite(candVal))
                    toRemove(:)=true;
                    if self.options.Verbosity>=3
                        disp('Surrogate evaluation failed; possibly points are not well-poised.');
                    end
                    TF=false;
                    return;
                end
            end


            function TF=verifySurrogate(Xin,method)
                cand=globaloptim.bmo.trialPoints(self,1,...
                incumbent.(self.varName),Xin,method,evalCount,[]);

                if isempty(cand)


                    TF=false;
                    return;
                end

                TF=self.problem.nobj_expensive>0&&...
                ~isempty(objSurrogates(cand));


                if~TF
                    TF=self.problem.mineq_expensive>0&&...
                    ~isempty(constrSurrogates(cand));
                end
            end

        end



        function checkNotEnoughTrialsCondition(self)
            if self.restartWhenTrialsTooClose&&...
                (self.Data.notEnoughTrialsCounter>self.options.MinSurrogatePoints)
                self.state.surrogateReset=true;
                self.Data.notEnoughTrialsCounter=0;
                if self.options.Verbosity>=3
                    fprintf('Adaptive sampler trials too close; surrogate reset.\n');
                end
            else
                self.Data.notEnoughTrialsCounter=self.Data.notEnoughTrialsCounter+1;
            end
        end

        function advanceSampler(self)

            self.Data.nextSampler=self.Data.nextSampler+1;
            if self.Data.nextSampler==length(self.samplers)+1
                self.Data.nextSampler=1;
            end
        end

        function advanceWeights(self)

            self.Data.nextWeight=self.Data.nextWeight+1;
            if self.Data.nextWeight==length(self.weights)+1
                self.Data.nextWeight=1;
            end

        end

        function trialRefinementChecks(self)



            if~isfield(self.options,'fminconOptions')
                fminconOptions=optimoptions('fmincon','Algorithm','sqp','Display','off');
            else
                fminconOptions=optimoptions(self.options.fminconOptions,'Algorithm','sqp');
            end


            fminconOptions.ConstraintTolerance=min(...
            self.options.LinearConstraintTolerance,...
            self.options.ConstraintTolerance);


            fminconOptions.SpecifyObjectiveGradient=true;
            fminconOptions.SpecifyConstraintGradient=true;
            self.options.fminconOptions=fminconOptions;


            self.options.fminconNodeOptions=setSQPoptions(fminconOptions,...
            self.problem.nvar);

            if~isfield(self.options,'NodeOptions')
                self.options.NodeOptions=struct('BranchingMethod','variable',...
                'NodeSelection','lexical','WarmStartParentX0',1);
            end



            if~isfield(self.options,'TreeSearchOptions')
                self.options.TreeSearchOptions=struct('TimeLimit',realmax,...
                'NodeLimit',self.shallowSearchNodeLimit,...
                'AbsoluteGap',1e-3,...
                'RelativeGap',1e-3);
            end

            self.MinlpProbData=struct('nvar',self.problem.nvar,...
            'lb',self.problem.lb,...
            'ub',self.problem.ub,...
            'x0',[],...
            'nobj_cheap',self.problem.nobj_cheap,...
            'nobj_expensive',self.problem.nobj_expensive,...
            'mineq_cheap',self.problem.mineq_cheap,...
            'mineq_expensive',self.problem.mineq_expensive,...
            'meq_cheap',self.problem.meq_cheap,...
            'meq_expensive',self.problem.meq_expensive,...
            'objfun',self.problem.objfun,...
            'constrfun',self.problem.constrfun,...
            'Aineq',self.problem.Aineq,'bineq',self.problem.bineq,...
            'Aeq',self.problem.Aeq,'beq',self.problem.beq,...
            'fixedID',[],...
            'constr_margin',[],...
            'phase',[],...
            'intcon',find(self.problem.vartype)-1);

        end

        function initParams(self)


            self.Data.numCand=min(self.Data.maxNumCand,100*self.problem.nvar);

            self.Data.samplingRadius=self.Data.sigmaInit;
            self.Data.constMargin=self.Data.marginInit;

            self.Data.constFailCounter=0;
            self.Data.constSuccCounter=0;
            self.Data.failCounter=0;
            self.Data.succCounter=0;
            self.Data.restartCounter=0;
            self.Data.notEnoughTrialsCounter=0;

            self.Data.scaledSamplingRadius=self.Data.samplingRadius.*self.problem.range;

            intVar=self.problem.vartype;
            self.Data.scaledSamplingRadius(intVar)=...
            max(self.Data.scaledSamplingRadius(intVar),min(self.problem.range(intVar),2));

            tolCon=self.options.ConstraintTolerance;
            self.Data.scaledConstMargins=...
            self.Data.constMargin*max(tolCon,min(self.problem.range));

            self.state.surrogateReset=false;
            self.state.surrogateOK=false;
            self.Data.nextWeight=1;

            self.Data.Counter=0;


            if(~isempty(self.problem.Aineq)||~isempty(self.problem.Aeq))
                inputArgs=struct('PollMethod','gpspositivebasis2np2',...
                'PollOrderAlgorithm','consecutive',...
                'ConstraintTolerance',self.options.ConstraintTolerance,...
                'ActiveConstraintTolerance',1e-6,...
                'BasisType','orthomads',...
                'linconstrtype','linearconstraints',...
                'scale',1,...
                'MeshScaleFactor',1,...
                'nVars',self.problem.nvar,...
                'Verbosity',self.options.Verbosity);

                self.PollPointGenerator=globaloptim.internal.directions.PollPoints(inputArgs);
            end

        end

        function checkInputs(self)

            assert(isfloat(self.Data.numCand)&&(self.Data.numCand>0)&&isfinite(self.Data.numCand),...
            'Incorrect number of candidate points')

            assert(self.options.doDycors==0||self.options.doDycors==1,...
            'Second argument must be true or false')

            assert(length(self.weights)==numel(self.weights),...
            'weights must be an array')

            assert(all(self.weights<=1)&&all(self.weights>=0),...
            'All elements of weights must be in [0,1]')
        end

        function checkCurrent(self,incumbent)

            assert(~isempty(incumbent.(self.varName)),...
            'current.trial cannot be empty');

            assert(length(incumbent.(self.varName))==self.problem.nvar,...
            'current.trial has incorrect size');

            assert(all(incumbent.(self.varName)>=self.problem.lb')&&...
            all(incumbent.(self.varName)<=self.problem.ub'),...
            'incumbent.trial is outside the bounds')
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
    end
end


function scaledVals=unitRescale(vals)
    finite_id=isfinite(vals);
    if isempty(finite_id)
        scaledVals=inf*ones(size(vals));
    else
        finite_vals=vals(finite_id);
        mmin=min(finite_vals);
        mmax=max(finite_vals);
        if mmin==mmax
            scaledVals=ones(size(vals));
            scaledVals(~finite_id)=inf;
        else
            scaledVals=(vals-mmin)/(mmax-mmin);
        end
    end
end

function options=setSQPoptions(optionsIn,nvar)
    options=struct();
    options.Display=optionsIn.Display;
    options.MaxIter=optionsIn.MaxIter;
    options.MaxFunEvals=optionsIn.MaxFunEvals;
    if strcmpi(options.MaxFunEvals,'100*numberOfVariables')
        options.MaxFunEvals=100*nvar;
    end
    assert(isfloat(options.MaxFunEvals));
    options.ScaleProblem=optionsIn.ScaleProblem;
    options.TolCon=optionsIn.TolCon;
    options.TolFun=optionsIn.TolFun;
    options.TolX=optionsIn.TolX;
    options.ObjectiveLimit=optionsIn.ObjectiveLimit;

end


function meritVal=dualGoal(w_val,candVal,candDist,minDist)

    meritVal=w_val*unitRescale(candVal)+...
    (1-w_val)*(1-unitRescale(candDist));
    meritVal(candDist<minDist)=inf;
end

function meritVal=blindGoal(~,candVal,candDist,minDist)


    meritVal=ones(numel(candVal),1);
    meritVal(isinf(candVal))=Inf;
    meritVal(candDist<minDist)=inf;
end
