function out=fitStepHandler(action,varargin)

    switch(action)
    case 'getFitStep'
        out=getFitStep(varargin{:});
    end

end

function step=getFitStep(projectConverter,node,sessionID,externalDataInfo,projectVersion)


    step=struct;
    step.name='Fit';
    step.type='Fit';
    step.description='';
    step.enabled=true;
    step.version=1;


    step.runInParallel=getAttribute(node,'UseDistributed');
    if isempty(step.runInParallel)
        step.runInParallel=false;
    end


    step.estimationMethod=getEstimationFcnInfo(projectConverter,node);


    step.advancedSettings=getAdvancedAlgorithmInfo(node);


    step.algorithmSettings=getAlgorithmSettingsInfo(node,step.estimationMethod.estimationFunction);



    step.covarianceMatrix=[];
    step.covariates={};


    step.errorModel=getErrorModelInfo(node,sessionID,projectVersion);



    step.estimatedParameterInfo=[];


    step.fitDefinitions=getFitDefinitionInfo(node);


    step.internal=struct;
    step.internal.args=struct;
    step.internal.activeStep=false;
    step.internal.covariateRawTableData=getCovariateTableInfo(node);
    [estimatedParameterTableData,isPooled]=getEstimatedParameterInfo(node,sessionID,projectVersion);
    step.internal.estimatedParameterRawTableData=estimatedParameterTableData;
    step.internal.hasDataBeenPopulated=~isempty(externalDataInfo.data);
    step.internal.hasModelBeenPopulated=sessionID~=-1;
    step.internal.id=3;
    step.internal.isSetup=false;
    step.internal.outputArguments={'results','simdataI'};


    [paramNames,tableData]=getCovarianceMatrixTableInfo(node);
    step.covarianceMatrixParameterNames=paramNames;
    step.internal.covarianceMatrixRawTableData=tableData;


    [settings,advancedSettings]=getLocalSolverSettings(node);
    step.localSolverSettings=settings;
    step.localSolverAdvancedSettings=advancedSettings;


    if strcmp(step.estimationMethod.estimationFunction,'nlmefit')
        step.statisticalModel='mixed effects';
        step.supportsCovariates=true;
        step.pooled=isPooled;
    elseif strcmp(step.estimationMethod.estimationFunction,'nlmefitsa')
        step.statisticalModel='mixed effects using stochastic solver';
        step.supportsCovariates=true;
        step.pooled=isPooled;
    else
        step.statisticalModel='non-linear regressions';
        step.supportsCovariates=false;
        step.pooled=isPooled;
    end

end

function fitDefinitionInfo=getFitDefinitionInfo(node)

    fitDefinitionInfo=getFitDefinitionStructTemplate;


    errorModelNode=getField(node,'DataSettings');
    responseRowNodes=getField(errorModelNode,'ResponseRow');
    dosingRowNodes=getField(errorModelNode,'DosingRow');



    if isempty(responseRowNodes)
        responseRowNodes=struct;
    end


    totalRows=numel(responseRowNodes)+numel(dosingRowNodes)+2;
    fitDefinitionInfo=repmat(fitDefinitionInfo,totalRows,1);


    fitDefinitionInfo(1).classification='group';
    fitDefinitionInfo(1).property=getAttribute(errorModelNode,'Group');
    fitDefinitionInfo(1).columnSpan=[1,1,1,3];


    fitDefinitionInfo(2).classification='independent';
    fitDefinitionInfo(2).property=getAttribute(errorModelNode,'Time');
    fitDefinitionInfo(2).columnSpan=[1,1,1,3];


    for i=1:numel(responseRowNodes)
        index=2+i;
        fitDefinitionInfo(index).classification='response';
        fitDefinitionInfo(index).property=getAttribute(responseRowNodes(i),'ResponseLabel');
        fitDefinitionInfo(index).value=getAttribute(responseRowNodes(i),'ResponseQuantityLabel');
        fitDefinitionInfo(index).valueType='speciesParameter';


        children=getFitDefinitionStructTemplate;
        children=repmat(children,2,1);
        properties={'Column','Component'};
        valueType={'rawdata','speciesParameter'};

        for j=1:numel(children)
            children(j).isChild=true;
            children(j).property=properties{j};
            children(j).valueType=valueType{j};
        end


        children(1).value=fitDefinitionInfo(index).property;
        children(2).value=fitDefinitionInfo(index).value;


        fitDefinitionInfo(index).children=children;
    end


    for i=1:numel(dosingRowNodes)
        index=numel(responseRowNodes)+2+i;
        fitDefinitionInfo(index).classification='dose from data';
        fitDefinitionInfo(index).property=getAttribute(dosingRowNodes(i),'DoseColumn');
        fitDefinitionInfo(index).value=getAttribute(dosingRowNodes(i),'Name');
        fitDefinitionInfo(index).valueType='species';


        children=getFitDefinitionStructTemplate;
        children=repmat(children,4,1);
        properties={'Column','Target','Rate','Time Lag Parameter'};
        valueType={'rawdata','species','rawDataParameter','parameter'};

        for j=1:numel(children)
            children(j).isChild=true;
            children(j).property=properties{j};
            children(j).valueType=valueType{j};
        end


        children(1).value=getAttribute(dosingRowNodes(i),'DoseColumn');
        children(2).value=getAttribute(dosingRowNodes(i),'Name');
        children(4).value=getAttribute(dosingRowNodes(i),'LagName');



        rateType=getAttribute(dosingRowNodes(i),'RateType');
        if~isempty(rateType)
            switch rateType
            case 'Instant'
                children(3).value=rateType;
            case 'Column Name'
                children(3).value=getAttribute(dosingRowNodes(i),'RateColumn');
            case 'Parameter'
                children(3).value=getAttribute(dosingRowNodes(i),'ParameterName');
            otherwise
                children(3).value='Instant';
            end
        else
            doseType=getAttribute(dosingRowNodes(i),'DoseType');
            switch doseType
            case{'first-order','bolus'}
                children(3).value='Instant';
            case 'infusion'
                children(3).value=getAttribute(dosingRowNodes(i),'RateColumn');
            case 'zero-order'
                children(3).value=getAttribute(dosingRowNodes(i),'ParameterName');
            otherwise
                children(3).value='Instant';
            end
        end


        fitDefinitionInfo(index).children=children;
    end

