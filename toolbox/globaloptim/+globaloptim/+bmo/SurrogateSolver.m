



classdef SurrogateSolver<handle

    properties(Hidden,Constant)

        default_range=[-10;10];
        maxAlloc=10000;

        useAllTrialDataForDistance=true;
        doDycors=false;
        removeFixedVars=true;
        EFLAG_FIXED=10;
        EFLAG_LINEAR_INFEAS=-2;
        EFLAG_INCONSISTENT_RESPONSE=-99;
        EFLAG_EMPTY_NULL=1;
        STEP_TOLERANCE=1e-10;
        STALL_NO_POINTS=0;


        varName='X';
        expensiveModel_response={'Fval','Ineq'};
        cheapModel_response={'CheapFval','CheapIneq'};
        defaultAdaptiveSampler='globaloptim.bmo.optimizer.SurrogateAdaptiveTrial';

        savedVars={'current','incumbent','globalBest','trialData',...
        'surrogateData','state','problem','setupInfo','TrialMgr',...
        'rngstate','options','RandomSampler','AdaptiveSampler',...
        'fixedVarInfo','dataStoreArgs'};
    end

    properties(SetAccess=private,GetAccess=public)
id
CheckpointFile

        setupInfo=struct()

TrialMgr

RandomSampler
AdaptiveSampler
options


        problem=struct('nvar',[],'nOrigVar',[],'lb',[],'ub',[],'ntrials',[],...
        'nobj_cheap',0,'nobj_expensive',0,'mineq_cheap',0,'mineq_expensive',0,...
        'meq_cheap',0,'meq_expensive',0,'objfun',[],'constrfun',[],'range',[],...
        'Aineq',[],'bineq',[],'Aeq',[],'beq',[],'vartype',[],'mInt',0,...
        'intcon',[],'NullBasisAeq',[],'EmptyNullSpace',false,'X0',[]);


        fixedVarInfo=[];


current
incumbent
globalBest

dataStoreArgs
        trialData=globaloptim.bmo.surrogates.SurrogateData({'X',0},[]);
        surrogateData=globaloptim.bmo.surrogates.SurrogateData({'X',0},[]);
        surrogates=[]
        MinNumPoints=[]

