function self=createSolver(self,expensive,lb,ub,intcon,Aineq,bineq,Aeq,beq,options)

    self.state.startTime=tic;

    expensiveModel_response={'Fval','Ineq','Stop'};
    cheapModel_response={'CheapFval','CheapIneq'};

    if~all(isfield(expensive,{'model','response'}))
        error(message('globaloptim:surrogateopt:modelInvalidStruct'))
    end

    if numel(expensive)~=1
        error(message('globaloptim:surrogateopt:modelStructNotScalar'))
    end

    if~(all(ismember(expensive.response,expensiveModel_response)))

        error(message('globaloptim:surrogateopt:modelResponseNotValid'));
    end

    if~isa(expensive.model,'function_handle')

        error(message('globaloptim:surrogateopt:modelNotAFunctionHandle'));
    end

    if ismember(expensiveModel_response{2},expensive.response)
        input.expensiveconstr=true;
    end
    if ismember(expensiveModel_response{1},expensive.response)
        input.expensiveobj=true;
    end

    input.lb=lb;
    input.ub=ub;
    input.intcon=intcon;
    input.Aineq=Aineq;
    input.bineq=bineq;
    input.Aeq=Aeq;
    input.beq=beq;
    [input,self.state.msg]=globaloptim.bmo.verifybounds(input,options);

    nvars=numel(ub);
    opts=globaloptim.bmo.parseSurrogateopt(options,nvars);
    self=self.copyOptions(opts);
    self.options=opts;
    self.info.nvars=nvars;
    self.info.nInt=0;
    self.info.mLinIneq=size(Aineq,1);
    self.info.mLinEq=size(Aeq,1);

    if~isempty(self.state.msg)
        self.state.exitflag=self.EFLAG_LINEAR_INFEAS;
        return;
    end

    self.expensive=expensive;
    self.modelMgr=globaloptim.bmo.ModelManager(self.expensive,self.options,...
    self.options.Verbosity);

    options=self.options;
    options.solver='surrogate-single-obj';
    options.setup=true;

    options.boundsVerified=true;
    self.solverRef=globaloptim.bmo.solver(options);
    if~isfield(self.solverRef,'id')
        error(message('globaloptim:surrogateopt:SurrogateSolverInitFailed.'));
    end
    self.trialRequest=struct('id',self.solverRef.id,'request',true,...
    'trial',[]);
    self.statusRequest=struct('id',self.solverRef.id,'request',true,...
    'metrics',true);
    self.resultsRequest=struct('id',self.solverRef.id,'request',true,...
    'results',true);

    if~isempty(options.CheckpointFile)
        self.saveRequest=struct('id',self.solverRef.id,'request',true,...
        'save',true);
    end

    input.id=self.solverRef.id;
    input.setup=true;
    self.info.nInt=numel(unique(intcon));

    if isfield(self.options,'CheapConstraint')
        input.constrfun=options.CheapConstraint;
    else
        input.constrfun=[];
    end
    if isfield(self.options,'CheapObjective')
        input.objfun=options.CheapObjective;
    else
        input.objfun=[];
    end
    input=checkInitialPoints(self.varName,nvars,options,input,expensive,...
    expensiveModel_response,cheapModel_response);
    self.solverRef=globaloptim.bmo.solver(input);
    self.solverStatus=globaloptim.bmo.solver(self.statusRequest);
    if~isempty(self.solverStatus.exitflag)
        self.state.exitflag=self.solverStatus.exitflag;
        self.results.(self.varName)=self.solverStatus.(self.varName);
        if self.state.exitflag==self.EFLAG_FIXED
            self.state.msg=getString(message('globaloptim:surrogateopt:EqualBounds'));
        end
    end

end


function input=checkInitialPoints(varName,nvars,options,input,expensive,...
    expensiveModel_response,cheapModel_response)

    initialPoints=options.InitialPoints;

    if isstruct(initialPoints)

        if~isfield(initialPoints,varName)
            error(message('globaloptim:surrogateopt:InitPointStructNoXField',varName));
        end
        input.(varName)=initialPoints.(varName);

        if~isempty(input.(varName))

            input.ntrials=numel(input.(varName))/nvars;
            if~(input.ntrials==round(input.ntrials))
                error(message('globaloptim:surrogateopt:InitPointStructNumXColsInconsistent',...
                varName,nvars));
            end
            id_=isnan(input.(varName))|~isfinite(input.(varName));
            if any(id_)
                error(message('globaloptim:surrogateopt:InitPointsNotReal'));
            end
        end

        if~isempty(input.(varName))&&...
            ~isempty(setdiff(fieldnames(initialPoints),{varName}))

            response='X';
            fname=expensiveModel_response{1};
            if ismember(fname,expensive.response)
                fval_expensive_in=isfield(initialPoints,fname)&&...
                ~isempty(initialPoints.(fname));
                input.expensiveobj=true;
                response=strip([response,' ',fname]);
            else
                fval_expensive_in=true;
            end
            fname=expensiveModel_response{2};
            if ismember(fname,expensive.response)
                ineq_expensive_in=isfield(initialPoints,fname)&&...
                ~isempty(initialPoints.(fname));
                input.expensiveconstr=true;
                response=strip([response,' ',fname]);
            else
                ineq_expensive_in=true;
            end

            if~isempty(input.objfun)
                fname=cheapModel_response{1};
                cheapFval_in=isfield(initialPoints,fname)&&...
                ~isempty(initialPoints.(fname));
                response=strip([response,' ',fname]);
            else
                cheapFval_in=true;
            end

            if~isempty(input.constrfun)
                fname=cheapModel_response{2};
                cheapIneq_in=isfield(initialPoints,fname)&&...
                ~isempty(initialPoints.(fname));
                response=strip([response,' ',fname]);
            else
                cheapIneq_in=true;
            end

            response_ok=(fval_expensive_in||ineq_expensive_in)&&...
            cheapIneq_in&&cheapFval_in;

            if~response_ok
                error(message('globaloptim:surrogateopt:InitPointStructMissingFields',response))
            end

            fnames=[expensiveModel_response,cheapModel_response];
            for ii=1:length(fnames)
                if isfield(initialPoints,fnames{ii})
                    if size(initialPoints.(fnames{ii}),1)~=input.ntrials
                        error(message('globaloptim:surrogateopt:InitPointStructNumResponseRowsInconsistent',...
                        fnames{ii},input.ntrials));
                    end
                    input.(fnames{ii})=initialPoints.(fnames{ii});
                end
            end
        end
    elseif~isempty(initialPoints)

        input.(varName)=initialPoints;
        input.ntrials=numel(input.(varName))/nvars;

        if~(input.ntrials==round(input.ntrials))
            error(message('globaloptim:surrogateopt:InitPointNumColsInconsistent',nvars));
        end
    end
    if~(~xor(input.expensiveobj,isempty(input.objfun)))
        error(message('globaloptim:surrogateopt:NoObjectiveFunction'))
    end
    if~(input.expensiveobj||input.expensiveconstr)
        error(message('globaloptim:surrogateopt:NoExpensiveFunction'))
    end
end