end

function[estimatedParameterInfo,isPooled]=getEstimatedParameterInfo(node,sessionID,projectVersion)


    estimationSettings=getField(node,'EstimationSettings');


    switch projectVersion
    case{'4.1','4.2','4.3','4.3.1','5'}
        isPooled=false;
        algorithmSettingsNode=getField(node,'AlgorithmProperties_NLINFIT');

        if~isempty(algorithmSettingsNode)
            propertyNodes=getField(algorithmSettingsNode,'Property');

            for i=1:numel(propertyNodes)
                description=getAttribute(propertyNodes(i),'Name');
                value=getAttribute(propertyNodes(i),'Value');

                if strcmp(description,'Pooled')
                    isPooled=value;
                    break;
                end
            end
        end
    otherwise
        isPooled=getAttribute(estimationSettings,'Pooled',false);
    end

    isMixed=any(strcmp(getAttribute(estimationSettings,'EstimationMethod'),{'NLMEFIT','NLMEFITSA'}));


    estimateRows=getField(estimationSettings,'ObjToEstimate');
    estimatedParameterInfo=getEstimatedParameterStructTemplate;
    estimatedParameterInfo=repmat(estimatedParameterInfo,numel(estimateRows),1);
    model=getModelFromSessionID(sessionID);

    for i=1:numel(estimateRows)
        estimatedParameterInfo(i).name=getAttribute(estimateRows(i),'Name');
        estimatedParameterInfo(i).use=getAttribute(estimateRows(i),'Estimate');


        obj=getObject(model,estimatedParameterInfo(i).name);
        if~isempty(obj)
            estimatedParameterInfo(i).name=obj.PartiallyQualifiedNameReally;
            estimatedParameterInfo(i).sessionID=obj.sessionID;
            estimatedParameterInfo(i).UUID=obj.UUID;
        end


        children=getEstimatedParameterChildStructTemplate;
        children=repmat(children,3,1);

        children(1).name='Initial Untransformed Value';
        children(2).name='Untransformed Lower Bound';
        children(3).name='Untransformed Upper Bound';

        children(1).value=getAttribute(estimateRows(i),'InitialGuess');
        children(2).value=getAttribute(estimateRows(i),'LowerBound');
        children(3).value=getAttribute(estimateRows(i),'UpperBound');

        children(1).visible=~isMixed;
        children(2).visible=~isMixed;
        children(3).visible=~isMixed;


        parameterExpression=getField(estimateRows(i),'ParameterExpression');
        transform=getAttribute(parameterExpression,'ParameterTransform');
        randomEffectName=getAttribute(parameterExpression,'RandomEffectName');
        hasRandomEffect=getAttribute(parameterExpression,'HasRandomEffect');


        if~isMixed
            estimatedParameterInfo(i).transform=getTransform(transform);
        else
            estimatedParameterInfo(i).transform=getInverseTransform(transform);
        end


        estimatedParameterInfo(i).recommendedEta=randomEffectName;

        if hasRandomEffect
            estimatedParameterInfo(i).usedEta=randomEffectName;
        end


        covLabelCount=getAttribute(parameterExpression,'CovariateLabelsCount');

        if isempty(covLabelCount)
            covLabelCount=0;
        end


        covariateChildren=getEstimatedParameterChildStructTemplate;
        covariateChildren=repmat(covariateChildren,covLabelCount+1,1);
        covariateChildren(1).name=getAttribute(parameterExpression,'InterceptName');
        covariateChildren(1).value=getAttribute(parameterExpression,'IntercepValue');
        covariateChildren(1).visible=isMixed;
        covariateChildren(1).covariateRow=true;

        estimatedParameterInfo(i).usedCovThetas{end+1}=covariateChildren(1).name;

        covariateString=covariateChildren(1).name;

        if covLabelCount>0
            covariateTerms=getField(estimateRows(i),'ParameterExpression');
            covariateTerms=getField(covariateTerms,'CovariateTerm');
            for j=1:numel(covariateTerms)
                covariateChildren(j+1).name=getAttribute(covariateTerms(j),'SlopeName');
                covariateChildren(j+1).value=getAttribute(covariateTerms(j),'SlopeValue');
                covariateChildren(j+1).visible=isMixed;
                covariateChildren(j+1).covariateRow=true;

                covariateName=getAttribute(covariateTerms(j),'CovariateName');
                covariateName=getTransformedOrUntransformedCovariateName(covariateName,estimationSettings);


                covariateString=[covariateString,' + ',covariateChildren(j+1).name,'*',covariateName];%#ok<AGROW>

                estimatedParameterInfo(i).usedCovThetas{end+1}=covariateChildren(j+1).name;
                estimatedParameterInfo(i).recommendedCovThetas{end+1}=covariateChildren(j+1).name;
                estimatedParameterInfo(i).covariateNames{end+1}=covariateName;
            end
        end



        if hasRandomEffect
            covariateString=sprintf('%s + %s',covariateString,estimatedParameterInfo(i).usedEta);
        end


        if~strcmp(transform,'none')
            transform=getInverseTransform(transform);
            estimatedParameterInfo(i).covariateExpression=[transform,'(',covariateString,')'];
        else
            estimatedParameterInfo(i).covariateExpression=covariateString;
        end



        covExpression=sprintf('%s = %s',estimatedParameterInfo(i).name,estimatedParameterInfo(i).covariateExpression);
        result=SimBiology.web.covariatehandler('parseCovariateExpression',struct('expression',covExpression,'rowID',-1));
        estimatedParameterInfo(i).matlabErrorMessages=result{2}.message;
        estimatedParameterInfo(i).children=vertcat(children,covariateChildren);
    end