user_tids
startTime
rngstate
















        state=struct('phase',0,...
        'init_eval_OK',false,...
        'id',[],...
        'funccount',0,...
        'elapsedtime',0.0,...
        'timeoffset',0.0,...
        'random_sample_size',[],...
        'numPointsBeforeAdaptivePhase',[],...
        'Verbosity',0,...
        'msg','',...
        'errmsg','',...
        'retcode',1,...
        'exitflag',[],...
        'notify_model_about_restart',true,...
        'initial_point_consistent_check',false,...
        'surrogateReset',false,...
        'surrogateResetCntr',[],...
        'nFeasPoints',[],...
        'incumbentChangeCntr',[],...
        'globalBestChangeCntr',[],...
        'checkpointResumeCntr',[],...
        'surrogateUpdateCntr',0,...
        'obj_field',[]);

    end

    methods(Access=public)


        function self=SurrogateSolver(input)

            self.state.id=char(matlab.lang.internal.uuid);
            self.id=self.state.id;
            self.saveSetup(input);
            self.startTime=tic;

            [self.current,self.incumbent,self.globalBest]=...
            initTrialPoints(self.varName);

        end


        function output=setup(self,input,output)

            if self.state.phase<=0
                self.saveSetup(input);
                output.retcode=1;
            else

                warning(message('globaloptim:bmo:setupChangeWhileRunning'));
                output.retcode=-1;
            end

            output.id=input.id;
            output.message=self.state.msg;
        end


        function output=getTrial(self,~)

            if~(self.state.retcode>0)

                error(message('globaloptim:bmo:setupErrorCannotCallGetTtrial'));
            end

            if~isempty(self.state.exitflag)
                if self.state.exitflag==self.EFLAG_FIXED

                    self.TrialMgr.addTrial(self.fixedVarInfo.fixedValues,'adaptive');
                    output=self.TrialMgr.getWaitingTrial();


                    self.TrialMgr.removeTrial(output.tid);
                elseif self.state.exitflag==self.EFLAG_LINEAR_INFEAS

                    output.(self.varName)=[];
                end
                output.message=self.state.msg;
                output.retcode=self.state.retcode;
                output.exitflag=self.state.exitflag;
                output.id=self.state.id;
                return;
            end


            if self.state.phase==0
                self.verifySetup();

                if self.state.exitflag==self.EFLAG_LINEAR_INFEAS
                    output.(self.varName)=[];
                    output.message=self.state.msg;
                    output.retcode=self.state.retcode;
                    output.exitflag=self.state.exitflag;
                    output.id=self.state.id;
                    return;
                end
                if self.state.exitflag==self.EFLAG_FIXED
                    output.(self.varName)=self.fixedVarInfo.fixedValues;
                    output.message=self.state.msg;
                    output.retcode=self.state.retcode;
                    output.exitflag=self.state.exitflag;
                    output.id=self.state.id;
                    return;
                end

            end


            output=self.TrialMgr.getWaitingTrial();

            if isempty(output)

                self.createNewTrial()

                output=self.TrialMgr.getWaitingTrial();
            else

                output.message='Trial from the queue';
            end


            if isempty(output)
                output=struct();
                output.(self.varName)=[];
                output.message='Failed to create new trials.';
                output.retcode=self.STALL_NO_POINTS;
            else

                output.message='New trials created.';
                output.retcode=1;
            end

            output.id=self.state.id;
            output.exitflag=0;

            self.state.errmsg='';
            if output.retcode~=0&&~(isfield(output,self.varName))

                error(message('globaloptim:bmo:outputMissingFieldX'))
            end

            if output.retcode~=0&&~isempty(self.fixedVarInfo)

                output.(self.varName)=unfixVariables(output.(self.varName),...
                self.fixedVarInfo);
            end
        end


        function output=getMetrics(self,input)


            if self.state.phase==0
                self.verifySetup();
            end


            if~isempty(self.state.exitflag)
                output=self.globalBest;
                output.exitflag=self.state.exitflag;
                output.message=self.state.msg;
                output.retcode=self.state.retcode;
                output.surrogateResetCount=length(self.state.surrogateResetCntr);
                output.checkpointResumeCount=length(self.state.checkpointResumeCntr);
                output.elapsedtime=self.state.elapsedtime;
                output.checkpointResume=false;
                output.surrogateReset=self.state.notify_model_about_restart;
                output.nFeasPoints=self.state.nFeasPoints;

                if self.state.exitflag==self.EFLAG_LINEAR_INFEAS||...
                    self.state.exitflag==self.EFLAG_INCONSISTENT_RESPONSE
                    output.(self.varName)=[];
                elseif self.state.exitflag==self.EFLAG_FIXED
                    output.(self.varName)=self.fixedVarInfo.fixedValues;
                end
                return
            end


            if isfield(input,'iter')&&isfield(input,'metrics')
                output=self.unfixOutput(getPastMetrics(self,input));
                return
            end

            output=self.globalBest;
            if isfield(input,'metrics')
                output.current=self.current;
                output.incumbent=self.incumbent;
                output.elapsedtime=self.state.elapsedtime;
                output.checkpointResume=false;
                output.surrogateReset=self.state.notify_model_about_restart;

                self.state.notify_model_about_restart=false;

            end
            output=self.unfixOutput(output);

            if isfield(input,'results')
                output.trialData.(self.varName)=...
                self.trialData.getIndependentVariable();

                if~isempty(self.fixedVarInfo)
                    output.trialData.(self.varName)=unfixVariables(...
                    output.trialData.(self.varName),self.fixedVarInfo);
                end





                if self.problem.nobj_expensive>0
                    output.trialData.(self.expensiveModel_response{1})=...
                    self.trialData.getResponses(self.expensiveModel_response{1});
                end
                if self.problem.mineq_expensive>0
                    output.trialData.(self.expensiveModel_response{2})=...
                    self.trialData.getResponses(self.expensiveModel_response{2});
                end

            end
            output.surrogateResetCount=length(self.state.surrogateResetCntr);
            output.checkpointResumeCount=length(self.state.checkpointResumeCntr);
            output.nFeasPoints=self.state.nFeasPoints;
            output.id=input.id;
            output.retcode=isempty(self.state.errmsg);
            output.message=self.state.errmsg;
            output.exitflag=self.state.exitflag;

        end


        function output=updateResponse(self,response)

            if~(self.state.phase>0)

                error(message('globaloptim:bmo:updateResponseConditionFailed'))
            end
            if~isempty(self.state.exitflag)

                output.id=response.id;
                output.message=self.state.errmsg;
                output.retcode=1;
                output.exitflag=self.state.exitflag;
                return;
            end

            if~isempty(response)
                self.TrialMgr.updateTrial(response,false,true);
                self.state.elapsedtime=toc(self.startTime)+self.state.timeoffset;
                self.state.funccount=self.state.funccount+1;



                if~self.state.initial_point_consistent_check&&...
                    self.state.init_eval_OK&&...
                    ~self.consistentResponse(response)

                    output.id=response.id;
                    output.message=self.state.errmsg;
                    output.retcode=1;
                    output.exitflag=self.state.exitflag;
                    return;
                end

            end

            if self.state.phase==1




                trial=self.TrialMgr.getEvaluated(response(1).tid);
                if~trial.failed

                    response_ok=true;
                else
                    response_ok=false;
                    self.current=self.failedTrial(trial);
                end

                if response_ok&&~self.verifyInitialResponse(trial)

                    error(message('globaloptim:bmo:verifyInitialResponseFailed'))
                end

                if response_ok

                    self.setSurrogatesAndAdaptiveSampler(self.setupInfo);

                    self.initParams();

                end
            else
                self.updateIterationData();

                if self.state.surrogateReset
                    self.resetSearch();
                end
            end

            output.id=response.id;

            output.message='Update OK';
            output.retcode=1;
            self.state.errmsg='';
        end


        function output=saveState(self)

            fileName=self.options.CheckpointFile;
            if isempty(fileName)
                output.retcode=1;
                return;
            end
            self.rngstate=rng;
            SurrogateSolverData=struct();
            for ii=1:length(self.savedVars)
                var=self.savedVars{ii};
                SurrogateSolverData.(var)=self.(var);
            end

            if exist(fileName,'file')
                CheckPointData=struct();loadCheckPointFile()
                CheckPointData.SurrogateSolverData=SurrogateSolverData;
            else
                CheckPointData.SurrogateSolverData=SurrogateSolverData;
            end
            save(self.options.CheckpointFile,'CheckPointData');



            output.retcode=1;

            function loadCheckPointFile()

                warnState=warning('query','MATLAB:load:variableNotFound');
                warning('off','MATLAB:load:variableNotFound')
                try
                    load(self.options.CheckpointFile,'CheckPointData')
                    warning(warnState)
                catch ME
                    warning(warnState)
                    rethrow(ME)
                end
            end
        end


        function output=restoreState(self,input)
            if~(isfield(input,'restorefile')&&...
                isfield(input,'load'))
                output.retcode=-1;
                return;
            end

            warnState=warning('query','MATLAB:load:variableNotFound');
            warning('off','MATLAB:load:variableNotFound')
            try
                load(input.restorefile,'-mat','CheckPointData');
                warning(warnState)
            catch ME
                warning(warnState)
                rethrow(ME)
            end

            if isempty(CheckPointData)
                error(message('globaloptim:surrogateopt:CheckpointDataNotConsistent'))
            end

            SurrogateSolverData=CheckPointData.SurrogateSolverData;

            try
                for ii=1:length(self.savedVars)
                    var=self.savedVars{ii};
                    self.(var)=SurrogateSolverData.(var);
                end
            catch ME
                error(message('globaloptim:surrogateopt:CheckpointDataNotConsistent'))
            end

            rng(self.rngstate);


            if isfield(input,'CheckpointFile')
                self.options.CheckpointFile=input.CheckpointFile;
            end

            if isfield(input,'MinSurrogatePoints')
                self.options.MinSurrogatePoints=input.MinSurrogatePoints;
            end

            self.state.timeoffset=self.state.elapsedtime;

            self.state.id=self.id;


            self.state.checkpointResumeCntr(end+1)=self.state.funccount+1;
            self.state.checkpointResumeCntr=unique(self.state.checkpointResumeCntr);


            self.TrialMgr.makePendingTrialsWaiting();


            self.setSurrogates(self.setupInfo);

            if~isempty(self.state.surrogateResetCntr)

                self.addOldDataInSurrogates([2,3]);
            else

                self.addOldDataInSurrogates([1,2,3]);
            end


            self.RandomSampler.restoreState(input.restorefile);
            self.AdaptiveSampler.restoreState(input.restorefile);

            output.retcode=1;
        end
    end

    methods(Access=private)


        function saveSetup(self,input)

            fnames=fieldnames(input);
            for ii=1:length(fnames)
                self.setupInfo.(fnames{ii})=input.(fnames{ii});
            end

            self.state.retcode=1;

            self.state.msg='Setup data OK';
        end


        function verifySetup(self)

            input=self.setupInfo;


            self.checkLinearConstraints(input);
            if self.state.exitflag==self.EFLAG_LINEAR_INFEAS
                return;
            end


            input.(self.varName)=self.checkTrials(input);


            self.problem.vartype=false(self.problem.nvar,1);

            if isfield(input,'intcon')&&~isempty(input.intcon)
                self.problem.vartype(input.intcon)=true;
                self.problem.mInt=numel(input.intcon);
                self.problem.intcon=input.intcon;


                input.AdaptiveSampler=self.defaultAdaptiveSampler;
                self.setupInfo.AdaptiveSampler=input.AdaptiveSampler;
            end


            if self.removeFixedVars
                input=self.checkFixedVars(input);
            end


            self.problem.range=self.problem.ub-self.problem.lb;


            self.verifyOptions(input);


            self.addUserTrialsInQueue(input);


            self.setRandomSampler(input)

            self.state.phase=1;



            if self.state.init_eval_OK
                self.setSurrogatesAndAdaptiveSampler(input)

                self.initParams();

            end

        end


        function consistent=consistentResponse(self,response)


            consistent=true;
            if self.problem.nobj_expensive>0&&...
                (~isfield(response,self.expensiveModel_response{1})||...
                size(response.(self.expensiveModel_response{1}),2)~=self.problem.nobj_expensive)
                consistent=false;
            elseif self.problem.nobj_expensive==0&&...
                isfield(response,self.expensiveModel_response{1})&&...
                ~isempty(response.(self.expensiveModel_response{1}))
                consistent=false;
            end
            if self.problem.mineq_expensive>0&&...
                (~isfield(response,self.expensiveModel_response{2})||...
                size(response.(self.expensiveModel_response{2}),2)~=self.problem.mineq_expensive)
                consistent=false;
            elseif self.problem.mineq_expensive==0&&...
                isfield(response,self.expensiveModel_response{2})&&...
                ~isempty(response.(self.expensiveModel_response{2}))
                consistent=false;
            end

            if~consistent
                self.state.errmsg='InitialPoint and function evaluation mismatch';
                self.state.exitflag=self.EFLAG_INCONSISTENT_RESPONSE;
            end

            self.state.initial_point_consistent_check=true;

        end

        function verifyOptions(self,input)






            opts=self.options;


            if isinf(opts.MaxFunctionEvaluations)
                opts.MaxFunctionEvaluations=max(self.maxAlloc,50*self.problem.nOrigVar);
            end


            if isfield(input,'objfun')&&~isempty(input.objfun)&&...
                isa(input.objfun,'function_handle')
                self.problem.objfun=input.objfun;
            end
            if isfield(input,'constrfun')&&~isempty(input.constrfun)&&...
                isa(input.constrfun,'function_handle')
                self.problem.constrfun=input.constrfun;
            end


            opts.rbf_kernel='globaloptim.bmo.surrogates.kernels.CubicKernel';
