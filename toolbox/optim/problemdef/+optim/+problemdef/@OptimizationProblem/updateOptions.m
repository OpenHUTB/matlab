function probStruct=updateOptions(prob,probStruct)











    options=probStruct.options;




    if isa(options,'optim.options.SolverOptions')
        options=convertForSolver(options,probStruct.solver);
    end


    switch probStruct.solver
    case "fmincon"
        options=setSolverGradientOptionsForAD(prob,options,probStruct,'GradObj');
        options=setSolverGradientOptionsForAD(prob,options,probStruct,'GradConstr');
    case "fminunc"
        options=setSolverGradientOptionsForAD(prob,options,probStruct,'GradObj');
    case "lsqnonlin"
        options=setSolverGradientOptionsForAD(prob,options,probStruct,'Jacobian');
    end








    hybridFcnSet=(isfield(options,'HybridFcn')||...
    any(strcmpi(properties(options),'HybridFcn')))&&...
    ~isempty(options.HybridFcn);
    if hybridFcnSet
        options=setHybridOptions(prob,probStruct,options);
    end


    if~isfield(probStruct,'SolveSetInitialX')||~probStruct.SolveSetInitialX
        options=updateIgnoredInitialX(options,probStruct.solver);
    end


    if~isfield(probStruct,'SolveSetInitialObjConVals')||~probStruct.SolveSetInitialObjConVals
        options=updateIgnoredInitialObjConVals(options,probStruct.solver);
    end


    options=updateIgnoredOption(options,probStruct.solver,...
    {'ga','gamultiobj'},'PopulationType','PopulationType');
    options=updateIgnoredOption(options,probStruct.solver,...
    'simulannealbnd','DataType','DataType');
    vectorizedSolvers={'ga','gamultiobj',...
    'particleswarm','patternsearch'};
    options=updateIgnoredOption(options,probStruct.solver,...
    vectorizedSolvers,'UseVectorized','Vectorized');
    useVectorizedSolvers={'paretosearch','surrogateopt'};
    options=updateIgnoredOption(options,probStruct.solver,...
    useVectorizedSolvers,'UseVectorized','UseVectorized');



    probStruct.options=options;

end

function options=setHybridOptions(prob,probStruct,options)




    if iscell(options.HybridFcn)
        hybridSolver=options.HybridFcn{1};
        hybridOptions=options.HybridFcn{2};
    else
        hybridSolver=options.HybridFcn;
        if isa(options.HybridFcn,'function_handle')
            hybridSolverName=func2str(options.HybridFcn);
        else
            hybridSolverName=hybridSolver;
        end
        if strcmpi(hybridSolverName,'fminsearch')
            hybridOptions=optimset('fminsearch');
            hybridOptions.Display='none';
        else
            hybridOptions=optimoptions(hybridSolver,'Display','none');
        end
    end


    if~isa(hybridSolver,'function_handle')
        hybridSolver=str2func(hybridSolver);
    end


    hybridSolverName=func2str(hybridSolver);




    if any(strcmp(hybridSolverName,{'fmincon','fminunc'}))
        if isOptionSet(hybridOptions,'GradObj')
            hybridProbStruct.setByUserOptions={'GradObj'};
        else
            hybridProbStruct.setByUserOptions={};
        end
        hybridProbStruct.objectiveDerivative=probStruct.objectiveDerivative;
        hybridOptions=setSolverGradientOptionsForAD(prob,hybridOptions,hybridProbStruct,'GradObj');
    end


    hasConstraints=~isempty(prob.Constraints)||...
    (~isempty(prob.Constraints)&&isstruct(prob.Constraints)&&...
    ~all(structfun(@isempty,prob.Constraints)));
    if hasConstraints&&strcmp(hybridSolverName,'fmincon')
        if isOptionSet(hybridOptions,'GradConstr')
            hybridProbStruct.setByUserOptions={'GradConstr'};
        else
            hybridProbStruct.setByUserOptions={};
        end
        hybridProbStruct.constraintDerivative=probStruct.constraintDerivative;
        hybridOptions=setSolverGradientOptionsForAD(prob,hybridOptions,hybridProbStruct,'GradConstr');
    end


    options.HybridFcn={hybridSolver,hybridOptions};

end

function options=updateIgnoredInitialX(options,solver)

    initialXName='';
    switch solver
    case{'ga','gamultiobj'}
        initialXName='InitialPopulationMatrix';
        initialXAlias='InitialPopulation';
    case{'paretosearch','surrogateopt'}
        initialXName='InitialPoints';
        initialXAlias='InitialPoints';
    case 'particleswarm'
        initialXName='InitialSwarmMatrix';
        initialXAlias='InitialSwarm';
    end

    if~isempty(initialXName)&&isOptionSet(options,initialXAlias)

        [options,displayName]=resetOptionAndGetDisplayName(options,...
        initialXName,initialXAlias);


        warnStr=getString(message('optim_problemdef:OptimizationProblem:solve:InitialObjConValsIgnored',displayName));
        warning('optim_problemdef:OptimizationProblem:solve:InitialXIgnored',warnStr);

    end

end

function options=updateIgnoredInitialObjConVals(options,solver)

    initialName='';
    switch solver
    case{'ga','gamultiobj'}
        initialName='InitialScoresMatrix';
        aliasName='InitialScores';
        isSet=isOptionSet(options,aliasName);
    case{'paretosearch','surrogateopt'}
        initialName='InitialPoints';
        aliasName='InitialPoints';
        isSet=isOptionSet(options,aliasName);


        isSet=isSet&&isstruct(options.InitialPoints)&&...
        ((isfield(options.InitialPoints,'Fval')&&~isempty(options.InitialPoints.Fval))||...
        (isfield(options.InitialPoints,'Ineq')&&~isempty(options.InitialPoints.Ineq)));
    end

    if~isempty(initialName)&&isSet

        [options,displayName]=resetOptionAndGetDisplayName(options,...
        initialName,aliasName);


        warning(message('optim_problemdef:OptimizationProblem:solve:InitialObjConValsIgnored',displayName));
    end

end

function options=updateIgnoredOption(options,solver,affectedSolvers,optionName,aliasName)

    if any(strcmp(solver,affectedSolvers))&&isOptionSet(options,aliasName)

        [options,displayName]=resetOptionAndGetDisplayName(options,...
        optionName,aliasName);


        warning(message('optim_problemdef:OptimizationProblem:solve:IgnoredOption',displayName));
    end

end

function isSet=isOptionSet(options,name)

    isOptimOptions=isa(options,"optim.options.SolverOptions");
    isSet=(isOptimOptions&&isSetByUser(options,name))||...
    (isstruct(options)&&isfield(options,name)&&~isempty(options.(name)));

end

function[options,displayName]=resetOptionAndGetDisplayName(options,optionName,aliasName)

    if isa(options,"optim.options.SolverOptions")
        displayName=optionName;
        options=resetoptions(options,optionName);
    else
        displayName=aliasName;

        options=rmfield(options,aliasName);
    end

end
