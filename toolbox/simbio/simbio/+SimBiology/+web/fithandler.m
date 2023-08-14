function out=fithandler(action,varargin)











    out={};

    switch(action)
    case 'verifyWeightExpression'
        out=verifyWeightExpression(action,varargin{:});
    case 'getAdvancedOptions'
        out=getAdvancedOptions(varargin{1});
    case 'getAllOptimOptionProperties'
        out=getAllOptimOptionProperties(varargin{1});
    case 'getEstimatedParameters'
        out=getEstimatedParameters(varargin{1});
    case 'getEstimatedValues'
        out=getEstimatedValues(varargin{1});
    end

end

function out=getAdvancedOptions(input)

    algorithm=input.algorithm;
    optionNames={};
    switch(algorithm)
    case 'nlinfit'
        propsToExclude={'MaxIter','TolFun','TolX','Display','UseParallel'};
        allNames=fieldnames(statset);
        properties=setdiff(allNames,propsToExclude);
    case 'fminsearch'
        propsToExclude={'MaxIter','TolFun','TolX','Display','UseParallel'};
        allNames=fieldnames(optimset);
        properties=setdiff(allNames,propsToExclude);
        properties=properties';
    case{'lsqcurvefit','lsqnonlin','fminunc','fmincon'}
        propsToExclude={'Display','StepTolerance','FunctionTolerance','OptimalityTolerance','MaxIterations','UseParallel'};
        properties=getOptimOptionProperties(algorithm,propsToExclude);
    case 'patternsearch'
        propsToExclude={'Display','StepTolerance','FunctionTolerance','MaxIterations','UseParallel'};
        properties=getOptimOptionProperties(algorithm,propsToExclude);
    case 'ga'
        propsToExclude={'Display','FunctionTolerance','MaxGenerations','UseParallel'};
        properties=getOptimOptionProperties(algorithm,propsToExclude);
    case 'particleswarm'
        propsToExclude={'Display','FunctionTolerance','MaxIterations','UseParallel'};
        properties=getOptimOptionProperties(algorithm,propsToExclude);
    case 'scattersearch'
        properties={'CreateFcn','FractionInitialBest','InitialPointMatrix','LocalSearchInterval',...
        'LocalSelectBestProbability','MaxStallTime','ObjectiveLimit','OutputFcn','TrialStallLimit'};
    case 'nlmefit'
        optionNames={'DerivStep','FunValCheck','OutputFcn'};
        properties={optionNames{:},'CovParameterization','RefineBeta0'};%#ok<*CCAT>
    case 'nlmefitsa'
        optionNames={'DerivStep','FunValCheck','OutputFcn'};
        properties={optionNames{:},'Cov0','Replicates'};
    end

    out.Algorithm=algorithm;
    out.AdvancedOptions=sort(optionNames);
    out.AdvancedProperties=sort(properties);

end

function out=getOptimOptionProperties(algorithm,propsToExclude)
    allNames=getAllOptimOptionProperties(algorithm);
    out=setdiff(allNames,propsToExclude);
end

function allNames=getAllOptimOptionProperties(algorithm)

    switch algorithm
    case{'lsqcurvefit','lsqnonlin'}
        allNames={'CheckGradients','Display','FiniteDifferenceStepSize','FiniteDifferenceType','FunctionTolerance','JacobianMultiplyFcn','MaxFunctionEvaluations','MaxIterations','OptimalityTolerance','OutputFcn','PlotFcn','SpecifyObjectiveGradient','StepTolerance','SubproblemAlgorithm','TypicalX','UseParallel','Algorithm'};
    case 'fminunc'
        allNames={'CheckGradients','Display','FiniteDifferenceStepSize','FiniteDifferenceType','FunctionTolerance','HessianApproximation','HessianFcn','HessianMultiplyFcn','MaxFunctionEvaluations','MaxIterations','ObjectiveLimit','OptimalityTolerance','OutputFcn','PlotFcn','SpecifyObjectiveGradient','StepTolerance','SubproblemAlgorithm','TypicalX','UseParallel','Algorithm'};
    case 'fmincon'
        allNames={'BarrierParamUpdate','CheckGradients','ConstraintTolerance','Display','EnableFeasibilityMode','FiniteDifferenceStepSize','FiniteDifferenceType','FunctionTolerance','HessianApproximation','HessianFcn','HessianMultiplyFcn','HonorBounds','MaxFunctionEvaluations','MaxIterations','ObjectiveLimit','OptimalityTolerance','OutputFcn','PlotFcn','ScaleProblem','SpecifyConstraintGradient','SpecifyObjectiveGradient','StepTolerance','SubproblemAlgorithm','TypicalX','UseParallel','Algorithm'};
    case 'patternsearch'
        allNames={'Display','ConstraintTolerance','FunctionTolerance','MaxFunctionEvaluations','MaxIterations','MaxTime','MeshTolerance','StepTolerance','OutputFcn','PlotFcn','UseParallel','UseVectorized','InitialMeshSize','SearchFcn','ScaleMesh','MeshContractionFactor','MeshExpansionFactor','PollMethod','PollOrderAlgorithm','UseCompletePoll','UseCompleteSearch','AccelerateMesh','Algorithm'};
    case 'ga'
        allNames={'EliteCount','FitnessLimit','FitnessScalingFcn','HybridFcn','MaxStallTime','NonlinearConstraintAlgorithm','PlotFcn','SelectionFcn','ConstraintTolerance','CreationFcn','CrossoverFcn','CrossoverFraction','Display','FunctionTolerance','InitialPopulationMatrix','InitialPopulationRange','InitialScoresMatrix','MaxGenerations','MaxStallGenerations','MaxTime','MutationFcn','OutputFcn','PopulationSize','PopulationType','UseParallel','UseVectorized'};
    case 'particleswarm'
        allNames={'CreationFcn','Display','FunctionTolerance','HybridFcn','InertiaRange','InitialSwarmMatrix','InitialSwarmSpan','MaxIterations','MaxStallIterations','MaxStallTime','MaxTime','MinNeighborsFraction','ObjectiveLimit','OutputFcn','PlotFcn','SelfAdjustmentWeight','SocialAdjustmentWeight','SwarmSize','UseParallel','UseVectorized'};
    otherwise
        error(message('SimBiology:Internal:InternalError'));
    end