end

function out=getTransformedOrUntransformedCovariateName(transformedCovName,estimationSettings)

    out=transformedCovName;
    covariateRows=getField(estimationSettings,'CovariateTransform');


    for i=1:numel(covariateRows)
        name=getAttribute(covariateRows(i),'Name');



        if strcmp(name,transformedCovName(2:end))
            centerBy=getAttribute(covariateRows(i),'CenterBy');
            scaleBy=getAttribute(covariateRows(i),'ScaleBy');
            log=getAttribute(covariateRows(i),'Log');

            isTransformed=~strcmp(centerBy,'none')||~strcmp(scaleBy,'none')||log;

            if isTransformed
                out=transformedCovName;
            else
                out=transformedCovName(2:end);
            end
            break;
        end
    end

end

function[paramNames,covarianceMatrixInfo]=getCovarianceMatrixTableInfo(node)

    estimationSettings=getField(node,'EstimationSettings');
    estimateInfo=getField(estimationSettings,'ObjToEstimate');
    nodes={};
    paramNames={};


    for i=1:numel(estimateInfo)
        paramExpression=getField(estimateInfo(i),'ParameterExpression');

        if getAttribute(paramExpression,'HasRandomEffect')
            nodes{end+1}=estimateInfo(i);%#ok<AGROW>
            paramNames{end+1}=getAttribute(estimateInfo(i),'Name');%#ok<AGROW>
        end
    end

    covarianceMatrixInfo=struct('ID',-1,'isChild',false,'name','');
    for i=1:numel(paramNames)
        fieldName=sprintf('Column%d',i-1);
        covarianceMatrixInfo.(fieldName)=0;
    end

    covarianceMatrixInfo=repmat(covarianceMatrixInfo,numel(paramNames),1);

    for i=1:numel(nodes)
        numDependencies=getAttribute(nodes{i},'DependenciesCount');
        covarianceMatrixInfo(i).name=getAttribute(nodes{i},'Name');

        if~isempty(numDependencies)
            for j=1:numDependencies
                depValue=getAttribute(nodes{i},sprintf('Dependencies%d',j-1));
                index=find(strcmp(paramNames,depValue));
                fieldName=sprintf('Column%d',index-1);
                covarianceMatrixInfo(i).(fieldName)=true;
            end
        end
    end

