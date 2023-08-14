function[varNames,variableUsageInfo,sourceInfo,errors]=getControlVariableNamesFromVariantExpressions(modelOrBlock,optArgs)











    if nargin<2
        optArgs=Simulink.variant.utils.getControlVariableNamesFromVariantExpressionsOptArgs();
    end


    Simulink.variant.utils.reportDiagnosticIfV2Enabled();

    calledFromTool=optArgs.CalledFromTool;
    hasVerboseInfoObject=~isempty(optArgs.VerboseInfoObject);
    errors={};
    undefinedSimulinkVariantObjects={};
    try


        modelOrBlockObj=get_param(modelOrBlock,'Object');
        modelOrBlock=Simulink.variant.utils.replaceNewLinesWithSpaces(modelOrBlockObj.getFullName());


        if~isempty(optArgs.VerboseInfoObject)
            optArgs.VerboseInfoObject.updateProgressBarMessage('Simulink:Variants:VariantManagerProcessingVariantBlocksInModelHierarchy');
        end
        if strcmp(get_param(modelOrBlock,'type'),'block_diagram')%#ok<*ALIGN>


            model=modelOrBlock;
            blocksPathsInModel=Simulink.variant.utils.i_getFullName(...
            Simulink.variant.utils.getAllVariantAndModelBlocks(model,'AllVariants'));
        elseif strcmp(get_param(modelOrBlock,'type'),'block')






            blocksPathsInModel={modelOrBlock};
            model=Simulink.variant.utils.getModelNameFromPath(modelOrBlock);
        else
            errid='Simulink:Variants:GetCtrlVarsUnexpectedInput';
            errmsg=message(errid,modelOrBlock);
            err=MException(errmsg);
            throwAsCaller(err);
        end
    catch
        errid='Simulink:Variants:GetCtrlVarsUnexpectedInput';
        errmsg=message(errid,modelOrBlock);
        err=MException(errmsg);
        throwAsCaller(err);
    end

    if~isa(optArgs.SpecialVarsInfoManagerMap,'containers.Map')
        optArgs.SpecialVarsInfoManagerMap=containers.Map();
    end

    if optArgs.SpecialVarsInfoManagerMap.isKey(model)
        specialVarsInfoManager=optArgs.SpecialVarsInfoManagerMap(model);
    else
        specialVarsInfoManager=Simulink.variant.manager.SpecialVarsInfoManager(model);
        optArgs.SpecialVarsInfoManagerMap(model)=specialVarsInfoManager;
    end


    if hasVerboseInfoObject
        optArgs.VerboseInfoObject.updateProgressBarMessage('Simulink:Variants:VariantManagerProcessingVariantControlExpr');
    end
    varControlExprsToBlocksMap=containers.Map();
    varControlExprsToParamsMap=containers.Map();
    varObjectNamesToBlocksMap=containers.Map();

    variableUsageInfo.ControlVarsFromParams={};


    variableUsageInfo.ControlVarToBlockUsageMap=containers.Map();


    variableUsageInfo.VariantObjectsToUsageMap=containers.Map();


    dataDictionary=get_param(model,'DataDictionary');
    variableUsageInfo.ControlVarToBlockUsageMap(dataDictionary)=containers.Map;
    variableUsageInfo.VariantObjectsToUsageMap(dataDictionary)=containers.Map;


    variableUsageInfo.RootModelPathToParentModelPathMap=containers.Map();

    sourceInfo.DataDictionaryToVarsMap=containers.Map();
    i_addKeyValueToMap(sourceInfo.DataDictionaryToVarsMap,get_param(model,'DataDictionary'),{});

    sourceInfo.ModelsToVarsMap=containers.Map();
    i_addKeyValueToMap(sourceInfo.ModelsToVarsMap,model,{});

    sourceInfo.SpecialVarsInfoManagerMap=optArgs.SpecialVarsInfoManagerMap;

    sourceInfo.DataDictionaryToModelsMap=containers.Map();
    referencedModelsOrBlocksSoFarUsageMap=optArgs.ReferencedModelsOrBlocksSoFarUsageMap;

    if~referencedModelsOrBlocksSoFarUsageMap.isKey(model)


        emptyVariableUsageInfo=struct('ControlVarToBlockUsageMap',containers.Map,...
        'RootModelPathToParentModelPathMap',containers.Map);
        emptyDataSourceInfo=struct('DataDictionaryToVarsMap',containers.Map,...
        'ModelsToVarsMap',containers.Map,...
        'DataDictionaryToModelsMap',containers.Map,...
        'SpecialVarsInfoManagerMap',containers.Map);


        referencedModelsOrBlocksSoFarUsageMap(model)=struct('RefModelVariableUsageInfo',emptyVariableUsageInfo,...
        'RefModelSourceInfo',emptyDataSourceInfo);
    end

    for blockPathIdx=1:length(blocksPathsInModel)
        varBlockPathInModel=blocksPathsInModel{blockPathIdx};


        if doRecurseIfReferenceModel(optArgs,varBlockPathInModel)
            refModelName=get_param(varBlockPathInModel,'ModelName');
            try
                if referencedModelsOrBlocksSoFarUsageMap.isKey(refModelName)



                    refModelVariableUsageInfo=referencedModelsOrBlocksSoFarUsageMap(refModelName).RefModelVariableUsageInfo;
                    refModelSourceInfo=referencedModelsOrBlocksSoFarUsageMap(refModelName).RefModelSourceInfo;
                    refModelErrors={};
                else
                    load_system(refModelName);


                    [~,refModelVariableUsageInfo,refModelSourceInfo,refModelErrors]=...
                    Simulink.variant.utils.getControlVariableNamesFromVariantExpressions(refModelName,optArgs);
                    referencedModelsOrBlocksSoFarUsageMap(refModelName)=struct(...
                    'RefModelVariableUsageInfo',refModelVariableUsageInfo,...
                    'RefModelSourceInfo',refModelSourceInfo);
                end

                refModelDataDictionaries=refModelVariableUsageInfo.ControlVarToBlockUsageMap.keys;
                for refModelDataDictionaryIdx=1:numel(refModelDataDictionaries)
                    refModelDataDictionary=refModelDataDictionaries{refModelDataDictionaryIdx};

                    if~variableUsageInfo.ControlVarToBlockUsageMap.isKey(refModelDataDictionary)

                        variableUsageInfo.ControlVarToBlockUsageMap(refModelDataDictionary)=containers.Map;
                        variableUsageInfo.VariantObjectsToUsageMap(refModelDataDictionary)=containers.Map;
                    end


                    refModelControlVarToBlockUsageMap=refModelVariableUsageInfo.ControlVarToBlockUsageMap(refModelDataDictionary);
                    refModelVarNames=refModelControlVarToBlockUsageMap.keys;



                    for refModelVarNameIdx=1:numel(refModelVarNames)
                        refModelBlockPaths=refModelControlVarToBlockUsageMap(refModelVarNames{refModelVarNameIdx});
                        refModelBlockUsages={};
                        for m=1:numel(refModelBlockPaths)
                            rootModelPath=Simulink.variant.utils.getBlockPathRootModel(refModelBlockPaths{m},varBlockPathInModel);
                            refModelBlockUsages=[refModelBlockUsages,rootModelPath];

                            variableUsageInfo.RootModelPathToParentModelPathMap(rootModelPath)=refModelVariableUsageInfo.RootModelPathToParentModelPathMap(refModelBlockPaths{m});
                        end

                        i_addKeyValueToMap(variableUsageInfo.ControlVarToBlockUsageMap(refModelDataDictionary),refModelVarNames{refModelVarNameIdx},refModelBlockUsages);
                    end


                    refModelVarObjectNamesToUsageMap=refModelVariableUsageInfo.VariantObjectsToUsageMap(refModelDataDictionary);
                    refModelVarObjectNames=refModelVarObjectNamesToUsageMap.keys();
                    for refModelVarObjectNameIdx=1:numel(refModelVarObjectNames)
                        refModelBlockPaths=refModelVarObjectNamesToUsageMap(refModelVarObjectNames{refModelVarObjectNameIdx});
                        refModelBlockUsages={};
                        for m=1:numel(refModelBlockPaths)
                            rootModelPath=Simulink.variant.utils.getBlockPathRootModel(refModelBlockPaths{m},varBlockPathInModel);
                            refModelBlockUsages=[refModelBlockUsages,rootModelPath];

                            variableUsageInfo.RootModelPathToParentModelPathMap(rootModelPath)=refModelVariableUsageInfo.RootModelPathToParentModelPathMap(refModelBlockPaths{m});
                        end
                        i_addKeyValueToMap(variableUsageInfo.VariantObjectsToUsageMap(refModelDataDictionary),refModelVarObjectNames{refModelVarObjectNameIdx},refModelBlockUsages);
                    end
                end

                i_concatenateMaps(sourceInfo.DataDictionaryToVarsMap,refModelSourceInfo.DataDictionaryToVarsMap);
                i_concatenateMaps(sourceInfo.ModelsToVarsMap,refModelSourceInfo.ModelsToVarsMap);
                i_concatenateMaps(sourceInfo.DataDictionaryToModelsMap,refModelSourceInfo.DataDictionaryToModelsMap);
                i_concatenateMaps(sourceInfo.SpecialVarsInfoManagerMap,refModelSourceInfo.SpecialVarsInfoManagerMap);
                variableUsageInfo.ControlVarsFromParams=[variableUsageInfo.ControlVarsFromParams,refModelVariableUsageInfo.ControlVarsFromParams];
                for idx=1:numel(refModelErrors)
                    errors{end+1}=refModelErrors{idx};
                end
            catch ME
                errors{end+1}=ME;
            end
        end

        isInlineVariant=Simulink.variant.utils.isInlineVariantBlock(varBlockPathInModel);
        isSFChart=Simulink.variant.utils.isSFChart(get_param(varBlockPathInModel,'Handle'));

        if~isInlineVariant&&strcmp(get_param(varBlockPathInModel,'Variant'),'off')&&~isSFChart

            continue;
        end

        if strcmp(get_param(varBlockPathInModel,'BlockType'),'ModelReference')

            continue;
        end


        if~strcmp(get_param(varBlockPathInModel,'BlockType'),'VariantPMConnector')&&~strcmp(get_param(varBlockPathInModel,'VariantControlMode'),'expression')


            continue;
        end

        if Simulink.variant.utils.isManualIVBlock(varBlockPathInModel)




            continue;
        end

        infoFromCSide=Simulink.variant.utils.getVariantBlockInfoForVM(...
        varBlockPathInModel,struct('UseTempWS',false,...
        'IgnoreErrors',false,'HotlinkErrors',false));


        for choiceRowIdx=2:length(infoFromCSide)
            childRowFromCSide=infoFromCSide(choiceRowIdx);
            usage=i_getVarUsage(varBlockPathInModel,childRowFromCSide,calledFromTool);
            expression=[];variantObjectNames={};



            if~isempty(childRowFromCSide.VarControl)&&~childRowFromCSide.IsVariantKeyword



                [expression,variantObjectNames]=Simulink.variant.utils.replaceSimulinkVariantObjectsWithExpressions(model,childRowFromCSide.VarControl,specialVarsInfoManager);
                if childRowFromCSide.IsVariantControlSimulinkVariantObject&&strcmp(childRowFromCSide.VarCondition,getString(message('Simulink:dialog:VariantConditionNotApplicable')))

                    undefinedSimulinkVariantObjects=unique([undefinedSimulinkVariantObjects,expression]);
                end
            end




            if~isempty(expression)&&(isempty(optArgs.DesiredVariableUsage)||strcmp(optArgs.DesiredVariableUsage,usage))


                i_addKeyValueToMap(varControlExprsToBlocksMap,expression,{usage});
            end
            for i=1:numel(variantObjectNames)
                i_addKeyValueToMap(varObjectNamesToBlocksMap,variantObjectNames{i},{usage});
            end
        end
    end
    varParams=specialVarsInfoManager.getVariantParameters();
    for prmIdx=1:numel(varParams)
        choices=varParams(prmIdx).Object.getChoice();
        for choiceIdx=1:2:numel(choices)
            i_addKeyValueToMap(varControlExprsToParamsMap,choices{choiceIdx},varParams(prmIdx).Name);
        end
    end

    varControlExprs=[keys(varControlExprsToBlocksMap),keys(varControlExprsToParamsMap)];
    netUsages={};

    if hasVerboseInfoObject
        optArgs.VerboseInfoObject.updateProgressBarMessage('Simulink:Variants:VariantManagerProcessingVariablesFromVariantCondition');
    end
    for varControlExprIdx=1:length(varControlExprs)
        expression=varControlExprs{varControlExprIdx};
        [vars,undefinedVariantObjectNames]=i_findVarsInVariantExpression(model,expression,optArgs);





        indexToRemove=[];
        for i=1:numel(vars)
            if contains(vars{i},{'(',')'})


                indexToRemove=[indexToRemove,i];
                continue;
            end

            if(contains(vars{i},'.'))&&...
                ~Simulink.variant.utils.existsVarInSourceWSOf(model,vars{i})


                retVal=0;
                try
                    retVal=(Simulink.variant.utils.slddaccess.evalExpressionInGlobalScope(model,['isenum(',vars{i},')']));
                catch




                end
                if retVal
                    indexToRemove=[indexToRemove,i];
                end
            end
        end
        vars(indexToRemove)=[];
        if varControlExprsToBlocksMap.isKey(expression)
            blocksUsingExpression=varControlExprsToBlocksMap(expression);
            netUsages=[netUsages,blocksUsingExpression];%#ok<*AGROW>
            for i=1:numel(vars)
                i_addKeyValueToMap(variableUsageInfo.ControlVarToBlockUsageMap(dataDictionary),vars{i},blocksUsingExpression);
            end
            for i=1:numel(undefinedVariantObjectNames)
                i_addKeyValueToMap(variableUsageInfo.VariantObjectsToUsageMap(dataDictionary),undefinedVariantObjectNames{i},blocksUsingExpression);
            end
        end

        if varControlExprsToParamsMap.isKey(expression)
            variableUsageInfo.ControlVarsFromParams=[variableUsageInfo.ControlVarsFromParams,vars];
        end

        i_addKeyValueToMap(sourceInfo.DataDictionaryToVarsMap,get_param(model,'DataDictionary'),vars);
        i_addKeyValueToMap(sourceInfo.ModelsToVarsMap,model,vars);
    end

    varObjectNames=keys(varObjectNamesToBlocksMap);
    for i=1:numel(varObjectNames)
        blocksUsingVarObject=varObjectNamesToBlocksMap(varObjectNames{i});
        netUsages=[netUsages,blocksUsingVarObject];
        i_addKeyValueToMap(variableUsageInfo.VariantObjectsToUsageMap(dataDictionary),varObjectNames{i},blocksUsingVarObject);
    end

    netUsages=unique(netUsages);
    for i=1:numel(netUsages)



        variableUsageInfo.RootModelPathToParentModelPathMap(netUsages{i})=netUsages{i};
    end

    i_addKeyValueToMap(sourceInfo.DataDictionaryToModelsMap,get_param(model,'DataDictionary'),{model});

    varNames={};
    allModels=sourceInfo.ModelsToVarsMap.keys;
    for i=1:numel(allModels)
        varNames=[varNames{:},sourceInfo.ModelsToVarsMap(allModels{i})];
    end
    varNames=unique(varNames);

    for i=1:numel(undefinedSimulinkVariantObjects)


        err=MException(message('Simulink:Variants:VariantConditionUndefinedWarning',undefinedSimulinkVariantObjects{i},model));
        errors{end+1}=err;
    end
