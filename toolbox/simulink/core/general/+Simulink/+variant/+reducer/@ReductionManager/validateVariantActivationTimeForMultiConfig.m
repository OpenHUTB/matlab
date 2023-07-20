







function err=validateVariantActivationTimeForMultiConfig(rManager)


    err=[];
    redMdlName=rManager.getOptions().TopModelName;
    configInfos=rManager.getOptions().ConfigInfos;
    bdNameRedBDNameMap=rManager.BDNameRedBDNameMap;
    modelsToBeProcessed={redMdlName};
    rManager.ModelsToBeProcessed=modelsToBeProcessed;




    [refModels,modelBlocks]=i_find_mdlrefs(redMdlName,'MatchFilter',@Simulink.match.allVariants);
    withCallbacks=true;
    cellfun(@(x)Simulink.variant.reducer.utils.loadSystem(x,withCallbacks),refModels);

    modelsToBeProcessedMAP=containers.Map(redMdlName,{refModels});
    modelsToBeProcessed=[modelsToBeProcessed,refModels];
    modelBlocksToBeProcessed=modelBlocks;
    numOfProcessedModels=1;
    while numOfProcessedModels<numel(modelsToBeProcessed)

        numOfProcessedModels=numOfProcessedModels+1;
        currentModel=modelsToBeProcessed{numOfProcessedModels};

        if~modelsToBeProcessedMAP.isKey(currentModel)
            [refModels,modelBlocks]=i_find_mdlrefs(currentModel,'MatchFilter',@Simulink.match.allVariants);
            cellfun(@(x)Simulink.variant.reducer.utils.loadSystem(x,withCallbacks),refModels);
            modelsToBeProcessedMAP(currentModel)={refModels};
            modelsToBeProcessed=unique([modelsToBeProcessed,refModels],'stable');
            modelBlocksToBeProcessed=unique([modelBlocksToBeProcessed;modelBlocks],'stable');
        end
    end
    rManager.ModelsToBeProcessed=modelsToBeProcessed;







    modelsToBeProcessed=setdiff(modelsToBeProcessed,redMdlName);
    if~isempty(modelsToBeProcessed)
        dirtyFlagArray(1,numel(modelsToBeProcessed))=false;
        isSimulationPausedOrRunningFlag(1,numel(modelsToBeProcessed))=false;
        isModelInCompiledStateFlag(1,numel(modelsToBeProcessed))=false;
        for ii=1:numel(modelsToBeProcessed)
            tmpOrigModelName=modelsToBeProcessed{ii};
            dirtyFlagArray(ii)=bdIsLoaded(tmpOrigModelName)&&any(strcmp(tmpOrigModelName,rManager.Environment.BDsDirtyBeforeReduction));
            isSimulationPausedOrRunningFlag(ii)=bdIsLoaded(tmpOrigModelName)&&Simulink.variant.utils.getIsSimulationPausedOrRunning(tmpOrigModelName);
            isModelInCompiledStateFlag(ii)=bdIsLoaded(tmpOrigModelName)&&Simulink.variant.utils.getIsModelInCompiledState(tmpOrigModelName);
        end

        if any(dirtyFlagArray)


            dirtyModels=modelsToBeProcessed(dirtyFlagArray);
            errid='Simulink:Variants:InvalidRefModelDirty';
            if numel(dirtyModels)==1
                errmsg=message(errid,rManager.getOptions().TopModelOrigName,dirtyModels{1});
                err=MException(errmsg);
            else
                err=MException(message('SL_SERVICES:utils:MultipleErrorsMessagePreamble'));
                for iter=1:numel(dirtyModels)
                    tempErr=MException(message(errid,rManager.getOptions().TopModelOrigName,dirtyModels{iter}));
                    err=err.addCause(tempErr);
                end
            end
            return;
        end

        if any(isSimulationPausedOrRunningFlag)



            simulatingModels=modelsToBeProcessed(isSimulationPausedOrRunningFlag);
            errid='Simulink:VariantManager:ReducingWhileRunningSimulationNotSupported';
            if numel(simulatingModels)==1
                errmsg=message(errid,simulatingModels{1});
                err=MException(errmsg);
            else
                err=MException(message('SL_SERVICES:utils:MultipleErrorsMessagePreamble'));
                for iter=1:numel(simulatingModels)
                    tempErr=MException(message(errid,simulatingModels{iter}));
                    err=err.addCause(tempErr);
                end
            end
            return;
        end

        if any(isModelInCompiledStateFlag)


            compiledModels=modelsToBeProcessed(isModelInCompiledStateFlag);
            errid='Simulink:VariantManager:ReducingWhileCompiledNotSupported';
            if numel(compiledModels)==1
                errmsg=message(errid,compiledModels{1});
                err=MException(errmsg);
            else
                err=MException(message('SL_SERVICES:utils:MultipleErrorsMessagePreamble'));
                for iter=1:numel(compiledModels)
                    tempErr=MException(message(errid,compiledModels{iter}));
                    err=err.addCause(tempErr);
                end
            end
            return;
        end
    end






    rManager.getEnvironment().ModelTargetReplacer.ModelNames=rManager.ModelsToBeProcessed;
    rManager.getEnvironment().ModelTargetReplacer.changeRebuildOptions();








    if numel(configInfos)<=1
        return;
    end











    try




        subModelConfigPropagationMap=i_computeSubModelConfigPropagationMap(modelsToBeProcessedMAP);
        rManager.SubModelConfigPropagationMap=subModelConfigPropagationMap;






        subModelConfigMap=i_findsubModelConfigMap(modelsToBeProcessedMAP,configInfos,redMdlName);







        variantInfoBlocksStruct=cellfun(@Simulink.variant.reducer.utils.getVariantInfoBlocksWithAACOff,modelsToBeProcessedMAP.keys');

        conditionForEarlyExitForAModel=@(X)(isempty(X.variantSSBlocks)&&...
        isempty(X.variantSources)&&...
        isempty(X.variantSinks)&&...
        isempty(X.refModelBlocks)&&...
        isempty(X.variantTriggerPorts)&&...
        isempty(X.variantEventListeners)...
        );



        conditionForEarlyExit=arrayfun(conditionForEarlyExitForAModel,variantInfoBlocksStruct);
        if all(conditionForEarlyExit)
            return;
        end




        variantControlInfoForBlocksStruct=arrayfun(@i_getVCForVariantInfoBlocksInModel,variantInfoBlocksStruct);



        variantControlInfoForBlocksStruct=arrayfun(@i_handleSpecialCasesInVC,variantControlInfoForBlocksStruct);





        populateActiveVariantInfoFun=@(X)(i_populateActiveVariantInfo(variantControlInfoForBlocksStruct,subModelConfigPropagationMap,X));
        activeVariantInfoForAllConfigs=cellfun(populateActiveVariantInfoFun,subModelConfigMap,'UniformOutput',false);




        cumulativeActiveVariantInfoForAllConfigs=i_accumulateActiveVariantInfoForAllConfigs(activeVariantInfoForAllConfigs);

        AACOFFBlocksForAllModels=arrayfun(@i_findAACOffMultiActiveBlocks,...
        cumulativeActiveVariantInfoForAllConfigs,variantInfoBlocksStruct,'UniformOutput',false);

        singleChoiceGPCOffBlks=getSingleChoiceGPCOffBlks(activeVariantInfoForAllConfigs,variantInfoBlocksStruct);
        if~isempty(singleChoiceGPCOffBlks)
            AACOFFBlocksForAllModels{end+1}=singleChoiceGPCOffBlks;
        end
        if~any(cellfun(@(X)~isempty(X),AACOFFBlocksForAllModels)),return;end


        redmodelNameModelNameMap=i_invertMap(bdNameRedBDNameMap);

        allBlocksWithAACOFFOrig=cellfun(@(X)i_convertRedBlockNameToOrig(X,redmodelNameModelNameMap),...
        [AACOFFBlocksForAllModels{:}],'UniformOutput',false);

        if redmodelNameModelNameMap.isKey(redMdlName)
            redMdlName=redmodelNameModelNameMap(redMdlName);
        end

        err=getAAC_GPCErrors(redMdlName,allBlocksWithAACOFFOrig);
    catch me
        Simulink.variant.reducer.utils.logException(me);



    end
end

...
...
...
...
...
...
...
function updateActiveInactiveCounterForBlock(blkPath,activeStatus,blkPathToActiveInactiveInfo)
    activeCount=activeStatus;
    inactiveCount=~activeStatus;
    currActiveInactive.activeCount=activeCount;
    currActiveInactive.inactiveCount=inactiveCount;
    if~isKey(blkPathToActiveInactiveInfo,blkPath)
        blkPathToActiveInactiveInfo(blkPath)=currActiveInactive;%#ok<NASGU>
        return;
    end
    activeInactiveCountOld=blkPathToActiveInactiveInfo(blkPath);
    activeInactiveCountNew.activeCount=activeInactiveCountOld.activeCount+currActiveInactive.activeCount;
    activeInactiveCountNew.inactiveCount=activeInactiveCountOld.inactiveCount+currActiveInactive.inactiveCount;
    blkPathToActiveInactiveInfo(blkPath)=activeInactiveCountNew;%#ok<NASGU>
end

...
...
...
...
...
...
...
function violatingBlks=collectViolatingBlocks(blkPathToActiveInactiveInfo)
    violatingBlks={};
    for key=keys(blkPathToActiveInactiveInfo)
        blkPath=key{1};
        activeInactiveCount=blkPathToActiveInactiveInfo(blkPath);
        if activeInactiveCount.activeCount>0&&activeInactiveCount.inactiveCount>0
            violatingBlks{end+1}=blkPath;%#ok<AGROW>
        end
    end
end

...
...
...
function collectActiveInactiveStatus(blkPathToActiveInactiveInfo,variantBlksCompInfo,varBlks)
    for varBlkIdx=1:numel(variantBlksCompInfo)
        perVBlkCompInfo=variantBlksCompInfo{varBlkIdx};
        if numel(perVBlkCompInfo)>1
            continue;
        end
        activeStatus=perVBlkCompInfo(1);
        varBlkPath=varBlks{varBlkIdx};
        updateActiveInactiveCounterForBlock(varBlkPath,activeStatus,blkPathToActiveInactiveInfo);
    end
end

...
...
...
function calculateSingleChoiceBlocksCompiledInfo(blkPathToActiveInactiveInfo,activeStatusCfg,variantBlks)
    for cfgIdx=1:numel(activeStatusCfg)
        perConfigVarBlksArray=activeStatusCfg{cfgIdx};
        for idx=1:numel(perConfigVarBlksArray)
            perConfigInfo=perConfigVarBlksArray(idx);
            currVarBlks=variantBlks(idx);
            collectActiveInactiveStatus(blkPathToActiveInactiveInfo,perConfigInfo.variantSources,currVarBlks.variantSources);
            collectActiveInactiveStatus(blkPathToActiveInactiveInfo,perConfigInfo.variantSinks,currVarBlks.variantSinks);
            collectActiveInactiveStatus(blkPathToActiveInactiveInfo,perConfigInfo.refModelBlocks,currVarBlks.refModelBlocks);
            collectActiveInactiveStatus(blkPathToActiveInactiveInfo,perConfigInfo.variantSSBlocks,currVarBlks.variantSSBlocks);
            collectActiveInactiveStatus(blkPathToActiveInactiveInfo,perConfigInfo.variantTriggerPorts,currVarBlks.variantTriggerPorts);
            collectActiveInactiveStatus(blkPathToActiveInactiveInfo,perConfigInfo.variantEventListeners,currVarBlks.variantEventListeners);
        end
    end
end

...
...
...
...
...
...
...
...
function violatingBlks=getSingleChoiceGPCOffBlks(activeStatusCfg,variantBlks)
    blkPathToActiveInactiveInfo=containers.Map('keyType','char','valueType','any');
    calculateSingleChoiceBlocksCompiledInfo(blkPathToActiveInactiveInfo,activeStatusCfg,variantBlks);
    violatingBlks=collectViolatingBlocks(blkPathToActiveInactiveInfo);
end

...
...
...
...
...
...
...
...
...
...
...
...
function err=getAAC_GPCErrors(redMdlName,allBlocksWithAACOFFOrig)
    if isempty(allBlocksWithAACOFFOrig)
        return;
    end

    GPCOnlyBlks={};
    AACOnlyBlks={};
    for blkIdx=1:numel(allBlocksWithAACOFFOrig)
        blkPath=allBlocksWithAACOFFOrig{blkIdx};
        blkType=get_param(blkPath,'BlockType');
        if isequal(blkType,'EventListener')||isequal(blkType,'TriggerPort')
            GPCOnlyBlks{end+1}=blkPath;%#ok<AGROW>
        else
            AACOnlyBlks{end+1}=blkPath;%#ok<AGROW>
        end
    end

    AACErrorMsgID='Simulink:VariantReducer:AACOffForMultipleChoiceActiveBlocks';
    GPCErrorMsgId='Simulink:Variants:VariantReducerGPCOoffMultiBlocks';
    MultipleErrorMsgID='SL_SERVICES:utils:MultipleErrorsMessagePreamble';

    isNonEmpty=@(container)~isempty(container);

    if isNonEmpty(GPCOnlyBlks)&&isNonEmpty(AACOnlyBlks)
        err=MException(message(MultipleErrorMsgID));
        errAAC=MException(message(AACErrorMsgID,redMdlName,strjoin(AACOnlyBlks,newline)));
        errGPC=MException(message(GPCErrorMsgId,redMdlName,strjoin(GPCOnlyBlks,newline)));
        err=err.addCause(errAAC);
        err=err.addCause(errGPC);
    elseif isNonEmpty(AACOnlyBlks)
        err=MException(message(AACErrorMsgID,redMdlName,strjoin(AACOnlyBlks,newline)));
    elseif isNonEmpty(GPCOnlyBlks)
        err=MException(message(GPCErrorMsgId,redMdlName,strjoin(GPCOnlyBlks,newline)));
    end
end



function subVCDConfigInfosNet=i_findsubModelConfigMap(modelsToBeProcessedMAP,configInfos,topModelName)

    subVCDConfigInfosNet={};

    TopVCDO=get_param(topModelName,'VariantConfigurationObject');
    for i=numel(configInfos):-1:1
        validsubVCDModelsMap=containers.Map(topModelName,configInfos{i});
        command=[TopVCDO,'.VariantConfigurations((strcmp({',TopVCDO,'.VariantConfigurations.Name},''',configInfos{i},'''))).SubModelConfigurations'];
        try






            subVCDStruct=...
            Simulink.variant.utils.evalStatementInConfigurationsSection(...
            topModelName,command);
        catch me









            error('Validation issue to be caught later');
        end
        if~isempty(subVCDStruct)
            subVCDModels={subVCDStruct.ModelName};
            subVCDConfigsMap=containers.Map(subVCDModels,{subVCDStruct.ConfigurationName});
            refModels=modelsToBeProcessedMAP(topModelName);

            subVCDModelsValid=setdiff(subVCDModels,setdiff(subVCDModels,refModels{1}));
            subVCDConfigsValid=cellfun(@(X)subVCDConfigsMap(X),subVCDModelsValid,'UniformOutput',false);

            for j=1:numel(subVCDModelsValid)
                if~validsubVCDModelsMap.isKey(subVCDModelsValid{j})
                    validsubVCDModelsMap(subVCDModelsValid{j})=subVCDConfigsValid{j};
                elseif~strcmp(validsubVCDModelsMap(subVCDModelsValid{j}),subVCDConfigsValid{j})





                    error('Validation issue to be caught later');
                end
            end

            numProcessedModels=0;
            while numProcessedModels<numel(subVCDModelsValid)

                numProcessedModels=numProcessedModels+1;
                currModel=subVCDModelsValid{numProcessedModels};
                currVCDO=get_param(currModel,'VariantConfigurationObject');
                currConfig=validsubVCDModelsMap(currModel);
                command=[currVCDO,'.VariantConfigurations((strcmp({',currVCDO,'.VariantConfigurations.Name},''',currConfig,'''))).SubModelConfigurations'];
                try
                    currSubVCDStruct=Simulink.variant.utils.evalStatementInConfigurationsSection(...
                    currModel,command);
                catch
                    error('Validation issue to be caught later');
                end

                if~isempty(currSubVCDStruct)
                    currSubVCDModels={currSubVCDStruct.ModelName};
                    currSubVCDConfigsMap=containers.Map(currSubVCDModels,{currSubVCDStruct.ConfigurationName});
                    refModels=modelsToBeProcessedMAP(currModel);
                    currSubVCDModelsValid=setdiff(currSubVCDModels,setdiff(currSubVCDModels,refModels{1}));
                    CurrSubVCDConfigsValid=cellfun(@(X)currSubVCDConfigsMap(X),currSubVCDModelsValid,'UniformOutput',false);

                    for j=1:numel(currSubVCDModelsValid)
                        if~validsubVCDModelsMap.isKey(currSubVCDModelsValid{j})
                            validsubVCDModelsMap(currSubVCDModelsValid{j})=CurrSubVCDConfigsValid{j};
                        elseif~strcmp(validsubVCDModelsMap(currSubVCDModelsValid{j}),CurrSubVCDConfigsValid{j})
                            error('Validation issue to be caught later');
                        end
                    end
                    subVCDModelsValid=[subVCDModelsValid,currSubVCDModelsValid];%#ok<AGROW> % visited as part of MLINT cleanup
                    subVCDModelsValid=unique(subVCDModelsValid,'stable');
                end
            end
        end
        subVCDConfigInfosNet{i}=validsubVCDModelsMap;
    end
end



function activeVariantInfoStruct=i_populateActiveVariantInfo(modelInfoStruct,subModelConfigPropagationMap,subModelConfigMap)

    activeVariantInfoStruct=struct('variantSources',{},'variantSinks',{},...
    'refModelBlocks',{},'variantSSBlocks',{},...
    'variantTriggerPorts',{},'variantEventListeners',{});



    modelsWithConfigs=subModelConfigMap.keys;

    for i=1:numel(modelInfoStruct)

        currModel=modelInfoStruct(i).modelName;

        slInternal('setupTempWS',currModel);






        if~subModelConfigMap.isKey(currModel)
            vars=Simulink.VariantManager.findVariantControlVars(currModel(:)');
            name={vars.Name};
            value={vars.Value};
            found=[vars.Exists];

            Names=name(found);
            Values=cellfun(@Simulink.variant.reducer.utils.i_num2str,value(found),'UniformOutput',false);
            if~isempty(Names)
                controlVariableToSend=struct('Name',Names,'Value',Values);




                Simulink.variant.manager.configutils.pushControlVarsToGlobalOrTempWS(currModel,[],controlVariableToSend,true,false,true,false);
            end
        end
    end

    for i=1:numel(modelInfoStruct)

        currModel=modelInfoStruct(i).modelName;






        if subModelConfigMap.isKey(currModel)
            VCDO=get_param(currModel,'VariantConfigurationObject');
            try
                controlVariableToSend=Simulink.variant.utils.evalStatementInConfigurationsSection(...
                currModel,[VCDO,'.VariantConfigurations((strcmp({',VCDO,'.VariantConfigurations.Name},''',subModelConfigMap(currModel),'''))).ControlVariables']);
            catch









                error('Validation issue to be caught later');
            end

            Simulink.variant.manager.configutils.pushControlVarsToGlobalOrTempWS(currModel,[],controlVariableToSend,true,false,true,false);

            subModelsSameGlobalWkspce=subModelConfigPropagationMap(currModel);
            subModelsSameGlobalWkspce=subModelsSameGlobalWkspce{1};
            SubModelsSameGlobalWkspceNoConfigs=setdiff(subModelsSameGlobalWkspce,modelsWithConfigs);

            pushControlVariablesToSubModelsFun=@(X)(Simulink.variant.manager.configutils.pushControlVarsToGlobalOrTempWS(X,[],controlVariableToSend,true,false,true,false));
            cellfun(pushControlVariablesToSubModelsFun,SubModelsSameGlobalWkspceNoConfigs,'UniformOutput',false);
        end
    end



    for i=numel(modelInfoStruct):-1:1

        currModelInfoStruct=modelInfoStruct(i);
        evaluator=@(expr)Simulink.variant.utils.evalSimulinkBooleanExprInTempOrGlobalWS(currModelInfoStruct.modelName,expr,true);
        populateActiveVariantInfoForaBlockFun=@(Y)cellfun(@(expr)evaluator(expr),Y');
        populateActiveVariantInfoForaBlockHandleErrorsFun=@(Z)handleErrorsWhileComputingActiveIndices(populateActiveVariantInfoForaBlockFun,Z);


        thisActiveVariantInfoStruct.variantSources=cellfun(populateActiveVariantInfoForaBlockHandleErrorsFun,currModelInfoStruct.variantSources,'UniformOutput',false);
        thisActiveVariantInfoStruct.variantSinks=cellfun(populateActiveVariantInfoForaBlockHandleErrorsFun,currModelInfoStruct.variantSinks,'UniformOutput',false);
        thisActiveVariantInfoStruct.refModelBlocks=cellfun(populateActiveVariantInfoForaBlockHandleErrorsFun,currModelInfoStruct.refModelBlocks,'UniformOutput',false);
        thisActiveVariantInfoStruct.variantSSBlocks=cellfun(populateActiveVariantInfoForaBlockHandleErrorsFun,currModelInfoStruct.variantSSBlocks,'UniformOutput',false);
        thisActiveVariantInfoStruct.variantTriggerPorts=cellfun(populateActiveVariantInfoForaBlockHandleErrorsFun,currModelInfoStruct.variantTriggerPorts,'UniformOutput',false);
        thisActiveVariantInfoStruct.variantEventListeners=cellfun(populateActiveVariantInfoForaBlockHandleErrorsFun,currModelInfoStruct.variantEventListeners,'UniformOutput',false);
        activeVariantInfoStruct(i,1)=thisActiveVariantInfoStruct;
    end

    function activeIndices=handleErrorsWhileComputingActiveIndices(populateActiveVariantInfoForaBlockFun,Z)
        try







            activeIndices=populateActiveVariantInfoForaBlockFun(Z);
        catch
            activeIndices=false(1,numel(Z));
        end
    end
end



function blockVVCEInfoStruct=i_getVCForVariantInfoBlocksInModel(blockInfoStruct)

    blockVVCEInfoStruct.variantSources=cellfun(@(X)get_param(X,'VariantControls'),blockInfoStruct.variantSources,'UniformOutput',false);
    blockVVCEInfoStruct.variantSinks=cellfun(@(X)get_param(X,'VariantControls'),blockInfoStruct.variantSinks,'UniformOutput',false);

    refModelBlocksStruct=cellfun(@(X)get_param(X,'Variants'),blockInfoStruct.refModelBlocks,'UniformOutput',false);
    blockVVCEInfoStruct.refModelBlocks=cellfun(@(X){X.Name}',refModelBlocksStruct,'UniformOutput',false);

    variantSSBlocksStruct=cellfun(@(X)get_param(X,'Variants'),blockInfoStruct.variantSSBlocks,'UniformOutput',false);
    blockVVCEInfoStruct.variantSSBlocks=cellfun(@(X){X.Name}',variantSSBlocksStruct,'UniformOutput',false);

    numTriggerPorts=numel(blockInfoStruct.variantTriggerPorts);
    blockVVCEInfoStruct.variantTriggerPorts=cell(1,numTriggerPorts);
    for idx=1:numTriggerPorts
        varCtrl=get_param(blockInfoStruct.variantTriggerPorts{idx},'VariantControl');
        blockVVCEInfoStruct.variantTriggerPorts{1,idx}=cellstr(varCtrl);
    end
    numEventListeners=numel(blockInfoStruct.variantEventListeners);
    blockVVCEInfoStruct.variantEventListeners=cell(1,numEventListeners);
    for idx=1:numEventListeners
        varCtrl=get_param(blockInfoStruct.variantEventListeners{idx},'VariantControl');
        blockVVCEInfoStruct.variantEventListeners{1,idx}=cellstr(varCtrl);
    end
    blockVVCEInfoStruct.modelName=blockInfoStruct.modelName;
end



function subModelConfigPropagationMap=i_computeSubModelConfigPropagationMap(modelsToBeProcessedMAP)

    subModelConfigPropagationMap=containers.Map();
    modelNames=modelsToBeProcessedMAP.keys;

    for i=1:numel(modelNames)
        currModel=modelNames{i};
        refModelsCell=modelsToBeProcessedMAP(currModel);
        refModels=refModelsCell{1};
        numProcessedModels=0;
        while numProcessedModels<numel(refModels)
            numProcessedModels=numProcessedModels+1;
            currRefModel=refModels{numProcessedModels};
            currRefModelsCell=modelsToBeProcessedMAP(currRefModel);
            currRefModels=currRefModelsCell{1};
            refModels=unique([refModels,currRefModels],'stable');
        end
        dataDictionary=get_param(currModel,'DataDictionary');
        dataDictionaryMatchIndices=cellfun(@(X)strcmp(get_param(X,'DataDictionary'),dataDictionary),refModels);
        refModels=refModels(dataDictionaryMatchIndices);
        subModelConfigPropagationMap(currModel)={refModels};
    end
end



function AACOffBlocks=i_findAACOffMultiActiveBlocks(cumulativeActiveVariantInfoForModel,variantInfoBlocksStructForModel)
    findViolatingBlocksFun=@(blockInfo,block)(nnz(blockInfo)>1);

    status.variantSinks=cellfun(findViolatingBlocksFun,cumulativeActiveVariantInfoForModel.variantSinks,variantInfoBlocksStructForModel.variantSinks);
    status.variantSources=cellfun(findViolatingBlocksFun,cumulativeActiveVariantInfoForModel.variantSources,variantInfoBlocksStructForModel.variantSources);
    status.refModelBlocks=cellfun(findViolatingBlocksFun,cumulativeActiveVariantInfoForModel.refModelBlocks,variantInfoBlocksStructForModel.refModelBlocks);
    status.variantSSBlocks=cellfun(findViolatingBlocksFun,cumulativeActiveVariantInfoForModel.variantSSBlocks,variantInfoBlocksStructForModel.variantSSBlocks);
    status.variantTriggerPorts=cellfun(findViolatingBlocksFun,cumulativeActiveVariantInfoForModel.variantTriggerPorts,variantInfoBlocksStructForModel.variantTriggerPorts);
    status.variantEventListeners=cellfun(findViolatingBlocksFun,cumulativeActiveVariantInfoForModel.variantEventListeners,variantInfoBlocksStructForModel.variantEventListeners);

    AACOffBlocks=[variantInfoBlocksStructForModel.variantSinks(status.variantSinks),...
    variantInfoBlocksStructForModel.variantSources(status.variantSources),...
    variantInfoBlocksStructForModel.refModelBlocks(status.refModelBlocks),...
    variantInfoBlocksStructForModel.variantSSBlocks(status.variantSSBlocks),...
    variantInfoBlocksStructForModel.variantTriggerPorts(status.variantTriggerPorts),...
    variantInfoBlocksStructForModel.variantEventListeners(status.variantEventListeners)...
    ];
end

function netActiveVariantInfoStruct=i_accumulateActiveVariantInfoForAllConfigs(activeVariantInfoStructForAllConfigs)

    netActiveVariantInfoStruct=activeVariantInfoStructForAllConfigs{1};

    for i=2:numel(activeVariantInfoStructForAllConfigs)

        thisActiveVariantInfoStruct=activeVariantInfoStructForAllConfigs{i};

        for j=1:numel(netActiveVariantInfoStruct)
            netActiveVariantInfoStruct(j,1).variantSources=cellfun(@plus,netActiveVariantInfoStruct(j,1).variantSources,thisActiveVariantInfoStruct(j,1).variantSources,'UniformOutput',false);
            netActiveVariantInfoStruct(j,1).variantSinks=cellfun(@plus,netActiveVariantInfoStruct(j,1).variantSinks,thisActiveVariantInfoStruct(j,1).variantSinks,'UniformOutput',false);
            netActiveVariantInfoStruct(j,1).refModelBlocks=cellfun(@plus,netActiveVariantInfoStruct(j,1).refModelBlocks,thisActiveVariantInfoStruct(j,1).refModelBlocks,'UniformOutput',false);
            netActiveVariantInfoStruct(j,1).variantSSBlocks=cellfun(@plus,netActiveVariantInfoStruct(j,1).variantSSBlocks,thisActiveVariantInfoStruct(j,1).variantSSBlocks,'UniformOutput',false);
            netActiveVariantInfoStruct(j,1).variantTriggerPorts=cellfun(@plus,netActiveVariantInfoStruct(j,1).variantTriggerPorts,thisActiveVariantInfoStruct(j,1).variantTriggerPorts,'UniformOutput',false);
            netActiveVariantInfoStruct(j,1).variantEventListeners=cellfun(@plus,netActiveVariantInfoStruct(j,1).variantEventListeners,thisActiveVariantInfoStruct(j,1).variantEventListeners,'UniformOutput',false);
        end
    end
end

function modifiedVariantControlInfoForBlocksStruct=i_handleSpecialCasesInVC(variantControlInfoForBlocksStruct)
    modifiedVariantControlInfoForBlocksStruct=arrayfun(@i_handleSpecialCasesInVCForaModel,variantControlInfoForBlocksStruct);
end

function modifiedVCForaModel=i_handleSpecialCasesInVCForaModel(VCInfoForaModel)

    handleDefaultCaseInVCForaBlockTypeFun=@(X)(cellfun(@(Y)(Simulink.variant.reducer.utils.i_handleSpecialCasesInVCForaBlock(Y)),X,'UniformOutput',false));
    modifiedVCForaModel.variantSources=handleDefaultCaseInVCForaBlockTypeFun(VCInfoForaModel.variantSources);
    modifiedVCForaModel.variantSinks=handleDefaultCaseInVCForaBlockTypeFun(VCInfoForaModel.variantSinks);
    modifiedVCForaModel.refModelBlocks=handleDefaultCaseInVCForaBlockTypeFun(VCInfoForaModel.refModelBlocks);
    modifiedVCForaModel.variantSSBlocks=handleDefaultCaseInVCForaBlockTypeFun(VCInfoForaModel.variantSSBlocks);
    modifiedVCForaModel.variantTriggerPorts=handleDefaultCaseInVCForaBlockTypeFun(VCInfoForaModel.variantTriggerPorts);
    modifiedVCForaModel.variantEventListeners=handleDefaultCaseInVCForaBlockTypeFun(VCInfoForaModel.variantEventListeners);
    modifiedVCForaModel.modelName=VCInfoForaModel.modelName;
end


