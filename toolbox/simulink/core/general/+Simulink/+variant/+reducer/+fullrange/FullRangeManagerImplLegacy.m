classdef(Sealed,Hidden)FullRangeManagerImplLegacy<Simulink.variant.reducer.fullrange.FullRangeManager




    methods(Static,Hidden,Access=public)


        function[variableGroupsModified,fullRangeAnalysisInfo]=processControlVars(rootModelName,variableGroups,fullRangeVariables)

...
...
...
...
...
...
...
...


            variableGroupsModified=variableGroups;fullRangeAnalysisInfo=[];


            if isempty(fullRangeVariables)||~isa(fullRangeVariables,'cell')
                return;
            end
            variantControlsConcat=Simulink.variant.reducer.fullrange.FullRangeManager.i_getVariantControlsConcat(variableGroups);
            varNameExtractFun=@(X)(X(1:2:end));
            inputCtrlVarNamesCell=cellfun(varNameExtractFun,variantControlsConcat,'UniformOutput',false);
            inputControlVarNames=unique([inputCtrlVarNamesCell{1:end}]);

            sampleNameValuesForUpdate=[variantControlsConcat{1},fullRangeVariables];




            optArgs=Simulink.variant.utils.getControlVariableNamesFromVariantExpressionsOptArgs();
            optArgs.RecurseIntoModelReferences=true;optArgs.KnownControlVariables=inputControlVarNames;

            allHierarchicalModels=[rootModelName,Simulink.variant.utils.i_find_mdlrefs(rootModelName,struct('RecurseIntoModelReferences',true))];
            specialVarsInfoManagerMap=containers.Map();
            for i=1:numel(allHierarchicalModels)
                specialVarsInfoManager=Simulink.variant.manager.SpecialVarsInfoManager(allHierarchicalModels{i});
                specialVarsInfoManager.setUseRestrictedDataForSimulinkParameterIsExpValueMap(sampleNameValuesForUpdate);
                specialVarsInfoManagerMap(allHierarchicalModels{i})=specialVarsInfoManager;
            end
            optArgs.SpecialVarsInfoManagerMap=specialVarsInfoManagerMap;


            varControlVarsInfo=struct();
            [~,varControlVarsInfo.VariableUsageInfo,varControlVarsInfo.SourceInfo,varControlVarsInfo.Errors]=...
            Simulink.variant.utils.getControlVariableNamesFromVariantExpressions(rootModelName,optArgs);
            sampleNameValuesForUpdate=[variantControlsConcat{1},fullRangeVariables];
            for i=1:2:numel(sampleNameValuesForUpdate)
                controlVarName=sampleNameValuesForUpdate{i};
                controlVarValues=sampleNameValuesForUpdate{i+1};
                controlVarSampleValue=controlVarValues(1);

                if~Simulink.variant.reducer.fullrange.FullRangeManager.isValidSampleValue(controlVarSampleValue)
                    msg=message('Simulink:VariantReducer:FullRangeInvalidSampleValue',controlVarName);
                    err=MException(msg);
                    throwAsCaller(err);
                end

                modelNames=i_getDataSourcesForCtrlVarName(controlVarName,varControlVarsInfo.SourceInfo);

                for j=1:numel(modelNames)

                    isSimParameter=Simulink.data.evalinGlobal(modelNames{j},['(exist(''',controlVarName,''' , ''var'') == 1) && isa(',controlVarName,', ''Simulink.Parameter'')']);
                    if contains(controlVarName,'.')
                        if isSimParameter
                            expression=[controlVarName,'.Value = ',num2str(controlVarSampleValue),';'];
                        else
                            expression=[controlVarName,' = ',num2str(controlVarSampleValue),';'];
                        end
                        Simulink.data.evalinGlobal(modelNames{j},expression);
                    else
                        if isSimParameter
                            if isa(controlVarSampleValue,'Simulink.Parameter')
                                controlVarSampleValue=controlVarSampleValue.Value;
                            end


                            valueToPushGws=Simulink.data.evalinGlobal(modelNames{j},controlVarName);
                            valueToPushGws.Value=controlVarSampleValue;
                        else
                            valueToPushGws=controlVarSampleValue;
                        end
                        assigninGlobalScope(modelNames{j},controlVarName,valueToPushGws);
                    end
                end
            end


            try
                set_param(rootModelName,'SimulationCommand','update');
            catch ME
                msg=message('Simulink:VariantReducer:FullRangeModelFailedToUpdate',rootModelName,...
                Simulink.variant.reducer.fullrange.FullRangeManager.convertSpecifiedVariableConfigurationToStr(sampleNameValuesForUpdate));
                err=MException(msg);
                err=err.addCause(ME);
                throwAsCaller(err);
            end
            [variableGroupsModified,fullRangeAnalysisInfo]=Simulink.variant.reducer.fullrange.FullRangeManager.processControlVarsImpl(rootModelName,variableGroups,fullRangeVariables,varControlVarsInfo);

            if~isempty(fullRangeAnalysisInfo)
                variantBlocks=fullRangeAnalysisInfo.FullRangeConditionsMap.keys;
                for i=1:numel(variantBlocks)
                    choiceModificationMap=containers.Map;
                    choiceModifications=fullRangeAnalysisInfo.FullRangeConditionsMap(variantBlocks{i});
                    for j=1:numel(choiceModifications)
                        Simulink.variant.utils.i_addKeyValueToMap(choiceModificationMap,...
                        choiceModifications{j}.CondOrig,...
                        {Simulink.variant.reducer.fullrange.FullRangeManager.simplifyVarCondExpr(choiceModifications{j}.CondRed)});
                    end

                    choicesToModify=choiceModificationMap.keys;
                    for j=1:numel(choicesToModify)
                        choiceModificationMap(choicesToModify{j})=...
                        Simulink.variant.reducer.fullrange.combineByOR(choiceModificationMap(choicesToModify{j}));
                    end
                    fullRangeAnalysisInfo.FullRangeConditionsMap(variantBlocks{i})=choiceModificationMap;
                end
            end

            function modelNames=i_getDataSourcesForCtrlVarName(varName,sourceInfo)
                modelNames={};
                dataSources=sourceInfo.DataDictionaryToModelsMap.keys;
                for dsi=1:numel(dataSources)
                    if any(strcmp(varName,sourceInfo.DataDictionaryToVarsMap(dataSources{dsi})))
                        models=sourceInfo.DataDictionaryToModelsMap(dataSources{dsi});
                        modelNames=[modelNames,models];%#ok<AGROW>
                    end
                end
            end
        end


        function[outputVariableGroups,fullRangeAnalysisInfo]=processControlVarsImpl(rootModelName,variableGroups,fullrangeVariables,varControlVarsInfo)
            slexpControlVarsNameValuePairs={};
            for i=numel(fullrangeVariables):-2:2
                if isa(fullrangeVariables{i},'Simulink.Parameter')&&isa(fullrangeVariables{i}.Value,'Simulink.data.Expression')
                    slexpControlVarsNameValuePairs=[slexpControlVarsNameValuePairs,fullrangeVariables(i-1),fullrangeVariables(i)];%#ok<AGROW>
                    fullrangeVariables{i}=[];
                    fullrangeVariables{i-1}=[];
                end
            end
            inputFullRangeControlVarsNames=fullrangeVariables(1:2:end);
            variantControlsConcat=Simulink.variant.reducer.fullrange.FullRangeManager.i_getVariantControlsConcat(variableGroups);



            for i=1:numel(variantControlsConcat)
                for j=numel(variantControlsConcat{i}):-2:2
                    if isa(variantControlsConcat{i}{j},'Simulink.Parameter')
                        if isa(variantControlsConcat{i}{j}(1).Value,'Simulink.data.Expression')
                            if i==1


                                slexpControlVarsNameValuePairs=[slexpControlVarsNameValuePairs,variantControlsConcat{i}(j-1),variantControlsConcat{i}(j)];%#ok<AGROW>
                            end
                            variantControlsConcat{i}(j)=[];
                            variantControlsConcat{i}(j-1)=[];
                        else
                            variantControlsConcat{i}{j}=arrayfun(@(X)(X.Value),variantControlsConcat{i}{j});
                        end
                    end
                end
            end
            variableUsageInfo=varControlVarsInfo.VariableUsageInfo;
            sourceInfo=varControlVarsInfo.SourceInfo;
            fullRangeAnalysisInfo=Simulink.variant.reducer.fullrange.FullRangeManager.i_InitializeFullRangeAnalysisInfo();

            isVariableGroupNameSyntaxSpecified=Simulink.variant.reducer.fullrange.FullRangeManager.i_isVariableGroupNameSyntaxSpecified(variableGroups);
            if isVariableGroupNameSyntaxSpecified
                inputVariableConfigurationFieldNames=fieldnames(variableGroups);
                groupNames={variableGroups().(inputVariableConfigurationFieldNames{1})};
            else
                groupNames={};
            end

            dataSources=sourceInfo.DataDictionaryToVarsMap.keys;




            controlVarToSourceMap=containers.Map;
            for dataSourceIdx=1:numel(dataSources)
                dataSource=dataSources{dataSourceIdx};
                ControlVarToBlockUsageMap=variableUsageInfo.ControlVarToBlockUsageMap(dataSource);
                varControlVars=sourceInfo.DataDictionaryToVarsMap(dataSource);
                for varControlVarIdx=1:numel(varControlVars)
                    varControlVar=varControlVars{varControlVarIdx};
                    if controlVarToSourceMap.isKey(varControlVar)

                        commonUsage=variableUsageInfo.ControlVarToBlockUsageMap(controlVarToSourceMap(varControlVar));
                        commonUsage(varControlVar)=[commonUsage(varControlVar),ControlVarToBlockUsageMap(varControlVar)];%#ok<NASGU>

                        sourceInfo.DataDictionaryToVarsMap(dataSource)=setdiff(sourceInfo.DataDictionaryToVarsMap(dataSource),varControlVar);
                        ControlVarToBlockUsageMap.remove(varControlVar);
                    else

                        controlVarToSourceMap(varControlVar)=dataSource;
                    end
                end
            end

            outputVariableGroups={};
            for variableGroupIdx=1:numel(variantControlsConcat)


                outputVariableConfigurationForDataSources=cell(1,numel(dataSources));
                for dataSourceIdx=1:numel(dataSources)
                    ControlVarToBlockUsageMap=variableUsageInfo.ControlVarToBlockUsageMap(dataSources{dataSourceIdx});
                    varControlVars=sourceInfo.DataDictionaryToVarsMap(dataSources{dataSourceIdx});

                    modelsUsingDD=sourceInfo.DataDictionaryToModelsMap(dataSources{dataSourceIdx});
                    specialVarsInfoManager=sourceInfo.SpecialVarsInfoManagerMap(modelsUsingDD{1});

                    outputVariableConfigurationForDataSources{1,dataSourceIdx}=Simulink.variant.reducer.fullrange.FullRangeManagerImplLegacy.getprocessedVariableConfigForADataSource(rootModelName,varControlVars,...
                    ControlVarToBlockUsageMap,variableUsageInfo,specialVarsInfoManager,inputFullRangeControlVarsNames,variantControlsConcat{variableGroupIdx},fullRangeAnalysisInfo);
                end

                combMatrixDataSources=Simulink.variant.reducer.fullrange.FullRangeManager.getAllCombinationsOfSpecifiedConfigs(cellfun(@(X){1:numel(X)},outputVariableConfigurationForDataSources));
                numCombinations=size(combMatrixDataSources,1);
                for i=1:numCombinations
                    thisVariableCombination=slexpControlVarsNameValuePairs;
                    for j=1:numel(dataSources)
                        thisVariableCombination=[thisVariableCombination,outputVariableConfigurationForDataSources{1,j}{combMatrixDataSources(i,j)}];%#ok<AGROW>
                    end

                    if isVariableGroupNameSyntaxSpecified
                        outputVariableGroups{end+1}=struct(inputVariableConfigurationFieldNames{1},groupNames{variableGroupIdx},inputVariableConfigurationFieldNames{2},{thisVariableCombination});%#ok<AGROW>
                    else
                        outputVariableGroups{end+1}=thisVariableCombination;%#ok<AGROW>
                    end
                end
            end
            if isVariableGroupNameSyntaxSpecified

                outputVariableGroups=[outputVariableGroups{1:end}];
            end
        end



        function outputVariableConfiguration=getprocessedVariableConfigForADataSource(rootModelName,varControlVars,ControlVarToBlockUsageMap,...
            variableUsageInfo,specialVarsInfoManager,inputFullRangeControlVarsNames,inputVariableConfiguration,fullRangeAnalysisInfo)

            inputControlVarsForReducerNames=[inputVariableConfiguration(1:2:end),inputFullRangeControlVarsNames];

            for i=2:2:(numel(inputVariableConfiguration)-1)
                if isa(inputVariableConfiguration{i},'Simulink.Parameter')
                    inputVariableConfiguration{i}=arrayfun(@(x)(x.Value),inputVariableConfiguration{i});
                end
            end

            Simulink.variant.reducer.utils.assert(...
            all(cellfun(@(X)(isa(X,'char')||isa(X,'string')||isa(X,'numeric')||isa(X,'cell')),...
            inputVariableConfiguration)));
            inputVariableConfigurationModified=inputVariableConfiguration;
            rootModelPathToParentModelPathMap=variableUsageInfo.RootModelPathToParentModelPathMap;



            fullRangeControlVarNames={};blocksUsingFullRangeVars={};specifiedVariableConfigurations={};
            for i=1:numel(inputControlVarsForReducerNames)
                isInputFullRangeVarAControlVar=any(strcmp(inputControlVarsForReducerNames{i},varControlVars))&&...
                any(strcmp(inputControlVarsForReducerNames{i},inputFullRangeControlVarsNames));
                if isInputFullRangeVarAControlVar
                    fullRangeControlVarNames=[fullRangeControlVarNames,inputControlVarsForReducerNames{i}];%#ok<AGROW>
                    blocksUsingFullRangeVars=[blocksUsingFullRangeVars,ControlVarToBlockUsageMap(inputControlVarsForReducerNames{i})];%#ok<AGROW>
                elseif~any(strcmp(inputControlVarsForReducerNames{i},varControlVars))



                    idxValue=Simulink.variant.reducer.fullrange.FullRangeManager.getIdxValue(inputVariableConfigurationModified,inputControlVarsForReducerNames{i});
                    inputVariableConfigurationModified(idxValue)=[];
                    inputVariableConfigurationModified(idxValue-1)=[];
                else
                    idxValue=Simulink.variant.reducer.fullrange.FullRangeManager.getIdxValue(inputVariableConfiguration,inputControlVarsForReducerNames{i});
                    specifiedVariableConfigurations=[specifiedVariableConfigurations,inputControlVarsForReducerNames{i},inputVariableConfiguration(idxValue)];%#ok<AGROW>
                end
            end



            blockPathRootModelToControlVarsMap=Simulink.variant.utils.i_invertMap(ControlVarToBlockUsageMap);
            Simulink.variant.reducer.fullrange.ErrorHandler.handleDependentFullRangeVarsInSameBlock(...
            blocksUsingFullRangeVars,blockPathRootModelToControlVarsMap);



            Simulink.variant.reducer.fullrange.ErrorHandler.ensureAACONAndNOMRVForAllFullRangeBlocks(...
            rootModelName,fullRangeControlVarNames,ControlVarToBlockUsageMap,rootModelPathToParentModelPathMap);

            blockUsingVars={};
            for i=1:numel(varControlVars)
                blockUsingVars=[blockUsingVars,ControlVarToBlockUsageMap(varControlVars{i})];%#ok<AGROW>
            end


            [influentialVars,hierarchyOfLeafBlocks,blockPathRootModelToNodeMap,fullRangeVarsInfluentialVarsMap]=Simulink.variant.reducer.fullrange.FullRangeManagerImplLegacy.getInfluentialVarsFromHierarchies(rootModelName,blockUsingVars,...
            rootModelPathToParentModelPathMap,blockPathRootModelToControlVarsMap,fullRangeControlVarNames);



            for i=1:numel(fullRangeControlVarNames)
                usages=ControlVarToBlockUsageMap(fullRangeControlVarNames{i});
                for j=1:numel(usages)
                    Simulink.variant.reducer.fullrange.FullRangeManager.i_addKeyValuesToMap(fullRangeVarsInfluentialVarsMap,fullRangeControlVarNames{i},blockPathRootModelToControlVarsMap(usages{j}));
                    influentialVars=[influentialVars,blockPathRootModelToControlVarsMap(usages{j})];%#ok<AGROW>
                end
            end

            influentialVars=setdiff(influentialVars,fullRangeControlVarNames);


            influentialVariableConfig={};nonInfluentialVariableConfig={};
            for i=1:2:numel(specifiedVariableConfigurations)
                specifiedVars=specifiedVariableConfigurations(i+1);
                if numel(specifiedVars)>1
                    specifiedVars=specifiedVars(1);
                end



                if any(strcmp(specifiedVariableConfigurations{i},influentialVars))
                    influentialVariableConfig=[influentialVariableConfig,specifiedVariableConfigurations{i},specifiedVars];%#ok<AGROW>
                else
                    nonInfluentialVariableConfig=[nonInfluentialVariableConfig,specifiedVariableConfigurations{i},specifiedVars];%#ok<AGROW>
                end
            end

            outputVariableConfiguration={};
            if isempty(influentialVariableConfig)
                influentialVariableConfigValuesComb={};
                numInfluentialVariableConfigs=1;
            else
                influentialVariableConfigValuesComb=Simulink.variant.reducer.fullrange.FullRangeManager.getAllCombinationsOfSpecifiedConfigs(influentialVariableConfig(2:2:end));
                numInfluentialVariableConfigs=size(influentialVariableConfigValuesComb,1);
            end

            for influentialVariableConfigIdx=1:numInfluentialVariableConfigs

                currentInfluentialConfig={};
                for influentialVarNameIdx=1:2:(numel(influentialVariableConfig)-1)
                    currentInfluentialConfig=[currentInfluentialConfig,influentialVariableConfig{influentialVarNameIdx},influentialVariableConfigValuesComb(influentialVariableConfigIdx,(influentialVarNameIdx+1)/2)];%#ok<AGROW>
                end

                [inactiveBlockPathsRootModel,errorStructs]=Simulink.variant.reducer.fullrange.FullRangeManager.getListOfInactiveBlocksForSpecifiedConfig(hierarchyOfLeafBlocks,blockPathRootModelToNodeMap,currentInfluentialConfig,fullRangeControlVarNames);

                if~isempty(errorStructs)
                    errorString='';

                    for j=1:numel(errorStructs)
                        errorString=[errorString,errorStructs(j).message];%#ok<AGROW>
                    end
                    msg=message('Simulink:VariantReducer:FullRangeUnableToDetermineActiveBlocks',rootModelName,...
                    Simulink.variant.reducer.fullrange.FullRangeManager.convertSpecifiedVariableConfigurationToStr(currentInfluentialConfig),errorString);
                    err=MException(msg);
                    Simulink.variant.reducer.fullrange.ErrorHandler.handleErrors(rootModelName,err);
                end

                currentFullRangeConfig={};
                hasEmptyFullRangeVars=false;
                for fullRangeControlVarNameIdx=1:numel(fullRangeControlVarNames)


                    specifiedVariableConfigAndAnalysisInfo=struct('SpecifiedVariableConfiguration',{currentInfluentialConfig},...
                    'SkipComputingRanges',{false},...
                    'FullRangeCtrlVarName',fullRangeControlVarNames{fullRangeControlVarNameIdx},...
                    'FullRangeVarsInfluentialVarsMap',fullRangeVarsInfluentialVarsMap,...
                    'FullRangeConditionsMap',fullRangeAnalysisInfo.FullRangeConditionsMap,...
                    'SpecialVarsInfoManager',specialVarsInfoManager);
                    fullRangeBlocks=setdiff(ControlVarToBlockUsageMap(fullRangeControlVarNames{fullRangeControlVarNameIdx}),inactiveBlockPathsRootModel);
                    topNode=Simulink.variant.reducer.fullrange.FullRangeManagerImplLegacy.getHierarchyForBlocks(rootModelName,fullRangeBlocks,...
                    rootModelPathToParentModelPathMap,blockPathRootModelToControlVarsMap,specifiedVariableConfigAndAnalysisInfo);
                    topNode.validateRanges();
                    fullRangeControlVarValues=topNode.computeControlVarValues();
                    if isempty(fullRangeControlVarValues)


                        hasEmptyFullRangeVars=true;
                        break;
                    else
                        currentFullRangeConfig=[currentFullRangeConfig,fullRangeControlVarNames{fullRangeControlVarNameIdx},fullRangeControlVarValues];%#ok<AGROW>
                    end
                end
                if~hasEmptyFullRangeVars



                    outputVariableConfiguration{end+1}=[nonInfluentialVariableConfig,currentInfluentialConfig,currentFullRangeConfig];%#ok<AGROW>
                end
            end
        end



        function[influentialVarNames,hierarchyOfLeafBlocks,blockPathRootModelToNodeMap,fullRangeVarsInfluentialVarsMap]=getInfluentialVarsFromHierarchies(model,blockUsingVars,rootModelPathToParentModelPathMap,blockPathRootModelToControlVarsMap,fullRangeControlVarNames)


            specifiedVariableConfigAndAnalysisInfo=struct('SpecifiedVariableConfiguration',{{}},...
            'SkipComputingRanges',{true},'FullRangeCtrlVarName','');

            fullRangeVarsInfluentialVarsMap=containers.Map;
            blockUsingVars=unique(blockUsingVars);
            [topNode,blockPathRootModelToNodeMap]=Simulink.variant.reducer.fullrange.FullRangeManagerImplLegacy.getHierarchyForBlocks(model,blockUsingVars,rootModelPathToParentModelPathMap,blockPathRootModelToControlVarsMap,specifiedVariableConfigAndAnalysisInfo);
            hierarchyOfLeafBlocks=topNode.getCtrlVarHierarchy();
            varNameParentVarNamesMap=containers.Map();




            for i=1:numel(hierarchyOfLeafBlocks)
                hierarchyOfLeafBlock=hierarchyOfLeafBlocks{i};
                parentVarsSoFar={};
                for j=1:numel(hierarchyOfLeafBlock)
                    varNames=hierarchyOfLeafBlock(j).VarName;
                    for k=1:numel(parentVarsSoFar)
                        Simulink.variant.reducer.fullrange.FullRangeManager.i_addKeysValueToMap(varNameParentVarNamesMap,varNames,parentVarsSoFar{k});
                    end
                    parentVarsSoFar=[parentVarsSoFar,varNames];%#ok<AGROW>
                end
            end

            influentialVarNames={};
            for fullRangeControlVarNameIdx=1:numel(fullRangeControlVarNames)
                if varNameParentVarNamesMap.isKey(fullRangeControlVarNames{fullRangeControlVarNameIdx})
                    Simulink.variant.reducer.fullrange.FullRangeManager.i_addKeyValuesToMap(fullRangeVarsInfluentialVarsMap,fullRangeControlVarNames{fullRangeControlVarNameIdx},varNameParentVarNamesMap(fullRangeControlVarNames{fullRangeControlVarNameIdx}));
                    influentialVarNames=[influentialVarNames,varNameParentVarNamesMap(fullRangeControlVarNames{fullRangeControlVarNameIdx})];%#ok<AGROW>
                end
            end
            influentialVarNames=unique(influentialVarNames);
        end



        function[topNode,blockPathRootModelToNodeMap]=getHierarchyForBlocks(model,specifiedBlocks,rootModelPathToParentModelPathMap,blockPathRootModelToControlVarsMap,specifiedVariableConfigAndAnalysisInfo)
            blockPathRootModelToNodeMap=containers.Map();
            topNode=Simulink.variant.reducer.fullrange.VariantNode(model,model,Simulink.variant.reducer.VariantBlockType.MODEL,[],[],specifiedVariableConfigAndAnalysisInfo.FullRangeCtrlVarName,specifiedVariableConfigAndAnalysisInfo);
            blockPathRootModelToNodeMap(model)=topNode;
            for i=1:numel(specifiedBlocks)
                blockPathRootModel=specifiedBlocks{i};
                blockPathParentModel=rootModelPathToParentModelPathMap(blockPathRootModel);
                ctrlVarNames=blockPathRootModelToControlVarsMap(specifiedBlocks{i});
                switch get_param(blockPathParentModel,'BlockType')
                case 'SubSystem'
                    variants=get_param(blockPathParentModel,'Variants');
                    variants={variants().Name}';
                    variantBlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_SUBSYSTEM;
                case{'VariantSink','VariantSource'}
                    variants=get_param(blockPathParentModel,'VariantControls');
                    variantBlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_SOURCE;
                case{'ModelReference'}
                    if strcmp(get_param(blockPathParentModel,'Variant'),'on')
                        variants=get_param(blockPathParentModel,'Variants');
                        variants={variants().Name}';
                        variantBlockType=Simulink.variant.reducer.VariantBlockType.MODEL_VARIANT;
                    else
                        continue;
                    end
                case{'EventListener'}
                    variants={get_param(blockPathParentModel,'VariantControl')};
                    variantBlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_IRT_SUBSYSTEM;
                case{'TriggerPort'}
                    variants={get_param(blockPathParentModel,'VariantControl')};
                    variantBlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_SIMULINK_FUNCTION;
                otherwise
                    Simulink.variant.reducer.utils.assert(false);
                end
                parentRow=Simulink.variant.reducer.fullrange.FullRangeManager.i_getParentRow(blockPathRootModel,blockPathRootModelToNodeMap);
                blockPathRootModelToNodeMap(blockPathRootModel)=Simulink.variant.reducer.fullrange.VariantNode(...
                blockPathParentModel,blockPathRootModel,variantBlockType,...
                parentRow,variants,ctrlVarNames,specifiedVariableConfigAndAnalysisInfo);
            end
        end
    end
end