end

function out=verifyWeightExpression(action,input)


    matfileName=input.matfileName;
    matfileVariableName=input.matfileVariableName;
    matfileDerivedVariableName=input.matfileDerivedVariableName;
    rowsToExclude=input.rowsToExclude;
    dependentVariable=cell(input.dependentVariable);
    expression=input.expression;


    message='';
    requiresData=false;


    data=loadVariable(matfileName,matfileVariableName);
    derivedData=loadVariable(matfileName,matfileDerivedVariableName);


    if~isempty(rowsToExclude)
        if iscell(rowsToExclude)
            rowsToExclude=[rowsToExclude{:}];
        end
        rowsToExclude=double(rowsToExclude);
        data(rowsToExclude,:)=[];

        if~isempty(derivedData)
            derivedData(rowsToExclude,:)=[];
        end
    end

    try
        h=eval(expression);%#ok<NASGU>
    catch ex %#ok<NASGU>
        requiresData=true;




        columnNames=data.Properties.VariableNames;
        for i=1:length(columnNames)
            eval([columnNames{i},' = data.(columnNames{ ',num2str(i),'});']);
        end

        if~isempty(derivedData)
            columnNames=derivedData.Properties.VariableNames;
            for i=1:length(columnNames)
                eval([columnNames{i},' = derivedData.(columnNames{ ',num2str(i),'});']);
            end
        end
    end

    try

        h=eval(expression);
        expectedSize=[height(data),numel(dependentVariable)];
        sbiogate('privatecheckweights',h,expectedSize);
    catch ex
        message=SimBiology.web.internal.errortranslator(ex);
    end

    if length(message)>7&&strcmp(message(1:7),'Error: ')
        message=message(8:end);
    end

    results.message=message;
    results.requiresData=requiresData;

    out={action,results};

end

function out=getEstimatedParameters(input)

    out.names={};
    out.action=input.action;
    matfileName=input.matfileName;
    try
        dataName=split(input.name,'.');
        if numel(dataName)==1

            results=loadVariable(matfileName,input.matfileVariableName);
        else

            results=loadVariable(matfileName,'data');
            results=results.results;
        end

        if~isempty(results)
            out.names=results(1).EstimatedParameterNames;
        end
    catch
    end

end

function out=getEstimatedValues(input)

    out=struct('type','','values',[],'groups',[]);
    matfileName=input.matfileName;
    results=loadVariable(matfileName,'data');
    results=results.results;

    if isa(results,'SimBiology.fit.OptimResults')
        [out.type,out.values,out.groups]=getOptimResultsValues(results);
    elseif isa(results,'SimBiology.fit.NLMEResults')
        [out.type,out.values,out.groups]=getNLMEResultsValues(results);
    end

end

function[type,valueInfo,groups]=getOptimResultsValues(results)

    groups=cell(1,numel(results));
    names=results(1).EstimatedParameterNames;


    values=zeros(numel(names),numel(results));
    for i=1:numel(results)
        groups{i}=results(i).GroupName;
        values(:,i)=results(i).ParameterEstimates.Estimate;
    end

    if isa(groups{1},'categorical')
        groups=cellstr(string(groups));
    end

    valueInfo=struct('name','','values','');
    valueInfo=repmat(valueInfo,1,numel(names));
    for i=1:numel(names)
        next.name=names{i};
        next.values=values(i,:);
        valueInfo(i)=next;
    end

    if isempty(groups{1})
        type='pooled';
    else
        type='nonpooled';
    end

end

function[type,valueInfo,groups]=getNLMEResultsValues(results)

    groups=unique(results.IndividualParameterEstimates.Group,'stable');
    names=results.EstimatedParameterNames;

    if isa(groups,'categorical')
        groups=cellstr(string(groups));
    end

    valueInfo=struct('name','','values','','popValues','');
    valueInfo=repmat(valueInfo,1,numel(names));
    values=results.IndividualParameterEstimates.Estimate;
    popValues=results.PopulationParameterEstimates.Estimate;
    for i=1:numel(names)
        next.name=names{i};
        next.values=values(i:numel(names):end);
        next.popValues=popValues(i);
        valueInfo(i)=next;
    end

    type='mixed';

end

function data=loadVariable(matfile,matfileVarName)

    if SimBiology.internal.variableExistsInMatFile(matfile,matfileVarName)
        data=load(matfile,matfileVarName);
        data=data.(matfileVarName);
    else
        data=[];
    end
end