end

function covariateTableInfo=getCovariateTableInfo(node)

    estimationSettings=getField(node,'EstimationSettings');
    covariateNodes=getField(estimationSettings,'CovariateTransform');

    covariateTableInfo=getCovariateTableStructTemplate;
    covariateTableInfo=repmat(covariateTableInfo,numel(covariateNodes),1);

    for i=1:numel(covariateNodes)
        covariateTableInfo(i).name=getAttribute(covariateNodes(i),'Name');
        covariateTableInfo(i).columnSpan=[1,3];


        children=getCovariateTableChildStructTemplate;
        children=repmat(children,3,1);


        children(1).name='Center by';
        children(2).name='Normalize by';
        children(3).name='Log';


        children(1).value=getAttribute(covariateNodes(i),'CenterBy');
        children(2).value=getAttribute(covariateNodes(i),'ScaleBy');

        log=getAttribute(covariateNodes(i),'Log');
        if log
            children(3).value='true';
        else
            children(3).value='false';
        end

        isTransformed=~strcmp(children(1).value,'none')||~strcmp(children(2).value,'none')||log;

        if isTransformed
            covariateTableInfo(i).value=getTransformedCovariateString(covariateTableInfo(i).name,children(1).value,children(2).value,log);
        else
            covariateTableInfo(i).value=covariateTableInfo(i).name;
        end

        covariateTableInfo(i).children=children;
    end

end

function estimationFunctionInfo=getEstimationFcnInfo(projectConverter,node)

    estimationFunctionInfo=getEstimationFcnTemplate;
    solver=getField(node,'EstimationSettings');
    solver=lower(getAttribute(solver,'EstimationMethod'));
    isOptimInstalled=SimBiology.internal.checkForToolbox('optim');


    if isnumeric(solver)
        if isOptimInstalled
            solver='lsqnonlin';
        else
            solver='fminsearch';
        end
    end

    switch(solver)
    case 'nlinfit'
        if isOptimInstalled
            solver='lsqnonlin';
        else
            solver='fminsearch';
        end
        programName=getAttribute(node,'Name');
        projectConverter.addWarning(sprintf('Estimation function ''nlinfit'' is no longer supported in the SimBiology Model Analyzer, the estimation function was switched to ''%s'' in program %s',solver,programName));
    case 'lsqnonin'
        solver='lsqnonlin';
    case 'pso'
        solver='particleswarm';
    end

    estimationFunctionInfo.estimationFunction=solver;
    estimationFunctionInfo.useStochasticSolver=any(strcmp(solver,'nlmefitsa'));
    estimationFunctionInfo.useGlobalSolver=any(strcmp(solver,{'ga','scattersearch','patternsearch','particleswarm'}));

    if estimationFunctionInfo.useGlobalSolver
        estimationFunctionInfo.globalSolver=solver;
    end

    if~estimationFunctionInfo.useGlobalSolver&&~any(strcmp(solver,{'nlmefit','nlmefitsa'}))
        estimationFunctionInfo.nonGlobalSolver=solver;
    end

end