%#function globaloptim.bmo.surrogates.kernels.CubicKernel
            opts.rbf_tail='globaloptim.bmo.surrogates.tails.LinearTail';
%#function globaloptim.bmo.surrogates.tails.LinearTail
            opts.rbf_capacity=500;
            opts.rbf_mu=1e-6;
            opts.doDycors=self.doDycors;
            opts.verified=false;
            opts.unscaleResponse=false;
            opts.NonlinConstrAlgorithm=1;
            opts.CheckDistance=false;


            tolLP=max(1e-9,opts.LinearConstraintTolerance);
            tolLP=min(0.001,tolLP);
            opts.optionsLP=optimoptions(@linprog,'Display','none',...
            'ConstraintTolerance',tolLP);
            opts.optionsIP=optimoptions(@intlinprog,'Display','none',...
            'ConstraintTolerance',tolLP,...
            'IntegerTolerance',opts.IntegerTolerance,...
            'MaxFeasiblePoint',1);



            if~(isempty(self.problem.Aineq)&&isempty(self.problem.Aeq)&&...
                isempty(self.problem.lb)&&isempty(self.problem.ub))
                opts=globaloptim.internal.initLPSolver(self.problem.intcon,...
                self.problem.Aineq,self.problem.bineq,...
                self.problem.Aeq,self.problem.beq,...
                self.problem.lb,self.problem.ub,opts);
            end

            self.options=opts;

            if~isempty(self.problem.Aineq)||~isempty(self.problem.Aeq)


                self.state.random_sample_size=1;
            else
                self.state.random_sample_size=opts.MinSurrogatePoints;
            end
            self.state.numPointsBeforeAdaptivePhase=opts.MinSurrogatePoints;
            self.state.Verbosity=opts.Verbosity;

        end


        function checkLinearConstraints(self,input)

            if isfield(input,'boundsVerified')
                self.problem.lb=input.lb;
                self.problem.ub=input.ub;
                self.problem.Aineq=input.Aineq;
                self.problem.bineq=input.bineq;
                self.problem.Aeq=input.Aeq;
                self.problem.beq=input.beq;
                self.problem.NullBasisAeq=input.NullBasisAeq;
                self.problem.EmptyNullSpace=input.EmptyNullSpace;
                self.problem.X0=input.X0;
                self.problem.intcon=input.intcon;
                self.problem.nvar=numel(self.problem.lb);
                self.options=globaloptim.bmo.parseSurrogateopt(input,self.problem.nvar);
            else

                if~all(isfield(input,{'lb','ub'}))

                    error(message('globaloptim:bmo:MissingBounds'));
                end


                self.options=globaloptim.bmo.parseSurrogateopt(input,length(input.lb(:)));


                [input,self.state.errmsg]=globaloptim.bmo.verifybounds(input,self.options);

                if~isempty(self.state.errmsg)

                    self.state.exitflag=self.EFLAG_LINEAR_INFEAS;
                    self.state.retcode=1;
                else
                    self.problem.lb=input.lb;
                    self.problem.ub=input.ub;
                    self.problem.Aineq=input.Aineq;
                    self.problem.bineq=input.bineq;
                    self.problem.Aeq=input.Aeq;
                    self.problem.beq=input.beq;
                    self.problem.NullBasisAeq=input.NullBasisAeq;
                    self.problem.EmptyNullSpace=input.EmptyNullSpace;
                    self.problem.X0=input.X0;
                    self.problem.intcon=input.intcon;
                end
                self.problem.nvar=numel(input.lb);
            end
            if self.problem.EmptyNullSpace

                self.fixedVarInfo.fixedValues=self.problem.X0;
                self.state.exitflag=self.EFLAG_FIXED;
                self.state.retcode=1;
                self.state.message=getString(message('globaloptim:surrogateopt:EqualBounds'));
            end


            self.problem.nOrigVar=self.problem.nvar;

        end


        function input=checkFixedVars(self,input)
            lb=self.problem.lb;
            ub=self.problem.ub;
            tol=eps;
            fixedVarIndex=(ub(:)-lb(:))<=tol*max(1,max(abs(ub(:)),abs(lb(:))));
            if any(fixedVarIndex)

                self.problem.lb=lb(~fixedVarIndex);
                self.problem.ub=ub(~fixedVarIndex);
                self.problem.nvar=numel(self.problem.lb);
                self.problem.vartype=self.problem.vartype(~fixedVarIndex);
                self.problem.intcon=find(self.problem.vartype);
                self.problem.mInt=nnz(self.problem.vartype);


                self.fixedVarInfo.fixedVarIndex=fixedVarIndex;
                self.fixedVarInfo.fixedValues=lb(fixedVarIndex)';

                if~isempty(input.(self.varName))
                    input.(self.varName)=input.(self.varName)(:,~fixedVarIndex);
                end


                self.problem.bineq=self.problem.bineq-...
                self.problem.Aineq(:,fixedVarIndex)*lb(fixedVarIndex);
                self.problem.beq=self.problem.beq-...
                self.problem.Aeq(:,fixedVarIndex)*lb(fixedVarIndex);

                self.problem.Aineq=self.problem.Aineq(:,~fixedVarIndex);
                self.problem.Aeq=self.problem.Aeq(:,~fixedVarIndex);

                if~isempty(self.problem.Aeq)
                    self.problem.NullBasisAeq=...
                    globaloptim.patternsearch.eqconstrnullspace(self.problem.Aeq,...
                    self.problem.nvar);

                    self.problem.EmptyNullSpace=...
                    ~isempty(self.problem.NullBasisAeq)&&...
                    norm(self.problem.NullBasisAeq,'Inf')<=...
                    eps*norm(self.problem.Aeq,'Inf');

                    if self.problem.EmptyNullSpace



                        self.fixedVarInfo.fixedValues=self.problem.X0;
                        self.state.exitflag=self.EFLAG_FIXED;
                        self.state.retcode=1;
                        self.state.message=getString(message('globaloptim:surrogateopt:EqualBounds'));
                    end

                end

            end
            if all(fixedVarIndex)

                self.state.exitflag=self.EFLAG_FIXED;
                self.state.retcode=1;
                self.state.message=getString(message('globaloptim:surrogateopt:EqualBounds'));
            end

        end


        function output=unfixOutput(self,output)

            if~isempty(self.fixedVarInfo)
                if isfield(output,self.varName)
                    output.(self.varName)=unfixVariables(output.(self.varName),...
                    self.fixedVarInfo);
                end

                if isfield(output,'current')
                    output.current.(self.varName)=unfixVariables(...
                    self.current.(self.varName),self.fixedVarInfo);
                end
                if isfield(output,'incumbent')
                    output.incumbent.(self.varName)=unfixVariables(...
                    self.incumbent.(self.varName),self.fixedVarInfo);
                end
            end

        end


        function trial=checkTrials(self,input)


            trial=[];ntrials_=0;
            if isfield(input,self.varName)&&~isempty(input.(self.varName))

                nvar_=self.problem.nvar;
                if isfield(input,'ntrials')&&~isempty(input.ntrials)
                    ntrials_=input.ntrials;
                else
                    ntrials_=numel(input.(self.varName))/nvar_;
                end

                if round(ntrials_)~=ntrials_

                    error(message('globaloptim:bmo:MismatchedLengthInitialX',...
                    round(ntrials_)*nvar_))
                end

                trial=reshape(input.(self.varName),ntrials_,nvar_);
            end

            self.problem.ntrials=ntrials_;

        end


        function addUserTrialsInQueue(self,input)

            all_responses=[self.cheapModel_response,...
            self.expensiveModel_response];
            self.TrialMgr=globaloptim.bmo.TrialQueue(all_responses,...
            self.options.Verbosity);

            if isempty(input.(self.varName))

                return;
            end


            trialmgr=self.TrialMgr;
            self.user_tids=trialmgr.addTrial(input.(self.varName),'initial');

            response=self.reshapeUserResponse(input);

            if~isempty(response)

                self.state.init_eval_OK=true;
            end

            if~isempty(response)&&~trialmgr.updateTrial(response,false,true)

                error(message('globaloptim:bmo:TrialUpdateErrorInitialResponse'));
            end


            infeas=~globaloptim.internal.validate.isTrialFeasible(...
            input.(self.varName),...
            self.problem.Aineq,self.problem.bineq,...
            self.problem.Aeq,self.problem.beq,...
            self.problem.lb,self.problem.ub,...
            self.options.ConstraintTolerance);

            if self.problem.mInt>0

                x=input.(self.varName);
                int_index=self.problem.vartype;
                temp=abs(x(:,int_index)-round(x(:,int_index)))>eps;
                integer_infeas=all(temp,2);
                infeas=infeas|integer_infeas;
            end

            if any(infeas)
                if self.state.Verbosity>=3
                    fprintf('Removing %d infeasible inital point(s) out of %d.\n',...
                    nnz(infeas),length(infeas));
                end
                trialmgr.removeTrial(self.user_tids(infeas))
                self.problem.ntrials=self.problem.ntrials-nnz(infeas);

                if self.problem.ntrials==0

                    self.state.init_eval_OK=false;
                end
            end

            self.state.random_sample_size=...
            max(1,self.state.random_sample_size-self.problem.ntrials);
            self.state.numPointsBeforeAdaptivePhase=...
            max(0,self.state.numPointsBeforeAdaptivePhase-self.problem.ntrials);
        end


        function response=reshapeUserResponse(self,input)


            self.state.errmsg='';
            ntrials=self.problem.ntrials;
            response=[];


            fname=self.cheapModel_response{1};
            if isfield(input,fname)
                nobj_cheap=numel(input.(fname))/ntrials;

                if nobj_cheap>0
                    if~(round(nobj_cheap)==nobj_cheap)

                        error(message('globaloptim:bmo:MismatchedSizeResponse',...
                        fname,ntrials))
                    end
                    self.problem.nobj_cheap=nobj_cheap;
                    fval_cheap=reshape(input.(fname),ntrials,nobj_cheap);
                    response.(fname)=mat2cell(fval_cheap,ones(ntrials,1),nobj_cheap);
                end

            end


            fname=self.expensiveModel_response{1};
            if isfield(input,fname)
                nobj_expensive=numel(input.(fname))/ntrials;

                if nobj_expensive>0
                    if~(round(nobj_expensive)==nobj_expensive)

                        error(message('globaloptim:bmo:MismatchedSizeResponse',...
                        fname,ntrials))
                    end

                    self.problem.nobj_expensive=nobj_expensive;
                    fval_expensive=reshape(input.(fname),ntrials,nobj_expensive);
                    response.(fname)=mat2cell(fval_expensive,ones(ntrials,1),nobj_expensive);
                end
            end


            fname=self.cheapModel_response{2};
            if isfield(input,fname)
                mineq_cheap=numel(input.(fname))/ntrials;

                if mineq_cheap>0
                    if~(round(mineq_cheap)==mineq_cheap)

                        error(message('globaloptim:bmo:MismatchedSizeResponse',...
                        fname,ntrials))
                    end
                    self.problem.mineq_cheap=mineq_cheap;
                    ineq_cheap=reshape(input.(fname),ntrials,mineq_cheap);
                    response.(fname)=mat2cell(ineq_cheap,ones(ntrials,1),mineq_cheap);
                end
            end


            fname=self.expensiveModel_response{2};
            if isfield(input,fname)
                mineq_expensive=numel(input.(fname))/ntrials;
                if mineq_expensive>0
                    if~(round(mineq_expensive)==mineq_expensive)

                        error(message('globaloptim:bmo:MismatchedSizeResponse',...
                        fname,ntrials))
                    end
                    self.problem.mineq_expensive=mineq_expensive;
                    ineq_expensive=reshape(input.(fname),ntrials,mineq_expensive);
                    response.(fname)=mat2cell(ineq_expensive,ones(ntrials,1),mineq_expensive);
                end
            end

            if~isempty(response)

                self.assertSingleObjective();

                nn=length(self.user_tids);
                fnames=fieldnames(response);
                Res=struct();
                for ii=1:nn
                    for ff=1:length(fnames)
                        Res(ii).(fnames{ff})=response.(fnames{ff}){ii};
                        Res(ii).tid=self.user_tids(ii);
                    end
                end
                response=Res;
            else
                response=[];
            end
        end


        function have_resposnse=verifyInitialResponse(self,response)


            self.state.errmsg='';
            response_fields=self.TrialMgr.response_fields;
            have_resposnse=false;

            for ii=1:length(response_fields)
                fname=response_fields{ii};
                if isfield(response,fname)&&ismember(fname,response_fields)
                    nelem=numel(response.(fname));

                    if strcmpi(fname,self.cheapModel_response{1})
                        self.problem.nobj_cheap=nelem;

                    elseif strcmpi(fname,self.expensiveModel_response{1})
                        self.problem.nobj_expensive=nelem;

                    elseif strcmpi(fname,self.cheapModel_response{2})
                        self.problem.mineq_cheap=nelem;

                    elseif strcmpi(fname,self.expensiveModel_response{2})
                        self.problem.mineq_expensive=nelem;

                    end
                    have_resposnse=true;
                else

                    have_resposnse=false;
                end
            end

            if have_resposnse

                self.assertSingleObjective();

                self.state.init_eval_OK=true;
                self.state.phase=2;
            end

        end


        function initParams(self)




            if~(self.state.init_eval_OK)

                error(message('globaloptim:bmo:initParamConditionFailed'))
            end

            self.initIncumbent();

            self.dataStoreArgs={};
            if self.problem.nobj_expensive>0

                self.dataStoreArgs{end+1}=self.expensiveModel_response{1};
                self.dataStoreArgs{end+1}=self.problem.nobj_expensive;
            end
            if self.problem.mineq_expensive>0

                self.dataStoreArgs{end+1}=self.expensiveModel_response{2};
                self.dataStoreArgs{end+1}=self.problem.mineq_expensive;



                self.state.nFeasPoints=0;
            end


            self.initSurrogateData();


            self.globalBest=self.incumbent;


            self.trialData=globaloptim.bmo.surrogates.SurrogateData(...
            {self.varName,self.problem.nvar},...
            self.dataStoreArgs,self.options);


            if self.problem.nobj_expensive>0
                self.state.obj_field=self.expensiveModel_response{1};
            elseif self.problem.nobj_cheap>0
                self.state.obj_field=self.cheapModel_response{1};
            end


            self.state.phase=2;



            self.updateIterationData();

        end


        function initIncumbent(self)



            nvar=self.problem.nvar;
            mIneq_nonlin=self.problem.mineq_cheap+self.problem.mineq_expensive;
            nobj_all=self.problem.nobj_cheap+self.problem.nobj_expensive;

            self.incumbent.(self.varName)=nan(1,nvar);
            if mIneq_nonlin==0
                self.incumbent.ineq=[];
                self.incumbent.constrviolation=0;
                self.incumbent.numInfeas=0;
            else
                self.incumbent.ineq=inf(1,mIneq_nonlin);
                self.incumbent.constrviolation=Inf;
                self.incumbent.numInfeas=Inf;
            end

            if nobj_all>0
                self.incumbent.fval=inf(1,nobj_all);
            end

            self.state.surrogateReset=false;


            self.state.phase=2;

        end


        function resetSearch(self)


            self.TrialMgr.makeActiveTrialsObsolete();
            self.initIncumbent();
            self.AdaptiveSampler.reset();

            if self.options.UseRandomPointsAfterReset

                self.addOldDataInSurrogates(2);

            else

                self.initSurrogateData();

            end

            if~isempty(self.problem.Aineq)||~isempty(self.problem.Aeq)
                self.state.random_sample_size=1;
            else
                self.state.random_sample_size=self.options.MinSurrogatePoints;
            end

            self.state.notify_model_about_restart=true;
            self.state.surrogateResetCntr(end+1)=self.trialData.getEvalCount();


            self.state.surrogateUpdateCntr=self.surrogateData.getEvalCount();



            self.state.numPointsBeforeAdaptivePhase=self.options.MinSurrogatePoints+...
            self.surrogateData.getEvalCount();

        end


        function addOldDataInSurrogates(self,type_no)

            type=self.surrogateData.getValue([],'type');

            id_no=ismember(type,type_no);

            id_keep=id_no|type==0;
            reset_fieldnames={'flag','type','elapsedtime',self.varName};

            if self.problem.nobj_expensive>0
                reset_fieldnames{end+1}=self.expensiveModel_response{1};
            end

            if self.problem.mineq_expensive>0
                reset_fieldnames{end+1}=self.expensiveModel_response{2};
            end

            self.surrogateData=self.surrogateData.setValue(~id_keep,reset_fieldnames,[]);

            type=self.surrogateData.getValue([],'type');

            dataIndex=ismember(type,type_no);

            self.surrogates.fit(self.surrogateData,dataIndex,true);
        end


        function initSurrogateData(self)


            self.surrogateData=globaloptim.bmo.surrogates.SurrogateData(...
            {self.varName,self.problem.nvar},...
            self.dataStoreArgs,self.options);
        end


        function setSurrogatesAndAdaptiveSampler(self,input)

            if~(self.state.init_eval_OK)

                error(message('globaloptim:bmo:initEvaluationNotOK'));
            end

            self.setSurrogates(input);
            self.setAdaptiveSampler(input);
        end


        function setSurrogates(self,input)


            self.options.surrogateOK=false;

            if~isfield(input,'Surrogate')||isempty(input.Surrogate)
                self.surrogates=globaloptim.bmo.surrogates.RBFInterpolant(...
                self.problem,self.options);
            elseif isfield(input,'Surrogate')&&ischar(input.Surrogate)


                self.surrogates=feval(input.Surrogate,self.problem,self.options);

            elseif isfield(input,'Surrogate')&&isa(input.Surrogate,'function_handle')
                self.surrogates=feval(input.Surrogate);
            elseif isa(input.Surrogate,'APIs.SurrogateFitter')

                self.surrogates=input.Surrogate;
            else

                error(message('globaloptim:bmo:invalidSurrogateChoice'));
            end
            self.options.surrogateOK=true;
            self.MinNumPoints=self.surrogates.getMinNumPoints();
        end


        function setAdaptiveSampler(self,input)

            if~isfield(input,'AdaptiveSampler')||...
                (ischar(input.AdaptiveSampler)&&...
                strcmp(input.AdaptiveSampler,self.defaultAdaptiveSampler)||...
                strcmpi(input.AdaptiveSampler,'random')||...
                strcmpi(input.AdaptiveSampler,'auto'))

                self.AdaptiveSampler=...
                globaloptim.bmo.optimizer.SurrogateAdaptiveTrial(self.problem,...
                self.options,self.TrialMgr);

            elseif ischar(input.AdaptiveSampler)
                self.AdaptiveSampler=feval(input.AdaptiveSampler,...
                self.problem,self.options,self.TrialMgr);

            else

                error(message('globaloptim:bmo:invalidAdaptiveSamplerChoice'));
            end

        end


        function setRandomSampler(self,input)


            if~isfield(input,'RandomSampler')
                self.RandomSampler=globaloptim.bmo.doe.SpaceFillingDesign(...
                self.problem,self.options,self.TrialMgr);

            elseif ischar(input.RandomSampler)

                self.RandomSampler=feval(input.RandomSampler,self.problem,self.options,self.TrialMgr);
            else

                error(message('globaloptim:bmo:invalidRandomSamplerChoice'));
            end

        end


        function createNewTrial(self)


            if self.state.phase>=3
                if self.useAllTrialDataForDistance
                    AllData=self.trialData;
                else
                    AllData=self.surrogateData;
                end


                X=self.AdaptiveSampler.proposeEvaluations(AllData,...
                self.surrogates,self.incumbent);

                if~isempty(X)



                    self.TrialMgr.addTrial(X,'adaptive');
                    return;
                end
            end



            if self.state.phase>=1

                nPts=self.state.random_sample_size;
                AllData=self.trialData;
                X=self.RandomSampler.generateDesign(nPts,AllData);




                if self.state.random_sample_size>1
                    self.state.random_sample_size=1;
                end

                if~isempty(X)


                    self.TrialMgr.addTrial(X,'random');
                end

            end

        end


        function updateIterationData(self)


            tids=self.TrialMgr.getEvaluatedTrialTIDs();
            trials_evaluated=self.TrialMgr.getEvaluated(tids);

            if isempty(trials_evaluated)

                return;
            end


            if self.problem.nobj_expensive>0&&...
                size(vertcat(trials_evaluated.(self.expensiveModel_response{1})),2)~=self.problem.nobj_expensive
                return;
            end
            if self.problem.mineq_expensive>0&&...
                size(vertcat(trials_evaluated.(self.expensiveModel_response{2})),2)~=self.problem.mineq_expensive
                return;
            end


            self.updateSurrogates(trials_evaluated);



            self.updateIncumbentAndCurrent(trials_evaluated);


            self.updateTrialData(trials_evaluated)


            self.TrialMgr.removeTrial(tids);

        end


        function incumbent_improved=updateIncumbentAndCurrent(self,...
            new_trials)



            tolCon=self.options.ConstraintTolerance;
            incumbent_improved=false;

            for ii=1:numel(new_trials)
                this_trial=new_trials(ii);

                if this_trial.obsolete


                    [self.current,infeas_improved,feas_improved]=...
                    self.qualifyTrial(self.globalBest,this_trial,tolCon);
                    if feas_improved||infeas_improved
                        self.globalBest=self.current;
                        self.state.globalBestChangeCntr(end+1)=...
                        self.trialData.getEvalCount()+ii;
                    end
                    continue;
                end

                [self.current,infeas_improved,feas_improved]=...
                self.qualifyTrial(self.incumbent,this_trial,tolCon);


                if self.state.phase>=3
                    self.AdaptiveSampler.updateSolverData(self.incumbent,...
                    self.current,infeas_improved,feas_improved);


                    self.state.surrogateReset=self.AdaptiveSampler.state.surrogateReset;
                end


                if feas_improved||infeas_improved&&~this_trial.failed

                    self.incumbent=self.current;
                    incumbent_improved=true;
                    self.state.incumbentChangeCntr(end+1)=...
                    self.trialData.getEvalCount()+ii;


                    if compareTrials(self.globalBest,self.incumbent,tolCon)
                        self.globalBest=self.incumbent;
                        self.state.globalBestChangeCntr(end+1)=...
                        self.trialData.getEvalCount()+ii;
                    end

                end

            end

        end


        function updateSurrogates(self,new_trials)





            exclude_trials=[new_trials.obsolete]|[new_trials.failed];
            surr_trials=new_trials(~exclude_trials);

            if isempty(surr_trials)

                return;
            end


            start=self.surrogateData.getEvalCount()+1;
            last=numel(surr_trials)+start-1;

            inital_type=arrayfun(@(x)strcmp(x.flag,'initial'),surr_trials);
            random_type=arrayfun(@(x)strcmp(x.flag,'random'),surr_trials);
            adaptive_type=arrayfun(@(x)strcmp(x.flag,'adaptive'),surr_trials);

            point_type=zeros(last-start+1,1);
            point_type(random_type)=2;
            point_type(adaptive_type)=3;
            point_type(inital_type)=1;

            self.surrogateData=self.surrogateData.setValue(start:last,...
            {'type'},{point_type});
            self.surrogateData=self.surrogateData.setValue(start:last,{'flag'},...
            {{surr_trials.flag}'});
            self.surrogateData=self.surrogateData.setValue(start:last,{'elapsedtime'},...
            {self.state.elapsedtime});

            newX=vertcat(surr_trials.(self.varName));
            self.surrogateData=self.surrogateData.setValue(start:last,...
            {self.varName},{newX});

            if self.problem.nobj_expensive>0
                newF=vertcat(surr_trials.(self.expensiveModel_response{1}));
                self.surrogateData=self.surrogateData.setValue(start:last,...
                self.expensiveModel_response(1),{newF});
            end

            if self.problem.mineq_expensive>0
                newIneq=vertcat(surr_trials.(self.expensiveModel_response{2}));
                self.surrogateData=self.surrogateData.setValue(start:last,...
                self.expensiveModel_response(2),{newIneq});
            end


            buffer=self.surrogateData.getEvalCount()-...
            self.state.surrogateUpdateCntr;
            if buffer<self.options.BatchUpdateInterval
                return;
            end

            if self.state.phase>=3
                start=self.state.surrogateUpdateCntr+1;
                last=self.surrogateData.getEvalCount();


                self.surrogates.update(self.surrogateData,start:last);

                self.state.surrogateUpdateCntr=self.surrogateData.getEvalCount();
            end



            if self.state.phase==2



                minPointsForPhase3=max(self.MinNumPoints,...
                self.options.MinSurrogatePoints);




                minPointsForPhase3=max(minPointsForPhase3,self.state.numPointsBeforeAdaptivePhase);

                if(self.surrogateData.getEvalCount()>=minPointsForPhase3)

                    self.surrogates.fit(self.surrogateData);

                    self.state.surrogateUpdateCntr=self.surrogateData.getEvalCount();
                    if self.surrogates.fitOK

                        self.state.phase=3;
                    elseif self.state.Verbosity>=4
                        fprintf('Surrogate fit failed.\n');
                    end
                end
            end

        end


        function updateTrialData(self,new_trials)


            newX=vertcat(new_trials.(self.varName));
            start=self.trialData.getEvalCount()+1;
            last=numel(new_trials)+start-1;

            initial_type=arrayfun(@(x)strcmp(x.flag,'initial'),new_trials);
            random_type=arrayfun(@(x)strcmp(x.flag,'random'),new_trials);
            adaptive_type=arrayfun(@(x)strcmp(x.flag,'adaptive'),new_trials);

            point_type=zeros(last-start+1,1);
            point_type(random_type)=2;
            point_type(adaptive_type)=3;
            point_type(initial_type)=1;
            self.trialData=self.trialData.setValue(start:last,...
            {'type'},{point_type});

            self.trialData=self.trialData.setValue(start:last,...
            {self.varName},{newX});
            self.trialData=self.trialData.setValue(start:last,...
            {'flag'},{{new_trials.flag}'});
            self.trialData=self.trialData.setValue(start:last,...
            {'elapsedtime'},{self.state.elapsedtime});

            if self.problem.nobj_expensive>0
                newF=vertcat(new_trials.(self.expensiveModel_response{1}));
                self.trialData=self.trialData.setValue(start:last,...
                self.expensiveModel_response(1),{newF});
            end
            if self.problem.mineq_expensive>0
                newIneq=vertcat(new_trials.(self.expensiveModel_response{2}));
                self.trialData=self.trialData.setValue(start:last,...
                self.expensiveModel_response(2),{newIneq});
            end

        end


        function[aTrial,infeas_improved,feas_improved]=...
            qualifyTrial(self,incumbent,this_trial,tolCon)



            [fval,ineq,feas,numInfeas]=self.response_combined(this_trial,tolCon);


            aTrial.(self.varName)=this_trial.(self.varName);
            aTrial.fval=fval;
            aTrial.ineq=ineq;
            aTrial.flag=this_trial.flag;
            aTrial.constrviolation=feas;
            aTrial.numInfeas=numInfeas;

            [infeas_improved,feas_improved]=...
            measureImprovementOverIncumbent(incumbent,aTrial,tolCon);
        end


        function[fval,ineq,feas,numInfeas]=response_combined(self,...
            this_trial,tolCon)



            ineq=[];
            fval=[];

            if isfield(this_trial,self.cheapModel_response{1})
                fval=[fval;this_trial.(self.cheapModel_response{1})(:)]';
            end

            if isfield(this_trial,self.expensiveModel_response{1})
                fval=[fval;this_trial.(self.expensiveModel_response{1})(:)]';
            end

            if isfield(this_trial,self.cheapModel_response{2})
                ineq=[ineq;this_trial.(self.cheapModel_response{2})(:)]';
            end

            if isfield(this_trial,self.expensiveModel_response{2})
                ineq=[ineq;this_trial.(self.expensiveModel_response{2})(:)]';
            end

            if~isempty(ineq)
                if~this_trial.failed
                    feas=max(ineq);
                else
                    feas=Inf;
                end
                numInfeas=sum(ineq>tolCon);
                if feas<=tolCon
                    self.state.nFeasPoints=self.state.nFeasPoints+1;
                end
            else
                feas=0.0;
                numInfeas=0;
            end

        end


        function aTrial=failedTrial(self,this_trial)


            [fval,ineq,feas,numInfeas]=self.response_combined(this_trial,Inf);

            aTrial.(self.varName)=this_trial.(self.varName);
            aTrial.fval=fval;
            aTrial.ineq=ineq;
            aTrial.flag=this_trial.flag;
            aTrial.constrviolation=feas;
            aTrial.numInfeas=numInfeas;
        end


        function assertSingleObjective(self)


            nObj=self.problem.nobj_cheap+self.problem.nobj_expensive;
            if~(nObj<=1)
                error(message('globaloptim:bmo:NonScalarObj'))
            end


            obj_ineq=nObj+self.problem.mineq_expensive;
            if obj_ineq==0
                error(message('globaloptim:surrogateopt:needObjOrConstr'));
            end


        end

    end
end


function TF=compareTrials(incumbent,current,tolCon)


    [infeas_improved,feas_improved]=...
    measureImprovementOverIncumbent(incumbent,current,tolCon);

    TF=infeas_improved||feas_improved;
end



function[infeas_improved,feas_improved]=...
    measureImprovementOverIncumbent(incumbent,current,tolCon)



    if incumbent.constrviolation<=tolCon




        feas_improved=...
        current.constrviolation<=tolCon&&all(current.fval<incumbent.fval);
        infeas_improved=false;
    else


        max_violation_improved=current.constrviolation<incumbent.constrviolation;

        max_violation_delta_acceptable=...
        (current.constrviolation-incumbent.constrviolation)<=eps;
        numInfeas_improved=current.numInfeas<incumbent.numInfeas&&...
        max_violation_delta_acceptable;
        infeas_improved=max_violation_improved||numInfeas_improved;
        feas_improved=false;
    end
end


function[current,incumbent,globalBest]=initTrialPoints(varName)

    current=struct(varName,[],...
    'fval',[],...
    'ineq',[],...
    'flag','',...
    'constrviolation',Inf,...
    'numInfeas',Inf);

    incumbent=current;

    globalBest=current;
end


function output=getPastMetrics(self,input)

    [current,incumbent,output]=initTrialPoints(self.varName);

    output.current=current;
    output.incumbent=incumbent;
    output.surrogateReset=false;
    output.id=input.id;
    output.retcode=1;
    output.message='metrics from past';
    output.exitflag=self.state.exitflag;
    output.surrogateResetCount=0;
    output.checkpointResumeCount=0;
    output.checkpointResume=false;
    output.elapsedtime=toc(self.startTime);
    output.nFeasPoints=self.state.nFeasPoints;

    tolCon=self.options.ConstraintTolerance;
    nPoints=self.trialData.getEvalCount();
    if input.iter<1||input.iter>nPoints
        return;
    end
    trialData=self.trialData;

    current.fval=trialData.getValue(input.iter,self.expensiveModel_response{1});
    current.ineq=trialData.getValue(input.iter,self.expensiveModel_response{2});
    current.(self.varName)=trialData.getValue(input.iter,self.varName);
    current.flag=trialData.getValue(input.iter,'flag');current.flag=current.flag{:};

    if~isempty(current.ineq)
        current.constrviolation=max(current.ineq);
        current.numInfeas=sum(current.ineq>tolCon);
    else
        current.constrviolation=0;
        current.numInfeas=0;
    end


    ID=find(self.state.incumbentChangeCntr<=input.iter,1,'last');
    if~isempty(ID)

        ID=self.state.incumbentChangeCntr(ID);
        incumbent.fval=trialData.getValue(ID,self.expensiveModel_response{1});
        incumbent.ineq=trialData.getValue(ID,self.expensiveModel_response{2});
        incumbent.(self.varName)=trialData.getValue(ID,self.varName);
        incumbent.flag=trialData.getValue(ID,'flag');incumbent.flag=incumbent.flag{:};
    end

    if~isempty(incumbent.ineq)
        incumbent.constrviolation=max(incumbent.ineq);
        incumbent.numInfeas=sum(incumbent.ineq>tolCon);
    else
        incumbent.constrviolation=0;
        incumbent.numInfeas=0;
    end

    ID=find(self.state.globalBestChangeCntr<=input.iter,1,'last');
    if~isempty(ID)

        ID=self.state.globalBestChangeCntr(ID);
        output.fval=trialData.getValue(ID,self.expensiveModel_response{1});
        output.ineq=trialData.getValue(ID,self.expensiveModel_response{2});
        output.(self.varName)=trialData.getValue(ID,self.varName);
        output.flag=trialData.getValue(ID,'flag');output.flag=output.flag{:};
    end

    if~isempty(output.ineq)
        output.constrviolation=max(output.ineq);
        output.numInfeas=sum(output.ineq>tolCon);
    else
        output.constrviolation=0;
        output.numInfeas=0;
    end

    output.elapsedtime=trialData.getValue(input.iter,'elapsedtime');

    output.surrogateReset=any(self.state.surrogateResetCntr==input.iter);
    output.surrogateResetCount=nnz(self.state.surrogateResetCntr<=input.iter);

    output.checkpointResume=any(self.state.checkpointResumeCntr==input.iter);
    output.checkpointResumeCount=nnz(self.state.checkpointResumeCntr<=input.iter);

    output.current=current;
    output.incumbent=incumbent;

end

function xout=unfixVariables(xin,fixedVarInfo)

    xout=zeros(size(xin,1),numel(fixedVarInfo.fixedVarIndex));
    xout(:,~fixedVarInfo.fixedVarIndex)=xin;
    xout(:,fixedVarInfo.fixedVarIndex)=repmat(fixedVarInfo.fixedValues,size(xin,1),1);
end

