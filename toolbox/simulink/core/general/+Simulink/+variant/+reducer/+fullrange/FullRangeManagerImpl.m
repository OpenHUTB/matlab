classdef(Sealed,Hidden)FullRangeManagerImpl<Simulink.variant.reducer.fullrange.FullRangeManager




    methods(Static,Hidden,Access=public)


        function[variableGroupsModified,fullRangeAnalysisInfo]=processControlVars(rootModelName,variableGroups,fullRangeVariables)

            variableGroupsModified=variableGroups;fullRangeAnalysisInfo=[];


            if isempty(fullRangeVariables)||~isa(fullRangeVariables,'cell')
                return;
            end
            variantControlsConcat=Simulink.variant.reducer.fullrange.FullRangeManager.i_getVariantControlsConcat(variableGroups);
            sampleNameValuesForUpdate=[variantControlsConcat{1},fullRangeVariables];





            repeatForSlexpr=false;

            while(true)
                [~,variableUsageInfo,variantParameterUsageInfo]=slvariants.internal.manager.core.getVariantControlVarsWithUsages(rootModelName,true);
                varCtrlVars=variableUsageInfo.keys;
                CtrlVarsModelsMap=containers.Map;

                varCtrlParamVarsFR=intersect(variantParameterUsageInfo.keys(),fullRangeVariables(1:2:end));
                if~isempty(varCtrlParamVarsFR)


                    msg=message('Simulink:VariantReducer:FullRangeUnsupportedVariantParameters',Simulink.variant.utils.i_cell2str(varCtrlParamVarsFR));
                    err=MException(msg);
                    throwAsCaller(err);
                end

                for i=1:numel(varCtrlVars)
                    if~CtrlVarsModelsMap.isKey(varCtrlVars{i})
                        CtrlVarsModelsMap(varCtrlVars{i})={};
                    end
                    blockPaths=variableUsageInfo(varCtrlVars{i});
                    blockPathParentModels={blockPaths.ParentModelPath};
                    for j=1:numel(blockPathParentModels)
                        CtrlVarsModelsMap(varCtrlVars{i})=unique([CtrlVarsModelsMap(varCtrlVars{i}),bdroot(blockPathParentModels{j})]);
                    end
                end

                hasSLexprValue=false;

                for i=1:2:numel(sampleNameValuesForUpdate)
                    controlVarName=sampleNameValuesForUpdate{i};
                    controlVarValues=sampleNameValuesForUpdate{i+1};
                    controlVarSampleValue=controlVarValues(1);


                    hasSLexprValue=hasSLexprValue||isa(controlVarSampleValue,'Simulink.Parameter')&&isa(controlVarSampleValue.Value,'Simulink.data.Expression');

                    if~Simulink.variant.reducer.fullrange.FullRangeManager.isValidSampleValue(controlVarSampleValue)
                        msg=message('Simulink:VariantReducer:FullRangeInvalidSampleValue',controlVarName);
                        err=MException(msg);
                        throwAsCaller(err);
                    end

                    modelNames=i_getDataSourcesForCtrlVarName(controlVarName,CtrlVarsModelsMap);

                    for j=1:numel(modelNames)

                        isSimParameter=Simulink.data.evalinGlobal(modelNames{j},['(exist(''',controlVarName,''' , ''var'') == 1) && isa(',controlVarName,', ''Simulink.Parameter'')']);
                        isSLVarCtrl=Simulink.data.evalinGlobal(modelNames{j},['(exist(''',controlVarName,''' , ''var'') == 1) && isa(',controlVarName,', ''Simulink.VariantControl'')']);
                        if contains(controlVarName,'.')
                            if isSimParameter||isSLVarCtrl
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
                            elseif isSLVarCtrl
                                if isa(controlVarSampleValue,'Simulink.VariantControl')
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
                repeatForSlexpr=~repeatForSlexpr&&hasSLexprValue;
                if~repeatForSlexpr
                    break;
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
            [~,variableUsageInfo]=slvariants.internal.manager.core.getVariantControlVarsWithUsages(rootModelName,true);
            [variableGroupsModified,fullRangeAnalysisInfo]=Simulink.variant.reducer.fullrange.FullRangeManager.processControlVarsImpl(rootModelName,variableGroups,fullRangeVariables,variableUsageInfo);

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

            function modelNames=i_getDataSourcesForCtrlVarName(varName,CtrlVarsModelsMap)
                modelNames={};
                if CtrlVarsModelsMap.isKey(varName)
                    modelNames=CtrlVarsModelsMap(varName);
                end
            end
        end


        function[outputVariableGroups,fullRangeAnalysisInfo]=processControlVarsImpl(rootModelName,variableGroups,fullrangeVariables,variableUsageInfo)

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
            fullRangeAnalysisInfo=Simulink.variant.reducer.fullrange.FullRangeManager.i_InitializeFullRangeAnalysisInfo();

            isVariableGroupNameSyntaxSpecified=Simulink.variant.reducer.fullrange.FullRangeManager.i_isVariableGroupNameSyntaxSpecified(variableGroups);
            if isVariableGroupNameSyntaxSpecified
                inputVariableConfigurationFieldNames=fieldnames(variableGroups);
                groupNames={variableGroups().(inputVariableConfigurationFieldNames{1})};
            else
                groupNames={};
            end


            outputVariableGroups={};
            for variableGroupIdx=1:numel(variantControlsConcat)


                outputVariableConfigurationForDataSources=cell(1,1);
                varControlVars=variableUsageInfo.keys;
                outputVariableConfigurationForDataSources{1,1}=Simulink.variant.reducer.fullrange.FullRangeManagerImpl.getprocessedVariableConfigForADataSource(rootModelName,varControlVars,...
                variableUsageInfo,inputFullRangeControlVarsNames,variantControlsConcat{variableGroupIdx},fullRangeAnalysisInfo);

                combMatrixDataSources=Simulink.variant.reducer.fullrange.FullRangeManager.getAllCombinationsOfSpecifiedConfigs(cellfun(@(X){1:numel(X)},outputVariableConfigurationForDataSources));

                numCombinations=size(combMatrixDataSources,1);
                for i=1:numCombinations
                    thisVariableCombination=slexpControlVarsNameValuePairs;
                    thisVariableCombination=[thisVariableCombination,outputVariableConfigurationForDataSources{1,1}{combMatrixDataSources(i,1)}];%#ok<AGROW>
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



        function outputVariableConfiguration=getprocessedVariableConfigForADataSource(rootModelName,varControlVars,...
            variableUsageInfo,inputFullRangeControlVarsNames,inputVariableConfiguration,fullRangeAnalysisInfo)

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



            fullRangeControlVarNames={};blocksUsingFullRangeVars={};specifiedVariableConfigurations={};
            for i=1:numel(inputControlVarsForReducerNames)
                isInputFullRangeVarAControlVar=any(strcmp(inputControlVarsForReducerNames{i},varControlVars))&&...
                any(strcmp(inputControlVarsForReducerNames{i},inputFullRangeControlVarsNames));
                if isInputFullRangeVarAControlVar
                    fullRangeControlVarNames=[fullRangeControlVarNames,inputControlVarsForReducerNames{i}];%#ok<AGROW>
                    blockPathParentModels=variableUsageInfo(inputControlVarsForReducerNames{i});
                    blocksUsingFullRangeVars=[blocksUsingFullRangeVars,{blockPathParentModels.RootModelPath}];%#ok<AGROW>
                elseif~any(strcmp(inputControlVarsForReducerNames{i},varControlVars))



                    idxValue=Simulink.variant.reducer.fullrange.FullRangeManager.getIdxValue(inputVariableConfigurationModified,inputControlVarsForReducerNames{i});
                    inputVariableConfigurationModified(idxValue)=[];
                    inputVariableConfigurationModified(idxValue-1)=[];
                else
                    idxValue=Simulink.variant.reducer.fullrange.FullRangeManager.getIdxValue(inputVariableConfiguration,inputControlVarsForReducerNames{i});
                    specifiedVariableConfigurations=[specifiedVariableConfigurations,inputControlVarsForReducerNames{i},inputVariableConfiguration(idxValue)];%#ok<AGROW>
                end
            end

            blockUsingVars={};
            blockPathRootModelToControlVarsMap=containers.Map;
            rootModelPathToParentModelPathMap=containers.Map;
            varCtrlVars=variableUsageInfo.keys;
            for i=1:numel(varCtrlVars)
                blockPaths=variableUsageInfo(varCtrlVars{i});
                blockPathParentModels={blockPaths.ParentModelPath};
                blockPathRootModels={blockPaths.RootModelPath};
                blockUsingVars=[blockUsingVars,blockPathRootModels];%#ok<AGROW>
                for j=1:numel(blockPathRootModels)
                    if~blockPathRootModelToControlVarsMap.isKey(blockPathRootModels{j})
                        blockPathRootModelToControlVarsMap(blockPathRootModels{j})={};
                    end
                    rootModelPathToParentModelPathMap(blockPathRootModels{j})=blockPathParentModels{j};
                    blockPathRootModelToControlVarsMap(blockPathRootModels{j})=[blockPathRootModelToControlVarsMap(blockPathRootModels{j}),varCtrlVars(i)];
                end
            end

            Simulink.variant.reducer.fullrange.ErrorHandler.handleDependentFullRangeVarsInSameBlock(...
            blocksUsingFullRangeVars,blockPathRootModelToControlVarsMap);



            Simulink.variant.reducer.fullrange.ErrorHandler.ensureAACONAllFullRangeBlocks(...
            rootModelName,fullRangeControlVarNames,variableUsageInfo);


            [influentialVars,hierarchyOfLeafBlocks,blockPathRootModelToNodeMap,fullRangeVarsInfluentialVarsMap]=Simulink.variant.reducer.fullrange.FullRangeManagerImpl.getInfluentialVarsFromHierarchies(rootModelName,blockUsingVars,...
            blockPathRootModelToControlVarsMap,rootModelPathToParentModelPathMap,fullRangeControlVarNames);



            for i=1:numel(fullRangeControlVarNames)
                usages=variableUsageInfo(fullRangeControlVarNames{i});
                usages={usages.RootModelPath};
                for j=1:numel(usages)
                    Simulink.variant.reducer.fullrange.FullRangeManager.i_addKeyValuesToMap(fullRangeVarsInfluentialVarsMap,fullRangeControlVarNames{i},blockPathRootModelToControlVarsMap(usages{j}));
                    influentialVars=[influentialVars,blockPathRootModelToControlVarsMap(usages{j})];%#ok<AGROW>
                end
            end

            influentialVars=setdiff(influentialVars,fullRangeControlVarNames);


            specialVarsInfoManagerMap=containers.Map;

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

                [inactiveBlockPathsRootModel,errorStructs]=Simulink.variant.reducer.fullrange.FullRangeManagerImpl.getListOfInactiveBlocksForSpecifiedConfig(hierarchyOfLeafBlocks,blockPathRootModelToNodeMap,currentInfluentialConfig,fullRangeControlVarNames);

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
                    'SpecialVarsInfoManageMap',specialVarsInfoManagerMap);
                    fullRangeBlocks=variableUsageInfo(fullRangeControlVarNames{fullRangeControlVarNameIdx});
                    fullRangeBlocks={fullRangeBlocks.RootModelPath};
                    fullRangeBlocks=setdiff(fullRangeBlocks,inactiveBlockPathsRootModel);
                    topNode=Simulink.variant.reducer.fullrange.FullRangeManagerImpl.getHierarchyForBlocks(rootModelName,fullRangeBlocks,...
                    blockPathRootModelToControlVarsMap,rootModelPathToParentModelPathMap,specifiedVariableConfigAndAnalysisInfo);
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



        function[influentialVarNames,hierarchyOfLeafBlocks,blockPathRootModelToNodeMap,fullRangeVarsInfluentialVarsMap]=...
            getInfluentialVarsFromHierarchies(model,blockUsingVars,blockPathRootModelToControlVarsMap,rootModelPathToParentModelPathMap,fullRangeControlVarNames)


            specifiedVariableConfigAndAnalysisInfo=struct('SpecifiedVariableConfiguration',{{}},...
            'SkipComputingRanges',{true},'FullRangeCtrlVarName','');

            fullRangeVarsInfluentialVarsMap=containers.Map;
            blockUsingVars=unique(blockUsingVars);
            [topNode,blockPathRootModelToNodeMap]=Simulink.variant.reducer.fullrange.FullRangeManagerImpl.getHierarchyForBlocks(...
            model,blockUsingVars,blockPathRootModelToControlVarsMap,rootModelPathToParentModelPathMap,specifiedVariableConfigAndAnalysisInfo);
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



        function[topNode,blockPathRootModelToNodeMap]=getHierarchyForBlocks(model,specifiedBlocks,blockPathRootModelToControlVarsMap,rootModelPathToParentModelPathMap,specifiedVariableConfigAndAnalysisInfo)
            blockPathRootModelToNodeMap=containers.Map();
            topNode=Simulink.variant.reducer.fullrange.VariantNode(model,model,Simulink.variant.reducer.VariantBlockType.MODEL,[],[],specifiedVariableConfigAndAnalysisInfo.FullRangeCtrlVarName,specifiedVariableConfigAndAnalysisInfo);
            blockPathRootModelToNodeMap(model)=topNode;
            for i=1:numel(specifiedBlocks)
                blockPathRootModel=specifiedBlocks{i};
                blockPathParentModel=rootModelPathToParentModelPathMap(blockPathRootModel);
                ctrlVarNames=blockPathRootModelToControlVarsMap(specifiedBlocks{i});
                switch get_param(blockPathParentModel,'BlockType')
                case 'SubSystem'
                    [isVariantSimulinkFunction,portH]=Simulink.variant.utils.isVariantSimulinkFunction(blockPathParentModel);
                    if isVariantSimulinkFunction
                        variants={get_param(portH,'VariantControl')};
                        variantBlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_SIMULINK_FUNCTION;
                    else
                        [isVariantIRTSubsystem,portH]=Simulink.variant.utils.isVariantIRTSubsystem(blockPathParentModel);
                        if isVariantIRTSubsystem
                            variants={get_param(portH,'VariantControl')};
                            variantBlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_IRT_SUBSYSTEM;
                        else
                            isVariant=strcmp(get_param(blockPathParentModel,'Variant'),'on');
                            if isVariant
                                variants=get_param(blockPathParentModel,'Variants');
                                variants={variants().Name}';
                                variantBlockType=Simulink.variant.reducer.VariantBlockType.VARIANT_SUBSYSTEM;
                            end
                        end
                    end
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