function errorModel=getErrorModelInfo(node,sessionID,projectVersion)

    errorModel=struct;
    errorModelNode=getField(node,'DataSettings');



    errorModel.nlinFitErrorModel='constant';
    errorModel.nlinFitErrorModelWeights='[]';


    nlmeErrModelNode=getField(errorModelNode,'ErrorModel');
    errorModel.nlmeErrorModel=getAttribute(nlmeErrModelNode,'ErrorModelValue','constant');
    errorModel.nlmefitsaCombinedParameterA=getAttribute(nlmeErrModelNode,'ErrorModelA',1);
    errorModel.nlmefitsaCombinedParameterB=getAttribute(nlmeErrModelNode,'ErrorModelB',1);


    switch projectVersion
    case{'4.1','4.2','4.3','4.3.1','5','5.1'}
        errorModel.optimErrorModel=getAttribute(nlmeErrModelNode,'ErrorModelValue','constant');
    otherwise
        errorModel.optimErrorModel=getAttribute(errorModelNode,'CommonErrorModel','constant');
    end


    errorModel.optimErrorModelOption=getErrorModelOption(getAttribute(errorModelNode,'ErrorModelWeightSelectedItem','common'));


    weightsNode=getField(errorModelNode,'WeightedFitting');


    errorModel.optimErrorModelWeights=getAttribute(weightsNode,'WeightFcn','[]');



    switch projectVersion
    case{'4.1','4.2','4.3','4.3.1','5','5.1','5.2','5.3','5.4','5.5','5.6','5.7'}


        if strcmp(errorModel.optimErrorModelOption,'common')
            type=translateErrorModelName(getAttribute(weightsNode,'ErrorModelWeightType'));
            if strcmp(type,'weights')
                errorModel.optimErrorModelOption=type;
            else
                errorModel.optimErrorModel=type;
            end
        end
    end


    responseRows=getField(errorModelNode,'ResponseRow');
    responseInfo=struct('data','','errorModel','','name','','sessionID','','UUID','');
    responseInfo=repmat(responseInfo,1,numel(responseRows));
    errModel=struct('errorModel','','name','');
    errModel=repmat(errModel,1,numel(responseRows));

    model=getModelFromSessionID(sessionID);
    for i=1:numel(responseRows)
        responseInfo(i).data=getAttribute(responseRows(i),'ResponseLabel');
        responseInfo(i).errorModel=getAttribute(responseRows(i),'ErrorModel');
        responseInfo(i).name=getAttribute(responseRows(i),'ResponseQuantityLabel');
        responseInfo(i).sessionID=-1;
        responseInfo(i).UUID=-1;
        errModel(i).errorModel=getAttribute(responseRows(i),'ErrorModel');
        errModel(i).name=getAttribute(responseRows(i),'ResponseQuantityLabel');

        obj=getObject(model,responseInfo(i).name);
        if~isempty(obj)
            responseInfo(i).name=obj.PartiallyQualifiedNameReally;
            responseInfo(i).sessionID=obj.sessionID;
            responseInfo(i).UUID=obj.UUID;
            errModel(i).name=obj.PartiallyQualifiedNameReally;
        end
    end

    errorModel.optimErrorModelForEachResponse=errModel;
    errorModel.responseVariableStoreData=responseInfo;

end

function algorithmSettings=getAlgorithmSettingsInfo(node,estimationFunction)




    algorithmSettings=getAlgorithmSettingsTemplate;

    optionNodeProps={'AlgorithmProperties_OPTIMOPTIONS',...
    'AlgorithmProperties_NLME','AlgorithmProperties_SAEM',...
    'AlgorithmProperties_PSO','AlgorithmProperties_GA',...
    'AlgorithmProperties_PATTERNSEARCH',...
    'AlgorithmProperties_SCATTERSEARCH',...
    'AlgorithmProperties_NLINFIT'};


    for j=1:numel(optionNodeProps)
        optionNode=getField(node,optionNodeProps{j});
        if~isempty(optionNode)
            propertyNodes=getField(optionNode,'Property');

            for i=1:numel(propertyNodes)
                description=getAttribute(propertyNodes(i),'Name');
                value=getAttribute(propertyNodes(i),'Value');
                value=getOptionValue(value);
                prop=getOptionProperty(description,optionNodeProps{j});

                if strcmp(prop,'localSolver')&&strcmp(value,'nlinfit')
                    value='lsqnonlin';
                end

                if~isempty(prop)




                    if strcmp(prop,'showProgress')
                        if any(ismember({'nlmefit','nlmefitsa'},estimationFunction))
                            if any(ismember({'AlgorithmProperties_NLME','AlgorithmProperties_SAEM'},optionNodeProps{j}))
                                algorithmSettings.(prop)=value;
                            end
                        else
                            algorithmSettings.(prop)=value;
                        end
                    else
                        algorithmSettings.(prop)=value;
                    end
                end
            end
        end
    end

end

function[settings,advancedSettings]=getLocalSolverSettings(node)




    advancedSettings=struct('ID',-1,'isOption',false,'isUndefined',true,'message','','property','','value','');


    settings=struct('tolX',1e-8,'tolFun',1e-8,'optimalityTolerance',1e-6,'maxIter',400);

    localSolverNode=getField(node,'AlgorithmProperties_LOCAL_SOLVER');

    if~isempty(localSolverNode)
        propertyNodes=getField(localSolverNode,'Property');

        for i=1:numel(propertyNodes)


            descr=getAttribute(propertyNodes(i),'Name');
            prop=getOptionProperty(descr,'lsqnonlin');
            settings.(prop)=getAttribute(propertyNodes(i),'Value');
        end
    end

