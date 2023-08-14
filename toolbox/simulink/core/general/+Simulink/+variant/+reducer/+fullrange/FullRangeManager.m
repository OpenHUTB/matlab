classdef(Hidden)FullRangeManager








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
            if slfeature('VMGRV2UI')>0
                [variableGroupsModified,fullRangeAnalysisInfo]=Simulink.variant.reducer.fullrange.FullRangeManagerImpl.processControlVars(rootModelName,variableGroups,fullRangeVariables);
            else
                [variableGroupsModified,fullRangeAnalysisInfo]=Simulink.variant.reducer.fullrange.FullRangeManagerImplLegacy.processControlVars(rootModelName,variableGroups,fullRangeVariables);
            end
        end


        function[outputVariableGroups,fullRangeAnalysisInfo]=processControlVarsImpl(rootModelName,variableGroups,fullrangeVariables,varControlVarsInfo)
            if slfeature('VMGRV2UI')>0
                [outputVariableGroups,fullRangeAnalysisInfo]=Simulink.variant.reducer.fullrange.FullRangeManagerImpl.processControlVarsImpl(rootModelName,variableGroups,fullrangeVariables,varControlVarsInfo);
            else
                [outputVariableGroups,fullRangeAnalysisInfo]=Simulink.variant.reducer.fullrange.FullRangeManagerImplLegacy.processControlVarsImpl(rootModelName,variableGroups,fullrangeVariables,varControlVarsInfo);
            end
        end



        function node=i_getParentRow(blockPathRootModel,blockPathRootModelToNodeMap)
            subsystemBlocksInHierarchy=Simulink.variant.utils.splitPathInHierarchy(blockPathRootModel);
            for j=numel(subsystemBlocksInHierarchy)-1:-1:1
                parentSubsystemInHierarchy=strjoin(subsystemBlocksInHierarchy(1:j),'/');
                if blockPathRootModelToNodeMap.isKey(parentSubsystemInHierarchy)
                    node=blockPathRootModelToNodeMap(parentSubsystemInHierarchy);
                    return;
                end
            end
            node=[];
        end

        function simplifiedExpr=applySpecifiedConfigAndSimplifyExpression(expr,specifiedConfig)
            substitutedExpr=regexprep(expr,cellfun(@(X)['\<',X,'\>'],specifiedConfig(1:2:end),'UniformOutput',false),...
            cellfun(@(X)(num2str(X)),specifiedConfig(2:2:end),'UniformOutput',false));
            simplifiedExpr=Simulink.variant.reducer.fullrange.FullRangeManager.simplifyVarCondExpr(substitutedExpr);
        end

        function simplifiedExpr=simplifyVarCondExpr(expr)
            simplifiedExpr=slInternal('SimplifyVarCondExpr',expr);
            if isempty(simplifiedExpr)

                simplifiedExpr='true';
            end
        end

        function str=convertSpecifiedVariableConfigurationToStr(specifiedVariableConfiguration)
            str='';
            for i=1:2:(numel(specifiedVariableConfiguration)-1)
                ctrlVarValue=specifiedVariableConfiguration{i+1};
                str=[str,specifiedVariableConfiguration{i},'=',Simulink.variant.reducer.utils.convertCVV2String(ctrlVarValue(1)),', '];%#ok<AGROW>
            end
            if~isempty(str)

                str(end-1:end)=[];
            end
        end



        function variantControlsConcat=i_getVariantControlsConcat(variableGroups)
            if Simulink.variant.reducer.fullrange.FullRangeManager.i_isVariableGroupNameSyntaxSpecified(variableGroups)
                inputVariableConfigurationFieldNames=fieldnames(variableGroups);
                variantControlsConcat={variableGroups().(inputVariableConfigurationFieldNames{2})};
            else
                assert(Simulink.variant.reducer.fullrange.FullRangeManager.i_isNestedVariableGroupsCellSyntax(variableGroups));
                variantControlsConcat=variableGroups;
            end
        end


        function i_addKeysValueToMap(map,keys,value)
            for i=1:numel(keys)
                Simulink.variant.reducer.fullrange.FullRangeManager.i_addKeyValueToMap(map,keys{i},value);
            end
        end


        function i_addKeyValuesToMap(map,key,value)
            if numel(value)==0
                i_addKeyValueToMap(map,key,{});
                return;
            end
            cellfun(@(X)(Simulink.variant.reducer.fullrange.FullRangeManager.i_addKeyValueToMap(map,key,X)),value);
        end


        function i_addKeyValueToMap(map,key,value)
            Simulink.variant.utils.i_addKeyValueToMap(map,key,{value})
        end


        function fullRangeAnalysisInfo=i_InitializeFullRangeAnalysisInfo()
            fullRangeAnalysisInfo=struct('FullRangeConditionsMap',containers.Map);
        end



        function isVariableGroupNameSyntaxSpecified=i_isVariableGroupNameSyntaxSpecified(inputVariableConfigurationOrig)
            isVariableGroupNameSyntaxSpecified=isstruct(inputVariableConfigurationOrig)&&...
            Simulink.variant.reducer.utils.isVarGroupNameSyntaxStructValid(inputVariableConfigurationOrig);
        end




        function isNestedVariableGroupsCellSyntax=i_isNestedVariableGroupsCellSyntax(inputVariableConfigurationOrig)
            isNestedVariableGroupsCellSyntax=isa(inputVariableConfigurationOrig,'cell')&&...
            (numel(inputVariableConfigurationOrig)>0)&&all(cellfun(@(X)(isa(X,'cell')),inputVariableConfigurationOrig));
        end



        function idx=getIdxValue(X,name)
            idx=1+find(strcmp(X,name),1);
        end


        function isValid=isValidSampleValue(X)
            isValidSampleValueFun=@(y)(isnumeric(y)||(isa(y,'Simulink.Parameter')&&((isa(y.Value,'Simulink.data.Expression'))||(~isempty(y.Value)&&~isnan(y.Value)))));
            isValid=any(arrayfun(@(x)(isValidSampleValueFun(x)),X));
        end

        function combs=getAllCombinationsOfSpecifiedConfigs(cellOfValues)
            N=numel(cellOfValues);
            combs=cell(1,N);
            [combs{end:-1:1}]=ndgrid(cellOfValues{end:-1:1});
            combs=cat(N+1,combs{:});
            combs=reshape(combs,[],N);
        end




        function[inactiveRootModelPaths,errors]=getListOfInactiveBlocksForSpecifiedConfig(hierarchyOfLeafBlocks,blockPathRootModelToNodeMap,currentInfluentialConfig,fullRangeControlVarNames)

            inactiveRootModelPaths={};
            VariantBlockActiveChoiceNameMap=containers.Map();
            ModelsWithSetupTmpWksMap=containers.Map();
            errors=[];

            for i=1:numel(hierarchyOfLeafBlocks)
                hierarchyOfLeafBlock=hierarchyOfLeafBlocks{i};
                lastIdx=0;
                for j=numel(hierarchyOfLeafBlock):-1:1


                    if~isempty(intersect(hierarchyOfLeafBlock(j).VarName,fullRangeControlVarNames))


                        lastIdx=j;
                        break;
                    end
                end
                hierarchyOfLeafBlock=hierarchyOfLeafBlock(1:lastIdx);
                isInactiveHierarchy=false;
                for j=1:numel(hierarchyOfLeafBlock)
                    blockPathRootModel=hierarchyOfLeafBlock(j).BlockName;
                    if isInactiveHierarchy
                        inactiveRootModelPaths=[inactiveRootModelPaths,blockPathRootModel];%#ok<AGROW>
                        continue;
                    end

                    parentVariantBlockRow=Simulink.variant.reducer.fullrange.FullRangeManager.i_getParentRow(hierarchyOfLeafBlock(j).BlockName,blockPathRootModelToNodeMap);
                    isParentBlockRowIntroducingVariantHierarchy=(...
                    parentVariantBlockRow.mVariantBlockType.isVariantSubsystem()...
                    &&Simulink.variant.reducer.utils.isAnalyzeAllChoicesDisabled(parentVariantBlockRow.mBlockPathParentModel))...
                    ||parentVariantBlockRow.mVariantBlockType.isModelVariant();

                    if isParentBlockRowIntroducingVariantHierarchy
                        choiceName=getParentChoiceName(parentVariantBlockRow.mBlockPathRootModel,blockPathRootModel);
                        isInactiveHierarchy=isVariantChoiceInactive(parentVariantBlockRow.mBlockPathParentModel,choiceName);
                        if isInactiveHierarchy
                            inactiveRootModelPaths=[inactiveRootModelPaths,blockPathRootModel];%#ok<AGROW>
                        end
                    end
                end
            end


            function isInactive=isVariantChoiceInactive(parentBlockPathParentModel,parentChoiceName)


                pathsInHierarchyParentBlock=Simulink.variant.utils.splitPathInHierarchy(parentBlockPathParentModel);
                parentModelName=pathsInHierarchyParentBlock{1};




                if~ModelsWithSetupTmpWksMap.isKey(parentModelName)
                    for valIdx=2:2:numel(currentInfluentialConfig)
                        if isnumeric(currentInfluentialConfig{valIdx})
                            currentInfluentialConfig{valIdx}=num2str(currentInfluentialConfig{valIdx});
                        end
                    end
                    controlVarsStruct=struct('Name',currentInfluentialConfig(1:2:end),'Value',currentInfluentialConfig(2:2:end));
                    errs=Simulink.variant.manager.configutils.setupWorkspaceForVariantConfig(get_param(parentModelName,'Handle'),'',controlVarsStruct,struct('SkipAssigninGlobalWkspce',true));

                    if~isempty(errs)
                        errors=[errors,errs];
                    end
                    ModelsWithSetupTmpWksMap(parentModelName)=true;
                end

                if~isempty(errors)
                    isInactive=false;
                    return;
                end
                if~VariantBlockActiveChoiceNameMap.isKey(parentBlockPathParentModel)
                    infoFromCSide=Simulink.variant.utils.getVariantBlockInfoForVM(parentBlockPathParentModel,struct('UseTempWS',true,'IgnoreErrors',false,'HotlinkErrors',false));
                    for row=1:numel(infoFromCSide)
                        if~isempty(infoFromCSide(row).Errors)
                            errors=[errors,infoFromCSide(row).Errors];%#ok<AGROW>
                        end
                    end
                    activeChoices={};
                    if strcmp(infoFromCSide(1).ValidationResultType,'Active')
                        for choices=2:numel(infoFromCSide)

                            if any(strcmp(infoFromCSide(choices).ValidationResultType,{'Active','Analyzed'}))
                                activeChoices=[activeChoices,regexprep(infoFromCSide(choices).Name,'/','//')];%#ok<AGROW>
                            end
                        end
                    end

                    VariantBlockActiveChoiceNameMap(parentBlockPathParentModel)=activeChoices;
                end


                isInactive=~any(strcmp(Simulink.variant.utils.getNameFromRenderedName(parentChoiceName),VariantBlockActiveChoiceNameMap(parentBlockPathParentModel)));
            end



            function parentChoiceName=getParentChoiceName(parentVariantBlockPathRootModel,blockPathRootModel)


                parentVariantBlockPathPartsCount=numel(Simulink.variant.utils.splitPathInHierarchy(parentVariantBlockPathRootModel));
                blockPathParts=Simulink.variant.utils.splitPathInHierarchy(blockPathRootModel);
                parentChoiceName=blockPathParts{parentVariantBlockPathPartsCount+1};
            end
        end
    end
end