end


function flag=doRecurseIfReferenceModel(optArgs,varBlockPathInModel)
    flag=optArgs.RecurseIntoModelReferences&&...
    strcmp(get_param(varBlockPathInModel,'BlockType'),'ModelReference')&&...
    strcmp(get_param(varBlockPathInModel,'ProtectedModel'),'off');
end


function[vars,variantObjectNames]=i_findVarsInVariantExpression(model,expr,optArgs)
    specialVarsInfoManager=optArgs.SpecialVarsInfoManagerMap(model);

    vars={};variantObjectNames={};
    if isempty(expr)||any(strcmp(expr,{getString(message('Simulink:Variants:Ignored')),getString(message('Simulink:dialog:VariantConditionNotApplicable'))}))
        return;
    end

    oexpr=expr;

    specialChars={'"',''''};
    for i=1:numel(specialChars)


        splitExpr=regexp(expr,['(?<=',specialChars{i},')[^',specialChars{i},']+(?=',specialChars{i},')'],'match');


        expr=erase(expr,specialChars{i});
        expr=erase(expr,splitExpr);

        expr=erase(expr,specialChars{i});
        if isempty(expr)
            return;
        end
    end


    startIdxs=regexp(expr,'[a-zA-Z](\w*)');

    dotIdxs=regexp(expr,'\.')+1;
    startIdxs=setdiff(startIdxs,dotIdxs);

    snwidx=regexp(expr,'\W');
    if~isempty(dotIdxs)

        snwidx=setdiff(snwidx,dotIdxs-1);
        indexToDelete=[];

        if(contains(expr,'(')&&contains(expr,')'))||...
            (contains(expr,'{')&&contains(expr,'}'))
            for index=1:length(snwidx)
                if strcmp(expr(snwidx(index)),'(')||strcmp(expr(snwidx(index)),')')||...
                    strcmp(expr(snwidx(index)),'{')||strcmp(expr(snwidx(index)),'}')
                    indexToDelete=[indexToDelete,index];%#ok<*AGROW>
                end
            end
        end
        snwidx(indexToDelete)=[];
    end



    endIdxs=zeros(1,length(startIdxs));
    for ii=1:length(startIdxs)
        tmp=find(snwidx>startIdxs(ii),1);
        if~isempty(tmp)
            endIdxs(ii)=snwidx(tmp)-1;
        else
            endIdxs(ii)=length(expr);
        end
    end
    for ii=1:length(startIdxs)
        token=expr(startIdxs(ii):endIdxs(ii));




        if strcmp(token,oexpr)&&optArgs.CalledDirectly&&~Simulink.variant.utils.isTrueFalseLiteral(token)

            variantObjectNames=[variantObjectNames,token];
            break;
        end
        isSimulinkVariantObject=specialVarsInfoManager.getIsSimulinkVariantObject(token);
        if isSimulinkVariantObject


            variantObjectNames=[variantObjectNames,token];
            break;
        end

        isVariantControlVariable=optArgs.ConsiderAllAsVariables;







        if~isVariantControlVariable
            isKnownControlVariable=any(strcmp(token,optArgs.KnownControlVariables));
            isVariantControlVariable=isKnownControlVariable;
        end

        if~isVariantControlVariable



            isExistingControlVariable=specialVarsInfoManager.getIsVariable(token);
            isVariantControlVariable=isExistingControlVariable;
        end

        if~isVariantControlVariable
            existStatus=exist(token);%#ok<EXIST>



            isNotAMATLABScriptOrFunction=(existStatus==0)||(existStatus==7);
            isVariantControlVariable=isNotAMATLABScriptOrFunction;
        end

        if isVariantControlVariable
            vars{end+1}=token;
        end

        isSLExprValue=specialVarsInfoManager.getIsExpValue(token);
        if isSLExprValue



            expression=specialVarsInfoManager.getExpressionIfExpValue(token);
            optArgs.ExpressionsSoFar=[optArgs.ExpressionsSoFar,expr];


            if~any(strcmp(optArgs.ExpressionsSoFar,expression))
                optArgs.ExpressionsSoFar=[optArgs.ExpressionsSoFar,expression];
                optArgs.CalledDirectly=false;
                [varsNested,variantObjectNamesNested]=i_findVarsInVariantExpression(model,expression,optArgs);
                vars=[vars,varsNested];variantObjectNames=[variantObjectNames,variantObjectNamesNested];
            end
        end
    end
end


function i_addKeyValueToMap(map,key,value)
    Simulink.variant.utils.i_addKeyValueToMap(map,key,value);
end


function i_concatenateMaps(map,additionalMap)
    additionalKeys=additionalMap.keys;
    for i=1:numel(additionalKeys)
        i_addKeyValueToMap(map,additionalKeys{i},additionalMap(additionalKeys{i}));
    end
end


function usage=i_getVarUsage(varBlockPathInModel,childRowFromCSide,calledFromTool)

    if calledFromTool||Simulink.variant.utils.isSingleChoiceVariantInfoBlock(varBlockPathInModel)



        usage=[varBlockPathInModel,'/',childRowFromCSide.Name];

    else
        usage=varBlockPathInModel;
    end
end


