function[sol,varargout]=solveImpl(prob,varargin)



























































    if isempty(prob.Variables)
        errId='optim_problemdef:OptimizationProblem:solve:EmptyProblem';
        ME=MException(errId,getString(message(errId)));
        throwAsCaller(ME);
    end



    if isMultiObjective(prob)
        [VariableNames,ObjectiveNames,ConstraintNames]=getQuantityNames(prob);
        allNames=[VariableNames;ObjectiveNames;ConstraintNames];
        [~,idxInAllNames]=unique(allNames);
        idxDupNames=setdiff(1:numel(allNames),idxInAllNames);
        if~isempty(idxDupNames)
            errId='optim_problemdef:OptimizationProblem:solve:DuplicateLabelsMultiObjective';
            dupNamesStr=strjoin(unique(allNames(idxDupNames)),', ');
            ME=MException(errId,getString(message(errId,dupNamesStr)));
            throwAsCaller(ME);
        end
    end


    [x0,solverName,options,objectiveDerivative,constraintDerivative,...
    userSpecifiedObjectiveGradients,userSpecifiedConstraintGradients,...
    globalSolver,minNumStartPoints]=iParseInputs(prob,varargin{:});


    inMemory=true;

    prob.GeneratedFileFolder="probID"+replace(matlab.lang.internal.uuid(),"-","0");

    useParallel=checkUseParallel(options,globalSolver);



    filepath=prob.GeneratedFileFolder;


    objectiveFcnName="generated"+prob.ObjectivePtyName;
    constraintFcnName="generated"+prob.ConstraintPtyName;
    [probStruct,useParallel]=prob2structImpl(prob,'solve',x0,options,inMemory,...
    useParallel,objectiveFcnName,constraintFcnName,filepath,...
    objectiveDerivative,constraintDerivative,solverName,globalSolver);


    probStruct=updateOptions(prob,probStruct);



    probStruct.userSpecifiedObjectiveGradients=userSpecifiedObjectiveGradients;
    probStruct.userSpecifiedConstraintGradients=userSpecifiedConstraintGradients;


    pdOpts=prob.ProblemdefOptions;
    pdOpts.FromSolve=true;
    if isempty(probStruct.options)&&any(strcmp(probStruct.solver,{'intlinprog','coneprog'}))


        probStruct.options=setProblemdefOptions(optimoptions(probStruct.solver),pdOpts);
    elseif isempty(probStruct.options)||isstruct(probStruct.options)

        probStruct.options.ProblemdefOptions=pdOpts;
    else

        probStruct.options=setProblemdefOptions(probStruct.options,pdOpts);
    end


    clearVFS=onCleanup(@()optim.internal.problemdef.clearoptiminmem(prob.GeneratedFileFolder));
    if~useParallel
        clearVFSWorkers=onCleanup.empty;
        cleanupWorkers=onCleanup.empty;
    else
        pool=gcp;
        if~isempty(pool)
            if isa(pool,'parallel.ThreadPool')




                if isfield(probStruct,'objective')
                    probStruct.FcnHandleForWorkers.funfcn=probStruct.objective;
                elseif isfield(probStruct,'fitnessfcn')
                    probStruct.FcnHandleForWorkers.funfcn=probStruct.fitnessfcn;
                end
                if isfield(probStruct,'nonlcon')
                    probStruct.FcnHandleForWorkers.confcn=probStruct.nonlcon;
                end

                clearVFSWorkers=onCleanup.empty;
            else



                if isempty(probStruct.FcnHandleForWorkers.funfcn)



                    if isfield(probStruct,'objective')
                        probStruct.FcnHandleForWorkers.funfcn=probStruct.objective;
                    elseif isfield(probStruct,'fitnessfcn')
                        probStruct.FcnHandleForWorkers.funfcn=probStruct.fitnessfcn;
                    end
                end
                if isempty(probStruct.FcnHandleForWorkers.confcn)&&isfield(probStruct,'nonlcon')



                    probStruct.FcnHandleForWorkers.confcn=probStruct.nonlcon;
                end
                clearVFSWorkers=onCleanup(@()parfeval(@optim.internal.problemdef.clearoptiminmem,0,prob.GeneratedFileFolder));
            end
        else

            clearVFSWorkers=onCleanup.empty;
        end


        if~probStruct.derivativeFreeSolver&&~startsWith(probStruct.objectiveDerivative,'finite-diff')
            funfcnWorker={'fungrad',{},probStruct.FcnHandleForWorkers.funfcn,probStruct.FcnHandleForWorkers.funfcn};
        else
            funfcnWorker={'fun',{},probStruct.FcnHandleForWorkers.funfcn};
        end
        if strcmp(probStruct.solver,'fmincon')&&~startsWith(probStruct.constraintDerivative,'finite-diff')
            confcnWorker={'fungrad',{},probStruct.FcnHandleForWorkers.confcn,probStruct.FcnHandleForWorkers.confcn};
        else
            confcnWorker={'fun',{},probStruct.FcnHandleForWorkers.confcn};
        end
        cleanupWorkers=setOptimFcnHandleOnWorkers(true,funfcnWorker,confcnWorker);


        fcnHandleForWorkers=probStruct.FcnHandleForWorkers;%#ok<NASGU> Do not delete!
    end
    probStruct=rmfield(probStruct,'FcnHandleForWorkers');


    try

        if optim.internal.problemdef.display.allowsDisplay(probStruct.options)
            if isempty(globalSolver)
                selectedSolver=probStruct.solver;
            else
                selectedSolver=class(globalSolver);
            end
            selectedSolverMsg=getString(message('optim_problemdef:ProblemImpl:solve:SolverSelected',selectedSolver));
            fprintf('\n%s\n',selectedSolverMsg);
        end

        probStruct.globalSolver=globalSolver;
        probStruct.minNumStartPoints=minNumStartPoints;

        [x,fval,exitflag,output,lambda]=callSolver(prob,probStruct);
    catch ME
        throwAsCaller(ME);
    end


    delete(clearVFS);
    delete(clearVFSWorkers);
    delete(cleanupWorkers);

    [sol,varargout{1:nargout-1}]=prob.mapSolverOutputs(x,fval,exitflag,output,...
    lambda,probStruct.solver,probStruct.globalSolver,varargin{:});

    function[x0,solverName,options,objectiveDerivative,constraintDerivative,...
        userSpecifiedObjectiveGradients,userSpecifiedConstraintGradients,...
        globalSolver,minNumStartPoints]=iParseInputs(prob,varargin)



        checkForIncorrectDerivativeOption(prob,varargin,"solve");

        defaultX0=[];
        defaultGlobalSolver=[];
        defaultOptions=[];
        defaultSolverName='';
        defaultDerivative="auto";
        defaultMinNumStartPoints=20;
        userSpecifiedObjectiveGradients=any(strcmpi(varargin,"ObjectiveDerivative"));
        userSpecifiedConstraintGradients=any(strcmpi(varargin,"ConstraintDerivative"));

        if nargin==1
            x0=defaultX0;
            solverName=defaultSolverName;
            options=defaultOptions;
            objectiveDerivative=defaultDerivative;
            constraintDerivative=defaultDerivative;
            globalSolver=defaultGlobalSolver;
            minNumStartPoints=defaultMinNumStartPoints;
            return;
        end



        objectiveSingular=regexprep(prob.ObjectivePtyName,'(\w*)s','$1');
        objectiveDerivativeName=objectiveSingular+"Derivative";

        p=inputParser;

        addOptional(p,'x0',defaultX0,@(s)validateX0(prob,s));
        if prob.SupportsGlobalSolvers
            addOptional(p,'GlobalSolver',defaultGlobalSolver,@(s)iValidateGlobalSolver(prob,s));
            addParameter(p,'MinNumStartPoints',defaultMinNumStartPoints,@(s)iValidateMinNumStartPoints(prob,s));
        end



        addParameter(p,'Solver',defaultSolverName,@(s)iValidateSolverName(prob,s));
        addParameter(p,'Options',defaultOptions,@(s)iValidateOptions(prob,s));
        addParameter(p,objectiveDerivativeName,defaultDerivative);
        addParameter(p,'ConstraintDerivative',defaultDerivative);

        try
            parse(p,varargin{:});

            x0=p.Results.x0;



            solverName=p.Results.Solver;
            if~isequal(solverName,defaultSolverName)
                solverName=validatestring(solverName,prob.getSupportedSolvers,'solve','Solver');
            end
            options=p.Results.Options;



            if prob.SupportsGlobalSolvers
                globalSolver=iValidateX0WithGlobalSolver(p.Results.GlobalSolver,x0);
                minNumStartPoints=p.Results.MinNumStartPoints;
            else
                globalSolver=defaultGlobalSolver;
                minNumStartPoints=defaultMinNumStartPoints;
            end



            objectiveDerivative=iValidateDerivative(prob,objectiveDerivativeName,p.Results.(objectiveDerivativeName));
            constraintDerivative=iValidateDerivative(prob,"ConstraintDerivative",p.Results.ConstraintDerivative);

        catch ME
            throwAsCaller(ME);
        end



        if optim.internal.utils.hasGlobalOptimizationToolbox
            noGradientSolvers=["ga"
"gamultiobj"
"paretosearch"
"particleswarm"
"patternsearch"
"simulannealbnd"
"surrogateopt"
            ];



            hybridFcnSet=(isfield(options,'HybridFcn')||any(strcmpi(properties(options),'HybridFcn')))&&...
            ~isempty(options.HybridFcn);
            if any(strcmpi(solverName,noGradientSolvers))&&~hybridFcnSet
                objectiveDerivative="finite-differences";
                constraintDerivative="finite-differences";
            end

        end

        function iValidateSolverName(prob,inputString)

            try
                validatestring(inputString,prob.getSupportedSolvers,'solve','Solver');
            catch
                if ischar(inputString)||isstring(inputString)
                    if any(strcmp(inputString,prob.SupportedGlobalSolvers))
                        error(prob.MessageCatalogID+':solve:NoGlobalLicense',...
                        getString(message('optim_problemdef:ProblemImpl:solve:NoGlobalLicense',inputString)));
                    else
                        error(prob.MessageCatalogID+':solve:InvalidSolver',...
                        getString(message('optim_problemdef:ProblemImpl:solve:InvalidSolver',inputString)));
                    end
                else
                    error(prob.MessageCatalogID+':solve:InvalidSolverNameInput',...
                    getString(message('optim_problemdef:ProblemImpl:solve:InvalidSolverNameInput')));
                end
            end

            function iValidateOptions(prob,options)

                if~(isstruct(options)||isa(options,'optim.options.SolverOptions'))
                    error(prob.MessageCatalogID+':solve:InvalidOptions',...
                    getString(message('optim_problemdef:ProblemImpl:solve:InvalidOptions')));
                end


                function updatedDerivative=iValidateDerivative(prob,optionName,inputString)



                    try
                        updatedDerivative=validatestring(inputString,prob.ValidDerivativeValues);
                    catch
                        errmsg=message('optim_problemdef:ProblemImpl:solve:InvalidDerivativeInput',...
                        optionName,createValidDerivativeList(prob));
                        error(prob.MessageCatalogID+':solve:InvalidDerivativeInput',getString(errmsg));
                    end


                    function iValidateGlobalSolver(prob,GlobalSolver)

                        if~isa(GlobalSolver,'globaloptim.internal.AbstractGlobalSolver')
                            error(prob.MessageCatalogID+':solve:InvalidGlobalSolver',...
                            getString(message('optim_problemdef:ProblemImpl:solve:InvalidGlobalSolver')));
                        elseif~optim.internal.utils.hasGlobalOptimizationToolbox
                            error(prob.MessageCatalogID+':solve:NoGlobalLicense',...
                            getString(message('optim_problemdef:ProblemImpl:solve:NoGlobalLicense',...
                            class(GlobalSolver))));
                        end

                        function globalSolver=iValidateX0WithGlobalSolver(globalSolver,x0)


                            if~isempty(globalSolver)
                                if isempty(x0)
                                    error('optim_problemdef:OptimizationProblem:solve:GlobalSolverRequiresX0',...
                                    getString(message('optim_problemdef:ProblemImpl:solve:GlobalSolverRequiresX0',class(globalSolver))));
                                elseif isa(globalSolver,"GlobalSearch")&&~isscalar(x0)
                                    error('optim_problemdef:OptimizationProblem:solve:GlobalSearchRequiresScalarX0',...
                                    getString(message('optim_problemdef:ProblemImpl:solve:GlobalSearchRequiresScalarX0')));
                                end
                            end

                            function iValidateMinNumStartPoints(prob,minNumX0)



                                try
                                    validateattributes(minNumX0,{'numeric'},{'scalar','integer','>',0});
                                catch
                                    errmsg=message('optim_problemdef:ProblemImpl:solve:InvalidMinNumStartPoints');
                                    error(prob.MessageCatalogID+':solve:InvalidMinNumStartPoints',getString(errmsg));
                                end