end

function advancedSettings=getAdvancedAlgorithmInfo(node)


    advancedSettings=struct;



    optimOptions=parseAdvancedAlgorithmSettings(getField(node,'AdvancedAlgorithmProperties_optimoptions'));
    advancedSettings.lsqcurvefit=optimOptions;
    advancedSettings.lsqnonlin=optimOptions;
    advancedSettings.fminunc=optimOptions;
    advancedSettings.fmincon=optimOptions;
    advancedSettings.particleswarm=optimOptions;
    advancedSettings.patternsearch=optimOptions;
    advancedSettings.ga=optimOptions;

    advancedSettings.scattersearch=parseAdvancedAlgorithmSettings(getField(node,'AdvancedAlgorithmProperties_scattersearch'));
    advancedSettings.fminsearch=parseAdvancedAlgorithmSettings(getField(node,'AdvancedAlgorithmProperties_optimset'));
    advancedSettings.nlmefit=parseAdvancedAlgorithmSettings(getField(node,'AdvancedAlgorithmProperties_nlmefit'));
    advancedSettings.nlmefitsa=parseAdvancedAlgorithmSettings(getField(node,'AdvancedAlgorithmProperties_nlmefitsa'));



    nlmefitOptions=getField(node,'AlgorithmProperties_NLME');
    if~isempty(nlmefitOptions)
        propertyNodes=getField(nlmefitOptions,'Property');

        for i=1:numel(propertyNodes)
            description=getAttribute(propertyNodes(i),'Name');
            value=getAttribute(propertyNodes(i),'Value');

            if strcmp(description,'Covariance Matrix Parameterization')
                row=getAdvancedAlgorithmOptionStructTemplate;
                row.isUndefined=false;
                row.isOption=true;
                row.property='CovParameterization';

                if strcmp(value,'Cholesky factorization')
                    row.value='chol';
                else
                    row.value='logm';
                end



                if~isPropertyValueDefault(row.property,row.value)
                    advancedSettings.nlmefit=horzcat(row,advancedSettings.nlmefit);
                end
            end
        end
    end

    scattersearchOptions=getField(node,'AlgorithmProperties_SCATTERSEARCH');
    if~isempty(scattersearchOptions)
        propertyNodes=getField(scattersearchOptions,'Property');

        for i=1:numel(propertyNodes)
            description=getAttribute(propertyNodes(i),'Name');
            value=getAttribute(propertyNodes(i),'Value');
            if isnumeric(value)
                value=num2str(value);
            end

            switch description
            case 'Fraction of the initial trial points that are selected from the best of the initial points'
                row=getAdvancedAlgorithmOptionStructTemplate;
                row.isUndefined=false;
                row.isOption=true;
                row.property='FractionInitialBest';
                row.value=value;
            case 'Interval at which the local solver is applied to the trial points'
                row=getAdvancedAlgorithmOptionStructTemplate;
                row.isUndefined=false;
                row.isOption=true;
                row.property='LocalSearchInterval';
                row.value=value;
            case 'Probability of selecting the current best point as the starting point for local search'
                row=getAdvancedAlgorithmOptionStructTemplate;
                row.isUndefined=false;
                row.isOption=true;
                row.property='LocalSelectBestProbability';
                row.value=value;
            case 'Stop if MaxStallTime in seconds have passed since a change in the best objective function value'
                row=getAdvancedAlgorithmOptionStructTemplate;
                row.isUndefined=false;
                row.isOption=true;
                row.property='MaxStallTime';
                row.value=value;
            case 'Number of iterations before a trial point is replaced if it does not improve'
                row=getAdvancedAlgorithmOptionStructTemplate;
                row.isUndefined=false;
                row.isOption=true;
                row.property='TrialStallLimit';
                row.value=value;
            otherwise
                row=[];
            end



            if~isempty(row)&&~isPropertyValueDefault(row.property,row.value)
                advancedSettings.scattersearch=horzcat(row,advancedSettings.scattersearch);
            end
        end
    end

end

function rows=parseAdvancedAlgorithmSettings(node)



    rows=getAdvancedAlgorithmOptionStructTemplate;

    if isempty(node)
        return;
    end


    propNode=getField(node,'Property');
    valueProp=getAttribute(propNode,'Value');


    valueProp=strsplit(valueProp,',');

    for i=1:numel(valueProp)
        setting=strtrim(valueProp{i});
        if~isempty(setting)
            setting=strsplit(setting,'=');

            if~isempty(setting)
                row=getAdvancedAlgorithmOptionStructTemplate;
                row.isOption=true;
                row.isUndefined=false;
                row.property=strtrim(setting{1});



                if numel(setting)>1
                    row.value=strtrim(strrep(setting{2},'''',''));
                end

                rows(end+1)=row;%#ok<AGROW>
            end
        end
    end


    if numel(rows)>1
        rows=horzcat(rows(2:end),rows(1));
    end

end

function out=isPropertyValueDefault(property,value)

    out=false;

    switch property
    case 'CovParameterization'
        out=strcmp(value,'logm');
    case 'FractionInitialBest'
        out=strcmp(value,'0.5');
    case 'LocalSearchInterval'
        out=strcmp(value,'10');
    case 'LocalSelectBestProbability'
        out=strcmp(value,'0.5');
    case 'MaxStallTime'
        out=strcmp(value,'Inf');
    case 'TrialStallLimit'
        out=strcmp(value,'22');
    end

end

function out=getOptionProperty(descr,nodeName)


    switch descr
    case{'ProgressPlot','OutputFcn'}
        out='showProgress';
    case 'Method to Approximate the Non-linear Mixed Effects Model Likelihood'
        out='approximationType';
    case 'Optimization Function'
        out='optimFun';
    case 'Termination Tolerance on Estimated Fixed and Random Effect Parameters'
        out='nlmeTolX';
    case 'Number of MCMC updates'
        out='NMCMCIterations';
    case 'Termination Tolerance on Log-Likelihood Function'
        out='nlmeTolFun';
    case 'Maximum Iterations'
        if strcmp(nodeName,'AlgorithmProperties_SCATTERSEARCH')
            out='scatterSearchMaxIter';
        else
            out='maxIter';
        end
    case 'Number of Initial Burn-In Iterations During Which the Covariance Matrix is Not Computed'
        out='nBurnIn';
    case 'Number of Iterations after Burn-In'
        out='nIterations';
    case 'Method for Approximating the Log Likelihood'
        out='logLikMethod';
    case 'ComputeStdErrors'
        out='computeStdErrors';
    case 'Termination Tolerance on the Residual Sum of Squares'
        out='tolFun';
    case 'Generations'
        out='generations';
    case 'Termination Tolerance on the Estimated Coefficients'
        out='tolX';
    case 'Termination Tolerance on the First-Order Optimality'
        out='optimalityTolerance';
    case 'Function tolerance'
        out='scatterSearchFunTol';
    case 'Stop if the change in the best objective function value over max stall iterations is less than function tolerance'
        out='maxStallIterations';
    case 'Stop if MaxTime in seconds have passed since the beginning of the search'
        out='maxTime';
    case 'Number of initial points to generate before selecting a subset of trial points for subsequent steps'
        out='numInitialPoints';
    case 'Number of trial points to keep at each iteration'
        out='numTrialPoints';
    case 'Tolerance for considering two local solutions to be the same'
        out='xTolerance';
    case 'LocalSolver'
        out='localSolver';
    otherwise
        out='';
    end

end

function out=getOptionValue(value)

    switch value
    case 'LME (Use the likelihood for linear mixed-effects model)'
        out='LME';
    case 'RELME (Use the restricted likelihood for the linear mixed-effects model)'
        out='RELME';
    case 'FOCE (First order (Laplacian) approximation)'
        out='FOCE';
    case 'FO (First order (Laplacian) approximation without random effects)'
        out='FO';
    case 'Importance sampling'
        out='is';
    case 'Gaussian quadrature'
        out='gq';
    case 'linearization'
        out='lin';
    case 'do not compute'
        out='none';
    otherwise
        out=value;
    end

    if isinf(out)
        out=num2str(out);
    end

end

function out=getErrorModelOption(errorModel)

    if isempty(errorModel)
        out='common';
        return;
    end

    switch errorModel
    case 'ERRORMODEL_SAME'
        out='common';
    case 'ERRORMODEL'
        out='separate';
    case{'WEIGHTS','weights'}
        out='weights';
    otherwise
        out='common';
    end

end

function out=translateErrorModelName(errorModel)

    switch errorModel
    case 'proportional error model'
        out='proportional';
    case 'constant error model'
        out='constant';
    case 'exponential error model'
        out='exponential';
    case 'combined error model'
        out='combined';
    case 'weights'
        out='weights';
    otherwise
        out='constant';
    end

end

function out=getTransformedCovariateString(name,centerBy,scaleBy,log)

    denominator='';
    if~strcmp(scaleBy,'none')
        denominator=sprintf('%s(%s)',scaleBy,name);
    end

    numerator='';
    if~strcmp(scaleBy,'none')
        numerator=sprintf('(%s - %s(%s))',name,centerBy,name);
    end

    out=name;
    if isempty(denominator)
        out=[out,numerator];
    else
        out=['(',numerator,'/',denominator,')'];
    end

    if log
        if strcmp(out,name)
            out=['log(',out,')'];
        else
            out=['log',out];
        end
    end

end

function out=getInverseTransform(transform)

    switch(transform)
    case 'log'
        out='exp';
    case 'none'
        out='';
    otherwise
        out=sprintf('%sinv',transform);
    end

end

function out=getTransform(transform)

    switch(transform)
    case 'log'
        out='exp';
    case 'none'
        out='';
    otherwise
        out=transform;
    end

end

function out=getEstimationFcnTemplate

    out=struct;
    out.estimationFunction='';
    out.globalSolver='scattersearch';
    out.nonGlobalSolver='lsqnonlin';
    out.useGlobalSolver=false;
    out.useStochasticSolver=false;

end

function out=getFitDefinitionStructTemplate

    out=struct;
    out.ID=-1;
    out.children='';
    out.classification='';
    out.equal='=';
    out.expand=false;
    out.isChild=false;
    out.message=[];
    out.parentID=-1;
    out.property='Column';
    out.sessionID=-1;
    out.UUID=-1;
    out.type='';
    out.use=true;
    out.value='';
    out.valueType='rawdata';

end

function out=getEstimatedParameterStructTemplate

    out=struct;
    out.ID=-1;
    out.categoryVariable='';
    out.children={};
    out.covariateExpression='';
    out.covariateNames='';
    out.equal='=';
    out.expand=false;
    out.isChild=false;
    out.matlabErrorMessages={};
    out.message={};
    out.name='';
    out.recommendedCovThetas={};
    out.recommendedEta='';
    out.sessionID=-1;
    out.UUID=-1;
    out.transform='';
    out.type='';
    out.use=true;
    out.usedCovThetas={};
    out.usedEta='';
    out.usedTheta='';
    out.value='';

end

function out=getEstimatedParameterChildStructTemplate

    out=struct;
    out.ID=-1;
    out.children={};
    out.covariateRow=false;
    out.equal='=';
    out.expand=[];
    out.isChild=true;
    out.message={};
    out.name='';
    out.parentID=-1;
    out.use=[];
    out.value='';
    out.visible=true;
    out.covariateNames={};
    out.valueEdited=true;

end

function out=getCovariateTableStructTemplate

    out=struct;
    out.ID=-1;
    out.children='';
    out.columnSpan='';
    out.equal='=';
    out.expand=false;
    out.isChild=false;
    out.message=[];
    out.name='';
    out.type='estimateCovariate';
    out.value='';

end

function out=getCovariateTableChildStructTemplate

    out=struct;
    out.ID=-1;
    out.children='';
    out.equal='=';
    out.expand=false;
    out.isChild=true;
    out.message=[];
    out.name='';
    out.parentID='';
    out.value='';

end

function out=getAdvancedAlgorithmOptionStructTemplate

    out=struct;
    out.ID=-1;
    out.isOption=false;
    out.isUndefined=true;
    out.message=[];
    out.property='';
    out.value='';

end

function out=getAlgorithmSettingsTemplate

    out=struct;
    out.NMCMCIterations=2;
    out.approximationType='LME';
    out.computeStdErrors=false;
    out.generations=400;
    out.localSolver='lsqnonlin';
    out.logLikMethod='none';
    out.maxIter=400;
    out.maxStallIterations=50;
    out.maxTime='Inf';
    out.nBurnIn=5;
    out.nIterations=400;
    out.nlmeTolFun=1e-4;
    out.nlmeTolX=1e-4;
    out.numInitialPoints='auto';
    out.numTrialPoints='auto';
    out.optimFun='fminunc';
    out.optimalityTolerance=1e-6;
    out.scatterSearchFunTol=1e-8;
    out.scatterSearchMaxIter='auto';
    out.showProgress=true;
    out.tolFun=1e-8;
    out.tolX=1e-8;
    out.xTolerance=1e-6;


end

function out=getAttribute(node,attribute,varargin)

    out=SimBiology.web.internal.converter.utilhandler('getAttribute',node,attribute,varargin{:});

end

function out=getField(node,field)

    out=SimBiology.web.internal.converter.utilhandler('getField',node,field);

end

function model=getModelFromSessionID(sessionID)

    model=SimBiology.web.modelhandler('getModelFromSessionID',sessionID);

end

function obj=getObject(model,name)

    obj=SimBiology.web.internal.converter.utilhandler('getObject',model,name);

end
