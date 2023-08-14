function applyConfigs(rMgr)




    try
        applyConfigsImpl(rMgr);
    catch ex
        Simulink.variant.reducer.utils.logException(ex);
        rMgr.Error=ex;
    end
end







function applyConfigsImpl(rMgr)
    populateRefModelsForDefaultConfig(rMgr);
    processAllConfigs(rMgr);
    validateSlExpr(rMgr);
    copyBDs(rMgr);
    setBlksInModelRefModelInfo(rMgr);
    renameBlockChoiceInfoStructsVec(rMgr);
    addSubModelConfig(rMgr);
    fixInactiveBlksInAZVCOffMap(rMgr);
    handleRestrictedModels(rMgr);
end

function handleRestrictedModels(rMgr)




    rMgr.Error=getErrorForRestrictedModels(rMgr);
    rMgr.throwOnError();
end

function populateRefModelsForDefaultConfig(rMgr)



    for modelRefIter=2:numel(rMgr.ModelsToBeProcessed)
        currRefModel=rMgr.ModelsToBeProcessed{modelRefIter};
        rMgr.getEnvironment().addModelForDefaultConfigHandling(currRefModel);
    end
end

function processAllConfigs(rMgr)
    numConfigInfos=numel(rMgr.ProcessedModelInfoStructsVec.ConfigInfos);
    topModelName=rMgr.ProcessedModelInfoStructsVec.Name;
    rMgr.ApplyConfigInfo.allRefMdlsPerConfig=Simulink.variant.utils.i_find_mdlrefs(topModelName,struct('RecurseIntoModelReferences',true));
    for configInfoIdx=1:numConfigInfos
        processConfig(rMgr,configInfoIdx);
        collectModelRefDataForConfig(rMgr,configInfoIdx);
    end
end

function collectModelRefDataForConfig(rMgr,configInfoIdx)
    currCfg=rMgr.ProcessedModelInfoStructsVec.ConfigInfos(configInfoIdx).ConfigName;
    rMgr.CfgToMdlRefData(currCfg)=rMgr.AllRefBlocksInfo.getBDToMdlRefsData();



    rMgr.AllRefBlocksInfo.clearBDToMdlRefsData();
end

function processConfig(rMgr,configInfoIdx)
    setModelToConfigMap(rMgr,configInfoIdx);
    initialCompile(rMgr);
    setRefBlocksInfo(rMgr);
    setPortAttributesMap(rMgr);
    setVariantControlVars(rMgr,configInfoIdx);
    computeModelRefInfoForConfig(rMgr,configInfoIdx);
    loadModelRefs(rMgr);
    populateActiveModels(rMgr);
    populateInactiveAZVCOffIVBlks(rMgr);
    cleanUpInactiveBlks(rMgr,configInfoIdx);
end

function setRefBlocksInfo(rMgr)
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    rMgr.AllRefBlocksInfo.appendFromStruct(cMgr.getRefBlocksInfo());

end

function computeModelRefInfoForConfig(rMgr,configInfoIdx)
    currConfig=rMgr.ProcessedModelInfoStructsVec.ConfigInfos(configInfoIdx).Configuration;
    populateActiveMdlRefBlks(rMgr);
    rMgr.ApplyConfigInfo.activeRefMdlsPerConfig=...
    unique(get_param(rMgr.ApplyConfigInfo.activeMdlRefBlksPerConfig,'ModelName'));
    rMgr.ActiveRefMdls=union(rMgr.ApplyConfigInfo.activeRefMdlsPerConfig,rMgr.ActiveRefMdls);
    rMgr.ActiveMdlRefBlks=union(rMgr.ApplyConfigInfo.activeMdlRefBlksPerConfig,rMgr.ActiveMdlRefBlks);

    numConfigInfos=numel(rMgr.ProcessedModelInfoStructsVec.ConfigInfos);
    if numConfigInfos>1&&~isempty(currConfig)
        rMgr.ApplyConfigInfo.modelsActivePerConfigMap(currConfig.Name)=rMgr.ApplyConfigInfo.activeRefMdlsPerConfig;
    end
end

function loadModelRefs(rMgr)
    withCallbacks=true;
    cellfun(@(x)Simulink.variant.reducer.utils.loadSystem(x,withCallbacks),rMgr.ActiveRefMdls);
end

function setVariantControlVars(rMgr,configInfoIdx)
    topModelName=rMgr.ProcessedModelInfoStructsVec.Name;



    rMgr.ProcessedModelInfoStructsVec.ConfigInfos(configInfoIdx).AllCtrlVars=...
    Simulink.VariantManager.findVariantControlVars(topModelName,'SearchReferencedModels','on');
end

function setModelToConfigMap(rMgr,configInfoIdx)
    currConfig=rMgr.ProcessedModelInfoStructsVec.ConfigInfos(configInfoIdx).Configuration;
    validationLog=validateModelForConfig(rMgr,currConfig);
    topModelName=rMgr.ProcessedModelInfoStructsVec.Name;



    rMgr.ProcessedModelInfoStructsVec.ConfigInfos(configInfoIdx).ModelVsConfigMap=...
    getModelVsConfigMapPerConfiguration(topModelName,validationLog);
end

function setPortAttributesMap(rMgr)
    setCompiledPortAttributesMap(rMgr);
    setCompiledBusSrcPortAttribsMap(rMgr);
end

function cleanUpInactiveBlks(rMgr,configInfoIdx)
    inactiveRefMdlsPerConfig=setdiff(rMgr.ApplyConfigInfo.allRefMdlsPerConfig,rMgr.ApplyConfigInfo.activeRefMdlsPerConfig);

    compiledBlocks=cleanUpCompiledBlocks(inactiveRefMdlsPerConfig);
    compiledVarBlkChoiceInfo=cleanUpCompiledVarBlkChoiceInfo(inactiveRefMdlsPerConfig);
    compiledSpecialBlkInfo=cleanUpCompiledSpecialBlkInfo(inactiveRefMdlsPerConfig);



    rMgr.ProcessedModelInfoStructsVec.ConfigInfos(configInfoIdx).CompiledBlocks=compiledBlocks;
    rMgr.ProcessedModelInfoStructsVec.ConfigInfos(configInfoIdx).CompiledVarBlkChoiceInfo=compiledVarBlkChoiceInfo;
    rMgr.ProcessedModelInfoStructsVec.ConfigInfos(configInfoIdx).CompiledSpecialBlockInfo=copy(compiledSpecialBlkInfo);
end

function validationLog=validateModelForConfig(rMgr,currConfig)
    validationLog=[];
    if isempty(currConfig)
        return;
    end




    topModelName=rMgr.ProcessedModelInfoStructsVec.Name;
    optArgs=struct('ConfigurationName',currConfig.Name,...
    'VarNameSimParamExpressionHierarchyMap',rMgr.VarNameSimParamExpressionHierarchyMap);
    [errors,validationLog]=Simulink.variant.manager.configutils.validateModelEntry(...
    topModelName,validationLog,optArgs);
    if isempty(errors)
        return;
    end
    Simulink.variant.reducer.utils.throwInvalidConfig(rMgr.getOptions().TopModelOrigName,...
    rMgr.getOptions().IsConfigSpecifiedAsVariables,...
    currConfig,...
    errors);
end

function fixInactiveBlksInAZVCOffMap(rMgr)

    allCompiledActiveVarBlockInfo={rMgr.ProcessedModelInfoStructsVec.ConfigInfos.CompiledVarBlkChoiceInfo};
    allCompiledActiveVarBlocks=cellfun(@(x){x.VariantBlock},allCompiledActiveVarBlockInfo,'UniformOutput',false);
    allCompiledActiveVarBlocks=[allCompiledActiveVarBlocks{:}];

    inactiveVariantBlocksInMap=rMgr.InactiveAZVCOffIVBlockToActivePortMap.keys;
    inactiveVariantBlocksNotNeeded=setdiff(inactiveVariantBlocksInMap,allCompiledActiveVarBlocks);
    cellfun(@(x)rMgr.InactiveAZVCOffIVBlockToActivePortMap.remove(x),inactiveVariantBlocksNotNeeded,'UniformOutput',false);


    varBlks=rMgr.InactiveAZVCOffIVBlockToActivePortMap.keys;
    for ij=1:numel(varBlks)
        blk=varBlks{ij};
        mdl=i_getRootBDNameFromPath(blk);
        if rMgr.BDNameRedBDNameMap.isKey(mdl)
            newVarBlk=[rMgr.BDNameRedBDNameMap(mdl),blk((length(mdl)+1):end)];
            rMgr.InactiveAZVCOffIVBlockToActivePortMap(newVarBlk)=rMgr.InactiveAZVCOffIVBlockToActivePortMap(blk);
            rMgr.InactiveAZVCOffIVBlockToActivePortMap.remove(blk);
        end
    end
end


function fixSubModelMapToHaveSuffix(rMgr)
    keys=rMgr.SubModelToModelMap.keys;
    for keyIdx=1:numel(keys)
        key=keys{keyIdx};
        values=unique(rMgr.SubModelToModelMap(key));

        for valueIdx=1:numel(values)
            value=values{valueIdx};
            if rMgr.BDNameRedBDNameMap.isKey(value)
                values{valueIdx}=rMgr.BDNameRedBDNameMap(value);
            end
        end

        if rMgr.BDNameRedBDNameMap.isKey(key)
            rMgr.SubModelToModelMap.remove(key);
            key=rMgr.BDNameRedBDNameMap(key);
        end

        rMgr.SubModelToModelMap(key)=values;
    end
end

function addSubModelConfig(rMgr)

    if numel(rMgr.ModelsToBeProcessed)>1&&numel(rMgr.ProcessedModelInfoStructsVec.ConfigInfos)>1


        fixSubModelMapToHaveSuffix(rMgr);
        rMgr.Error=addSubModelConfigsImpl(rMgr);
        rMgr.throwOnError();
    end
end

function setBlksInModelRefModelInfo(rMgr)






    rMgr.ModelRefModelInfoStructsVec(1).FullPath=rMgr.ProcessedModelInfoStructsVec.FullPath;
    for mrefIdx=2:numel(rMgr.ModelRefModelInfoStructsVec)
        setBlksSVCEMap(rMgr,mrefIdx);
        if rMgr.getOptions().ValidateSignals
            setBlksAttribsMap(rMgr,mrefIdx)
        end
    end
end

function setBlksAttribsMap(rMgr,mrefIdx)
    currModelBlksAttribsMap=rMgr.ModelRefModelInfoStructsVec(mrefIdx).BlksAttribsMap;
    currModel=rMgr.ModelRefModelInfoStructsVec(mrefIdx).OrigName;
    currModelRedName=rMgr.BDNameRedBDNameMap(currModel);
    if~isempty(currModelBlksAttribsMap)
        currModelBlks=currModelBlksAttribsMap.keys;
        currModelBlks=cellfun(@(x)[currModelRedName,x((length(currModel)+1):end)],currModelBlks,'UniformOutput',false);
        currModelBlksAttribsMap=containers.Map(currModelBlks,currModelBlksAttribsMap.values);
        rMgr.ModelRefModelInfoStructsVec(mrefIdx).BlksAttribsMap=currModelBlksAttribsMap;
    end
end

function setBlksSVCEMap(rMgr,mrefIdx)
    currModelBlksSVCEMap=rMgr.ModelRefModelInfoStructsVec(mrefIdx).BlksSVCEMap;
    currModel=rMgr.ModelRefModelInfoStructsVec(mrefIdx).OrigName;
    currModelRedName=rMgr.BDNameRedBDNameMap(currModel);



    if~isempty(currModelBlksSVCEMap)
        currModelBlks=currModelBlksSVCEMap.keys;
        currModelBlks=cellfun(@(x)[currModelRedName,x((length(currModel)+1):end)],currModelBlks,'UniformOutput',false);
        currModelBlksSVCEMap=containers.Map(currModelBlks,currModelBlksSVCEMap.values);
        rMgr.ModelRefModelInfoStructsVec(mrefIdx).BlksSVCEMap=currModelBlksSVCEMap;
    end
end

function compiledBlocks=cleanUpCompiledBlocks(inactiveRefMdlsPerConfig)
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    [~,compiledBlocks]=cMgr.getModelInfo();


    for ij=numel(compiledBlocks):-1:1


        mdl=i_getRootBDNameFromPath(compiledBlocks{ij});
        if~isempty(Simulink.variant.reducer.utils.searchNameInCell(mdl,inactiveRefMdlsPerConfig))
            compiledBlocks(ij)=[];
        end
    end
end

function compiledVarBlkChoiceInfo=cleanUpCompiledVarBlkChoiceInfo(inactiveRefMdlsPerConfig)
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    compiledVarBlkChoiceInfo=cMgr.getVariantBlockActiveChoiceStruct();
    for ij=numel(compiledVarBlkChoiceInfo):-1:1
        mdl=i_getRootBDNameFromPath(compiledVarBlkChoiceInfo(ij).VariantBlock);
        if~isempty(Simulink.variant.reducer.utils.searchNameInCell(mdl,inactiveRefMdlsPerConfig))
            compiledVarBlkChoiceInfo(ij)=[];
        end
    end
end

function compiledSpecialBlkInfo=cleanUpCompiledSpecialBlkInfo(inactiveRefMdlsPerConfig)
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    compiledSpecialBlkInfo=cMgr.getSpecialBlockInfo();
    for ij=numel(compiledSpecialBlkInfo):-1:1
        mdl=i_getRootBDNameFromPath(compiledSpecialBlkInfo(ij).BlockPath);
        if~isempty(Simulink.variant.reducer.utils.searchNameInCell(mdl,inactiveRefMdlsPerConfig))
            compiledSpecialBlkInfo(ij)=[];
        end
    end
end

function populateInactiveAZVCOffIVBlks(rMgr)
    compiledInactiveAZVCOffIVBlkToActivePortMap=processInactiveModelBlocks(rMgr);


    inactiveBlks=compiledInactiveAZVCOffIVBlkToActivePortMap.keys;
    for ii=1:numel(inactiveBlks)
        currInactiveBlk=inactiveBlks{ii};
        if rMgr.InactiveAZVCOffIVBlockToActivePortMap.isKey(currInactiveBlk)
            rMgr.InactiveAZVCOffIVBlockToActivePortMap(currInactiveBlk)...
            =unique([compiledInactiveAZVCOffIVBlkToActivePortMap(currInactiveBlk)...
            ,rMgr.InactiveAZVCOffIVBlockToActivePortMap(currInactiveBlk)]);
        else
            rMgr.InactiveAZVCOffIVBlockToActivePortMap(currInactiveBlk)...
            =compiledInactiveAZVCOffIVBlkToActivePortMap(currInactiveBlk);
        end
    end
end

function initialCompile(rMgr)
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    cMgr.clean();
    cMgr.setTopModel(rMgr.ProcessedModelInfoStructsVec.Name);

    cMgr.setValidateSignalsFlag(rMgr.getOptions().ValidateSignals);




    hplgmngr=Simulink.PluginMgr;
    mdlHandle=get_param(rMgr.ProcessedModelInfoStructsVec.Name,'Handle');
    hplgmngr.attach(mdlHandle,'VARIANTREDUCER');
    cMgr.callInitialCompile(rMgr.getOptions().isCodegenCompileMode());




    hplgmngr.detachForAllModels('VARIANTREDUCER');
end

function validateSlExpr(rMgr)
    dataDictionaries=rMgr.VarNameSimParamExpressionHierarchyMap.keys;
    errid='Simulink:VariantReducer:InconsistentSlexprDefinitions';
    for i=1:numel(dataDictionaries)
        err=Simulink.variant.utils.getInconsistentSlexprError(...
        rMgr.VarNameSimParamExpressionHierarchyMap(dataDictionaries{i}),...
        numel(rMgr.ReductionOptions.ConfigInfos),errid);
        if isempty(err)
            continue;
        end
        throw(err);
    end
end

function setCompiledPortAttributesMap(rMgr)
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    compiledPortAttributesMap=cMgr.getCompiledPortAttributeMap();
    [~,compiledBlocks]=cMgr.getModelInfo();
    for ii=1:numel(compiledBlocks)
        tmpBlkName=i_replaceCarriageReturnWithSpace(compiledBlocks{ii});
        Simulink.variant.reducer.utils.assert(isKey(compiledPortAttributesMap,tmpBlkName));

        if~isKey(rMgr.CompiledPortAttributesMap,tmpBlkName)

            rMgr.CompiledPortAttributesMap(tmpBlkName)=compiledPortAttributesMap(tmpBlkName);
        else




        end
    end
end

function setCompiledBusSrcPortAttribsMap(rMgr)
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    compiledBusSrcPortAttributesMap=cMgr.getCompiledBusSrcPortAttributeMap();
    compiledBusSrcBlks=compiledBusSrcPortAttributesMap.keys;
    for ii=1:numel(compiledBusSrcBlks)
        tmpBlkName=i_replaceCarriageReturnWithSpace(compiledBusSrcBlks{ii});
        if~isKey(rMgr.CompiledBusSrcPortAttribsMap,tmpBlkName)

            rMgr.CompiledBusSrcPortAttribsMap(tmpBlkName)=compiledBusSrcPortAttributesMap(tmpBlkName);
        else




        end
    end
end

function populateActiveMdlRefBlks(rMgr)
    modelsToReduceQueue=get_param(rMgr.ProcessedModelInfoStructsVec.Name,'Handle');
    modelsProcessedQueue=[];
    rMgr.ApplyConfigInfo.activeMdlRefBlksPerConfig={};
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    compiledModelName2ModelBlocksMap=cMgr.getModelName2ModelBlocksMap();





















    while~isempty(modelsToReduceQueue)
        tmpName=get_param(modelsToReduceQueue(1),'Name');
        tmpActiveMdlRefBlksPerConfig=compiledModelName2ModelBlocksMap(tmpName);
        tmpActiveMdlRefBlksPerConfig=i_replaceCarriageReturnWithSpace(tmpActiveMdlRefBlksPerConfig);







        tmpActiveMdlRefBlksPerConfig=ignoreModelBlksInLibUnderMLRoot(tmpActiveMdlRefBlksPerConfig);
        tmpActiveMdlRefBlksPerConfig=tmpActiveMdlRefBlksPerConfig(:)';


        tmpActiveMdlRefBlksPerConfig=tmpActiveMdlRefBlksPerConfig(...
        ~cellfun(@(x)(Simulink.variant.utils.getIsProtectedModelAndFullFile(x)),...
        get_param(tmpActiveMdlRefBlksPerConfig,'ModelFile')));



        tmpActiveMdlRefBlksPerConfig=ignoreBlksMissingInRefBlksDB(rMgr,tmpActiveMdlRefBlksPerConfig);

        modelsProcessedQueue(end+1)=modelsToReduceQueue(1);%#ok<AGROW> % double array % visited as part of MLINT cleanup
        modelsToReduceQueue(1)=[];


        for mdlrefId=1:numel(tmpActiveMdlRefBlksPerConfig)
            refModelName=get_param(tmpActiveMdlRefBlksPerConfig{mdlrefId},'ModelName');
            modelsToReduceQueue(end+1)=get_param(refModelName,'Handle');%#ok<AGROW> % double array % visited as part of MLINT cleanup



            if rMgr.SubModelToModelMap.isKey(refModelName)



                rMgr.SubModelToModelMap(refModelName)=[rMgr.SubModelToModelMap(refModelName),tmpName];
            else
                rMgr.SubModelToModelMap(refModelName)={tmpName};
            end
        end

        modelsToReduceQueue=setdiff(modelsToReduceQueue,modelsProcessedQueue);
        rMgr.ApplyConfigInfo.activeMdlRefBlksPerConfig=[rMgr.ApplyConfigInfo.activeMdlRefBlksPerConfig...
        ,tmpActiveMdlRefBlksPerConfig];
    end
end

function blks=ignoreBlksMissingInRefBlksDB(rMgr,inputBlks)
    blks=inputBlks;
    for blkIdx=1:numel(inputBlks)
        if~rMgr.AllRefBlocksInfo.isBlockExistInRefBlocksDB(inputBlks{blkIdx})
            blks(blkIdx)=[];
        end
    end
end

function setMdlNameInCurrentModelBlock(rMgr,modelIter,currModelBlock)



    currMdlNameOrig=rMgr.ProcessedModelInfoStructsVec.OrigName;
    currMdlName=rMgr.ProcessedModelInfoStructsVec.Name;
    if~isequal(modelIter,0)
        currMdlNameOrig=rMgr.ApplyConfigInfo.activeRefMdlsPerConfig{modelIter};
        currMdlName='';
    end

    currModelBlock.Name=currMdlName;
    currModelBlock.OrigName=currMdlNameOrig;
end

function blocksInCurrModel=getFilteredBlocks(modelIter,currModelBlock)

    if modelIter==0
        blocksInCurrModel=i_findSystem(currModelBlock.Name);
    else
        blocksInCurrModel=i_findSystem(currModelBlock.OrigName);
    end

    blocksInCurrModel=blocksInCurrModel(2:end);

    blocksInCurrModel=i_removeBlksInSFChartFromList(blocksInCurrModel);
    blocksInCurrModel=i_replaceCarriageReturnWithSpace(blocksInCurrModel);
end

function calculateActiveBlksCount(rMgr,modelIter,currModelBlock)
    blocksInCurrModel=getFilteredBlocks(modelIter,currModelBlock);









    currModelBlock.BlksSVCEMap=containers.Map();
    currModelBlock.BlksAttribsMap=containers.Map();

    if numel(blocksInCurrModel)>0
        currModelBlock.BlksSVCEMap=containers.Map(...
        blocksInCurrModel,...
        zeros(1,numel(blocksInCurrModel)));
        if rMgr.getOptions().ValidateSignals
            currModelBlock.BlksAttribsMap=containers.Map(...
            blocksInCurrModel,cell(1,numel(blocksInCurrModel)));
        end
    end
end

function setBlocksInCurrModelBlock(rMgr,modelIter,modelRefModelInfoIter,currModelBlock)
    currModelBlock.BlksSVCEMap=containers.Map();
    currModelBlock.BlksAttribsMap=containers.Map();
    if isempty(modelRefModelInfoIter)
        calculateActiveBlksCount(rMgr,modelIter,currModelBlock);
    else
        currModelBlock.BlksSVCEMap=rMgr.ModelRefModelInfoStructsVec(modelRefModelInfoIter).BlksSVCEMap;
        if rMgr.getOptions().ValidateSignals
            currModelBlock.BlksAttribsMap=rMgr.ModelRefModelInfoStructsVec(modelRefModelInfoIter).BlksAttribsMap;
        end
    end
end

function setVarBlkChoiceInfo(rMgr,modelRefModelInfoIter,currModelBlock)
    if isempty(modelRefModelInfoIter)
        currModelBlock.VarBlkChoiceInfoStructsVec=Simulink.variant.reducer.types.VRedVariantBlockChoiceInfo.empty;
    else
        currModelBlock.VarBlkChoiceInfoStructsVec=rMgr.ModelRefModelInfoStructsVec(modelRefModelInfoIter).VarBlkChoiceInfoStructsVec;
    end
end

function setSpecialBlockInfo(rMgr,modelRefModelInfoIter,currModelBlock)
    if isempty(modelRefModelInfoIter)
        currModelBlock.CompiledSpecialBlockInfo=Simulink.variant.reducer.types.VRedCompiledSpecialBlockInfo.empty;
    else
        currModelBlock.CompiledSpecialBlockInfo=rMgr.ModelRefModelInfoStructsVec(modelRefModelInfoIter).CompiledSpecialBlockInfo;
    end
end

function setActiveBlocks(rMgr,currModelBlock)


    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    [~,compiledBlocks]=cMgr.getModelInfo();
    compiledPortAttributesMap=cMgr.getCompiledPortAttributeMap();
    compiledVarBlkChoiceInfo=cMgr.getVariantBlockActiveChoiceStruct();
    compiledSpecialBlkInfo=cMgr.getSpecialBlockInfo();

    for ii=1:numel(compiledBlocks)
        tmpBlkName=i_replaceCarriageReturnWithSpace(compiledBlocks{ii});

        if~isKey(currModelBlock.BlksSVCEMap,tmpBlkName)
            continue;
        end








        currModelBlock.BlksSVCEMap(tmpBlkName)=currModelBlock.BlksSVCEMap(tmpBlkName)+1;

        if rMgr.getOptions().ValidateSignals


            currModelBlock.BlksAttribsMap(tmpBlkName)=compiledPortAttributesMap(tmpBlkName);
        end


        blkLinkStatus=get_param(tmpBlkName,'StaticLinkStatus');

        setVarBlkChoiceInfo();
        setSpecialBlockInfo();
    end

    function setVarBlkChoiceInfo()


        varIdx=Simulink.variant.reducer.utils.searchNameInCell(tmpBlkName,{compiledVarBlkChoiceInfo.VariantBlock});







        if~isempty(varIdx)...
            &&(strcmpi('none',blkLinkStatus)...
            ||isResolvedIVBlock(tmpBlkName,blkLinkStatus)...
            ||Simulink.variant.utils.isManualIVBlock(tmpBlkName))






            currModelBlock.VarBlkChoiceInfoStructsVec=...
            Simulink.variant.reducer.ReductionManager.i_checkAndPopulateVarBlkChoiceInfo(...
            tmpBlkName,currModelBlock.VarBlkChoiceInfoStructsVec,compiledVarBlkChoiceInfo(varIdx));
        end
    end

    function setSpecialBlockInfo()

        splBlkIdx=Simulink.variant.reducer.utils.searchNameInCell(tmpBlkName,{compiledSpecialBlkInfo.BlockPath});


        if~isempty(splBlkIdx)&&any(strcmpi(blkLinkStatus,{'none','resolved'}))


            currModelBlock.CompiledSpecialBlockInfo=...
            Simulink.variant.reducer.ReductionManager.i_checkAndPopulateSpecialBlockInfo(...
            tmpBlkName,currModelBlock.CompiledSpecialBlockInfo,compiledSpecialBlkInfo(splBlkIdx));
        end
    end

    function status=isResolvedIVBlock(blk,blkLinkStatus)
        status=any(strcmpi(get_param(blk,'BlockType'),{'VariantSource','VariantSink'}))...
        &&strcmpi('resolved',blkLinkStatus);
    end
end

function populateModelRefInfoStructVec(rMgr,modelRefModelInfoIter,currModelBlock)
    if isempty(modelRefModelInfoIter)

        currModelBlock.NumberOfConfigsActive=1;
        rMgr.ModelRefModelInfoStructsVec(end+1)=currModelBlock;
    else

        currModelBlock.NumberOfConfigsActive=rMgr.ModelRefModelInfoStructsVec(modelRefModelInfoIter).NumberOfConfigsActive+1;
        rMgr.ModelRefModelInfoStructsVec(modelRefModelInfoIter)=currModelBlock;
    end
end

function populateActiveModels(rMgr)

    for modelIter=0:numel(rMgr.ApplyConfigInfo.activeRefMdlsPerConfig)
        currModelBlock=Simulink.variant.reducer.types.VRedModelBlock;
        setMdlNameInCurrentModelBlock(rMgr,modelIter,currModelBlock);
        modelRefModelInfoIter=Simulink.variant.reducer.utils.searchNameInCell(currModelBlock.OrigName,{rMgr.ModelRefModelInfoStructsVec.OrigName});
        setBlocksInCurrModelBlock(rMgr,modelIter,modelRefModelInfoIter,currModelBlock);
        setVarBlkChoiceInfo(rMgr,modelRefModelInfoIter,currModelBlock);
        setSpecialBlockInfo(rMgr,modelRefModelInfoIter,currModelBlock);
        setActiveBlocks(rMgr,currModelBlock);
        populateModelRefInfoStructVec(rMgr,modelRefModelInfoIter,currModelBlock);
    end
end

function compiledInactiveAZVCOffIVBlkToActivePortMap=processInactiveModelBlocks(rMgr)
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    compiledInactiveAZVCOffIVBlkToActivePortMap=cMgr.getInactiveAZVCOffIVBlockToActivePortMap();
    compiledVarBlkChoiceInfo=cMgr.getVariantBlockActiveChoiceStruct();
    [~,compiledBlocks]=cMgr.getModelInfo();













    inactiveRefMdlsPerConfig=setdiff(rMgr.ApplyConfigInfo.allRefMdlsPerConfig,rMgr.ApplyConfigInfo.activeRefMdlsPerConfig);

    for inactIdx=1:numel(inactiveRefMdlsPerConfig)


        currInactMdl=inactiveRefMdlsPerConfig{inactIdx};
        inactBlks=i_replaceCarriageReturnWithSpace(i_findSystem(currInactMdl));
        inactBlks(1)=[];

        for blkIdx=1:numel(compiledBlocks)
            tmpBlkName=i_replaceCarriageReturnWithSpace(compiledBlocks{blkIdx});
            blkFoundIdx=Simulink.variant.reducer.utils.searchNameInCell(tmpBlkName,inactBlks);
            if isempty(blkFoundIdx)
                continue;
            end
            varBlkFoundIdx=Simulink.variant.reducer.utils.searchNameInCell(tmpBlkName,{compiledVarBlkChoiceInfo.VariantBlock});
            if isempty(varBlkFoundIdx)
                continue;
            end
            varBlkPath=compiledVarBlkChoiceInfo(varBlkFoundIdx).VariantBlock;
            populateInactiveAZVCMap(compiledInactiveAZVCOffIVBlkToActivePortMap,varBlkPath,varBlkFoundIdx);
        end
    end
end

function populateInactiveAZVCMap(compiledInactiveAZVCOffIVBlkToActivePortMap,varBlkPath,varBlkFoundIdx)
    cMgr=Simulink.variant.reducer.CompileManager.getInstance();
    compiledVarBlkChoiceInfo=cMgr.getVariantBlockActiveChoiceStruct();
    isVarSrc=strcmp(get_param(varBlkPath,'BlockType'),'VariantSource');
    isVarSnk=~isVarSrc&&strcmp(get_param(varBlkPath,'BlockType'),'VariantSink');
    if~(isVarSrc||isVarSnk)
        return;
    end
    if strcmp(get_param(varBlkPath,'AllowZeroVariantControls'),'off')||...
        Simulink.variant.utils.defaultVariantExists(varBlkPath)
        compiledInactiveAZVCOffIVBlkToActivePortMap(varBlkPath)=str2double(compiledVarBlkChoiceInfo(varBlkFoundIdx).CompiledActiveChoice);%#ok<NASGU>
    end
end


function err=addSubModelConfigsImpl(rMgr)




    err=[];




    origRefMdlVCDOMap=containers.Map;
    topModelNameOrig=rMgr.getOptions().TopModelOrigName;


    try
        topModelName=rMgr.getOptions().TopModelName;

        modelsToBeHandled=rMgr.BDNameRedBDNameMap.values;
        modelsToBeHandledOrig=rMgr.BDNameRedBDNameMap.keys;



        refMdlVCDOMap=containers.Map(modelsToBeHandled,...
        cellfun(@(x)Simulink.variant.utils.getConfigurationDataNoThrow(x),...
        modelsToBeHandled,'UniformOutput',false));


        origRefMdlVCDOMap=containers.Map(modelsToBeHandled,...
        cellfun(@(x)getCopyOfVCDO(x,refMdlVCDOMap),...
        modelsToBeHandled,'UniformOutput',false));

        origRefMdlVCDONameMap=containers.Map(modelsToBeHandled,...
        cellfun(@(x)get_param(x,'VariantConfigurationObject'),...
        modelsToBeHandled,'UniformOutput',false));
        refMdlVCDONameMap=origRefMdlVCDONameMap;


        modelsToBeHandled=setdiff(modelsToBeHandled,topModelName);
        modelsToBeHandledOrig=setdiff(modelsToBeHandledOrig,topModelNameOrig);



        refMdlDepVarsMap=containers.Map(modelsToBeHandled,...
        cellfun(@(x)Simulink.VariantManager.findVariantControlVars(x),...
        modelsToBeHandled,'UniformOutput',false));



        for configIter=1:numel(rMgr.ProcessedModelInfoStructsVec.ConfigInfos)



            currConfigInfoStruct=rMgr.ProcessedModelInfoStructsVec.ConfigInfos(configIter);
            currConfigName=currConfigInfoStruct.ConfigName;
            currConfigActiveMdls=rMgr.ApplyConfigInfo.modelsActivePerConfigMap(currConfigName);
            currConfig=currConfigInfoStruct.Configuration;
            currConfigSubModelConfigStructsVec=currConfig.SubModelConfigurations;
            currConfigControlVarStructsVec=currConfig.ControlVariables;



            subModelConfigPairsToIgnoreMap=containers.Map(modelsToBeHandled,cell(1,numel(modelsToBeHandled)));


            subModelNameConfigNameMap=containers.Map(modelsToBeHandled,cell(1,numel(modelsToBeHandled)));
            subModelNameConfigNameMap(topModelName)=currConfigName;

            [currConfigControlVarStructsVec,subModelConfigPairsToIgnoreMap,subModelNameConfigNameMap]=...
            i_addControlVarsFromSubModelConfigs(topModelName,refMdlVCDOMap,...
            currConfigControlVarStructsVec,currConfigSubModelConfigStructsVec,rMgr.BDNameRedBDNameMap,...
            subModelConfigPairsToIgnoreMap,subModelNameConfigNameMap);



            for modelIter=1:numel(modelsToBeHandled)
                currModelOrig=modelsToBeHandledOrig{modelIter};
                currModel=rMgr.BDNameRedBDNameMap(currModelOrig);



                if~isempty(Simulink.variant.reducer.utils.searchNameInCell(currModelOrig,currConfigActiveMdls))

                    varsStructCurrMdl=refMdlDepVarsMap(currModel);
                    if isempty(varsStructCurrMdl)
                        subModelConfigPairsToIgnoreMap(currModel)=rMgr.SubModelToModelMap(currModel);
                        continue;
                    end

                    varStructsVec=getCtrlVariables();
                    currModelVCDO=setVCDOForModel();
                    nameOfConfig=getConfigName();
                    setVCDOMap();
                end
            end
            for modelIter=1:numel(modelsToBeHandled)
                childModelOrig=modelsToBeHandledOrig{modelIter};
                childModel=rMgr.BDNameRedBDNameMap(childModelOrig);
                if~isempty(Simulink.variant.reducer.utils.searchNameInCell(childModelOrig,currConfigActiveMdls))

                    modelsToAddSubModelConfig=setdiff(rMgr.SubModelToModelMap(childModel),subModelConfigPairsToIgnoreMap(childModel));
                    for midx=1:numel(modelsToAddSubModelConfig)
                        parentModel=modelsToAddSubModelConfig{midx};
                        parentVCDO=refMdlVCDOMap(parentModel);
                        parentConfigName=subModelNameConfigNameMap(parentModel);
                        childConfigName=subModelNameConfigNameMap(childModel);
                        parentVCDO.addSubModelConfigurations(parentConfigName,struct('ModelName',childModelOrig,'ConfigurationName',childConfigName));
                        refMdlVCDOMap(parentModel)=parentVCDO;
                    end
                end
            end

        end

        addVCDOForModel();
    catch ex %#ok<NASGU>  % visited as part of MLINT cleanup
        assignInConfigurationsSection();
    end

    function setVCDOMap()
        if isempty(subModelNameConfigNameMap(currModel))
            subModelNameConfigNameMap(currModel)=nameOfConfig;
            currModelVCDO.addConfiguration(nameOfConfig);
            currModelVCDO.addControlVariables(nameOfConfig,varStructsVec);
        end

        if~isempty(currModelVCDO)


            refMdlVCDOMap(currModel)=currModelVCDO;
        end
    end

    function currModelVCDO=setVCDOForModel()
        currModelVCDO=refMdlVCDOMap(currModel);
        if isempty(currModelVCDO)

            currModelVCDO=Simulink.VariantConfigurationData;
            VCDOName=Simulink.variant.reducer.utils.getUniqueName([currModel,'_VCDO'],refMdlVCDONameMap.values);
            refMdlVCDONameMap(currModel)=VCDOName;
            set_param(currModel,'VariantConfigurationObject',VCDOName);
        end
    end

    function nameOfConfig=getConfigName()
        if~isempty(currModelVCDO.VariantConfigurations)
            nameOfConfig=Simulink.variant.reducer.utils.getUniqueName(currConfigName,{currModelVCDO.VariantConfigurations.Name});
        else
            nameOfConfig=currConfigName;
        end
    end

    function varStructsVec=getCtrlVariables()
        varStructsVec=Simulink.variant.reducer.types.newEmptyControlVarStruct();
        varStructsVec(end)=[];
        for varIter=numel(varsStructCurrMdl):-1:1
            varStruct=Simulink.variant.reducer.types.newEmptyControlVarStruct();
            varStruct.Name=varsStructCurrMdl(varIter).Name;
            varIdx=Simulink.variant.reducer.utils.searchNameInCell(varsStructCurrMdl(varIter).Name,{currConfigControlVarStructsVec.Name});
            if isempty(varIdx)
                varStruct.Value=Simulink.variant.reducer.utils.i_num2str(varsStructCurrMdl(varIter).Value);
                currConfigControlVarStructsVec(end+1)=varStruct;%#ok<AGROW> % visited as part of MLINT cleanup
            else
                varStruct.Value=Simulink.variant.reducer.utils.i_num2str(currConfigControlVarStructsVec(varIdx).Value);
            end
            varStructsVec(varIter)=varStruct;
        end
    end

    function addVCDOForModel()
        models=refMdlVCDOMap.keys;
        for mdlIdx=1:numel(models)
            mdl=models{mdlIdx};
            toDelete=true;
            rMgr.getEnvironment().addVCDOForModel(mdl,refMdlVCDONameMap(mdl),refMdlVCDOMap(mdl),toDelete);
        end
    end

    function assignInConfigurationsSection()
        if isempty(origRefMdlVCDOMap)
            return;
        end
        mdlNames=origRefMdlVCDOMap.keys;
        for ii=1:numel(mdlNames)
            set_param(mdlNames{ii},'VariantConfigurationObject',origRefMdlVCDONameMap(mdlNames{ii}));
            if isempty(origRefMdlVCDOMap(mdlNames{ii}))
                continue;
            end
            Simulink.variant.utils.slddaccess.assignInConfigurationsSection(...
            mdlNames{ii},origRefMdlVCDONameMap(mdlNames{ii}),origRefMdlVCDOMap(mdlNames{ii}));
        end
    end
end

function[controlVarStructsVec,subModelConfigPairsToIgnoreMap,...
    subModelNameConfigNameMap]=i_addControlVarsFromSubModelConfigs(...
    topModelName,refMdlVCDOMap,controlVarStructsVec,...
    initSubModelConfigStructsVec,bdNameRedBDNameMap,...
    subModelConfigPairsToIgnoreMap,subModelNameConfigNameMap)







    subModelConfigStructsVec=Simulink.variant.reducer.types.VRedSubModelConfig.empty;

    subModelConfigStructsVec=modifySubModelConfigStruct(...
    topModelName,subModelConfigStructsVec,initSubModelConfigStructsVec);

    while~isempty(subModelConfigStructsVec)
        tempSubModelConfigStructsVec=Simulink.variant.reducer.types.VRedSubModelConfig.empty;
        for subModelIter=1:numel(subModelConfigStructsVec)
            subModelConfigStruct=subModelConfigStructsVec(subModelIter);
            subModelName=subModelConfigStruct.ModelName;
            subModelConfigurationName=subModelConfigStruct.ConfigurationName;

            if isKey(bdNameRedBDNameMap,subModelName)
                subModelNameRed=bdNameRedBDNameMap(subModelName);


                subModelVCDO=refMdlVCDOMap(subModelNameRed);
                subModelConfig=subModelVCDO.getConfiguration(subModelConfigurationName);


                subModelNameConfigNameMap(subModelNameRed)=subModelConfig.Name;
                subModelConfigPairsToIgnoreMap(subModelNameRed)=...
                [subModelConfigPairsToIgnoreMap(subModelNameRed),{subModelConfigStruct.ParentModelName}];

                tempControlVarStructsVec=subModelConfig.ControlVariables;
                for ii=numel(tempControlVarStructsVec):-1:1
                    if isfield(controlVarStructsVec,tempControlVarStructsVec(ii).Name)


                        tempControlVarStructsVec(ii)=[];
                    end
                end
                controlVarStructsVec=[controlVarStructsVec,tempControlVarStructsVec];%#ok<AGROW> % visited as part of MLINT cleanup
                tempSubModelConfigStructsVec=modifySubModelConfigStruct(...
                subModelNameRed,tempSubModelConfigStructsVec,subModelConfig.SubModelConfigurations);
            end
        end
        subModelConfigStructsVec=tempSubModelConfigStructsVec;
    end
end



function blks=ignoreModelBlksInLibUnderMLRoot(blks)
    for ii=numel(blks):-1:1
        libData=Simulink.variant.reducer.utils.getLibInfo(blks(ii));
        if isempty(libData),continue;end


        isResolved=arrayfun(@(x)any(strcmp(x.LinkStatus,{'resolved','implicit'})),libData,'UniformOutput',false);
        if~all(Simulink.variant.utils.i_cell2mat(isResolved)),continue;end
        [~,isLibUnderML]=arrayfun(@(x)Simulink.variant.utils.resolveBDFile(x.Library),libData,'UniformOutput',false);
        if any(Simulink.variant.utils.i_cell2mat(isLibUnderML)),blks(ii)=[];end
    end
end



function renameBlockChoiceInfoStructsVec(rMgr)



    for modelIter=2:numel(rMgr.ModelRefModelInfoStructsVec)

        varBlkChoiceInfoStructsVec=rMgr.ModelRefModelInfoStructsVec(modelIter).VarBlkChoiceInfoStructsVec;
        rMgr.ModelRefModelInfoStructsVec(modelIter).VarBlkChoiceInfoStructsVec=...
        modifyBlockInfo(rMgr,varBlkChoiceInfoStructsVec);


        compiledSpecialBlockInfo=rMgr.ModelRefModelInfoStructsVec(modelIter).CompiledSpecialBlockInfo;
        rMgr.ModelRefModelInfoStructsVec(modelIter).CompiledSpecialBlockInfo=...
        modifyBlockInfo(rMgr,compiledSpecialBlockInfo);
    end
end

function blkInfoVec=modifyBlockInfo(rMgr,blkInfoVec)
    for blkIter=1:numel(blkInfoVec)
        blkChoiceInfo=blkInfoVec(blkIter);
        blkPath=blkChoiceInfo.BlockPath;
        origName=i_getRootBDNameFromPath(blkPath);
        Simulink.variant.reducer.utils.assert(isKey(rMgr.BDNameRedBDNameMap,origName));
        redName=rMgr.BDNameRedBDNameMap(origName);

        blkChoiceInfo.BlockPath=[redName,blkPath((length(origName)+1):end)];
        if isprop(blkChoiceInfo,'BlockType')
            if blkChoiceInfo.BlockType.isVariantSubsystem()


                blkChoiceInfo.AllChoiceNames=cellfun(@(x)[redName,x((length(origName)+1):end)],blkChoiceInfo.AllChoiceNames,'UniformOutput',false);
                blkChoiceInfo.ActiveChoiceNames=cellfun(@(x)[redName,x((length(origName)+1):end)],blkChoiceInfo.ActiveChoiceNames,'UniformOutput',false);
            end
        end
        blkInfoVec(blkIter)=blkChoiceInfo;
    end
end




function err=getErrorForRestrictedModels(rMgr)
    err=[];
    modelStructsVec=rMgr.ModelRefModelInfoStructsVec;
    nModels=numel(modelStructsVec);

    errFlagVec(1,nModels)=false;

    for mdlI=1:nModels
        modelStruct=modelStructsVec(mdlI);
        modelName=modelStruct.Name;


        if~isfield(get_param(modelName,'ObjectParameters'),'EditingMode')...
            ||~strcmp(get_param(modelName,'EditingMode'),'Restricted')
            continue;
        end

        blksSVCEMap=modelStruct.BlksSVCEMap;
        totalBlocksToDel=blksSVCEMap.keys;
        totalBlocksToDel=(totalBlocksToDel(~Simulink.variant.utils.i_cell2mat(blksSVCEMap.values)))';
        totalBlocksToDel=i_removeBlksInSFChartFromList(totalBlocksToDel);



        for blkI=1:numel(totalBlocksToDel)
            if Simulink.variant.utils.isPhysModBlk(totalBlocksToDel{blkI}),errFlagVec(mdlI)=true;break;end
        end


        if errFlagVec(mdlI),continue;end

        errFlagVec=setErrorFlagForPhysmodVarBlks(modelStruct,errFlagVec,mdlI);
    end

    if~any(errFlagVec),return;end

    modelNamesCell={modelStructsVec.OrigName};
    modelNamesCell=modelNamesCell(errFlagVec);
    err=createRestrictedModelException(rMgr,modelNamesCell);
end

function errFlagVec=setErrorFlagForPhysmodVarBlks(modelStruct,errFlagVec,mdlI)




    varBlkChoiceInfoStructsVec=modelStruct.VarBlkChoiceInfoStructsVec;
    for varBlkI=1:numel(varBlkChoiceInfoStructsVec)
        varBlkStruct=varBlkChoiceInfoStructsVec(varBlkI);
        varBlkType=varBlkStruct.BlockType;
        varBlkPath=varBlkStruct.BlockPath;
        if~Simulink.variant.utils.isPhysModBlk(varBlkPath),continue;end
        if~varBlkType.isVariantSubsystem,continue;end
        if~isempty(setdiff(varBlkStruct.AllChoiceNames,varBlkStruct.ActiveChoiceNames))...
            ||numel(varBlkStruct.ActiveChoiceNames)==1
            errFlagVec(mdlI)=true;break;
        end
    end
end

function err=createRestrictedModelException(rMgr,modelNamesCell)


    if numel(modelNamesCell)==1
        if strcmp(rMgr.getOptions().TopModelOrigName,modelNamesCell{1})

            err=MException(message('Simulink:Variants:ReducerRestrictedTopModel',...
            rMgr.getOptions().TopModelOrigName));
        else
            err=MException(message('Simulink:Variants:ReducerRestrictedModel',...
            rMgr.getOptions().TopModelOrigName,modelNamesCell{1}));
        end
    else
        err=MException(message('Simulink:Variants:ReducerRestrictedModels',...
        rMgr.getOptions().TopModelOrigName,i_cellOfStringsToCSV(modelNamesCell)));
    end
end



function vcdoCopy=getCopyOfVCDO(mdl,mdlVCDOMap)
    vcdoCopy=[];
    tempVcdo=mdlVCDOMap(mdl);
    if~isempty(tempVcdo)
        vcdoCopy=copy(tempVcdo);
    end
end

function subModelConfigStructsVec=modifySubModelConfigStruct(...
    modelName,subModelConfigStructsVec,initSubModelConfigStructsVec)


    for ii=numel(initSubModelConfigStructsVec):-1:1
        subModelConfigStruct=Simulink.variant.reducer.types.VRedSubModelConfig;
        subModelConfigStruct.ParentModelName=modelName;
        subModelConfigStruct.ModelName=initSubModelConfigStructsVec(ii).ModelName;
        subModelConfigStruct.ConfigurationName=initSubModelConfigStructsVec(ii).ConfigurationName;
        subModelConfigStructsVec(ii)=subModelConfigStruct;
    end
end



function stringofControlvars=convertControlVarsStructToString(structofControlVars)
    stringofControlvars='';
    N=numel(structofControlVars);



    for ii=1:N
        if~Simulink.variant.reducer.utils.isScalarParameterObj(structofControlVars(ii).Value)


            structofControlVars(ii).Value=str2num(structofControlVars(ii).Value);%#ok<ST2NM>  % visited as part of MLINT cleanup
        end
        stringofControlvars=[stringofControlvars,structofControlVars(ii).Name,' = ',Simulink.variant.reducer.utils.convertCVV2String(structofControlVars(ii).Value),', '];%#ok<AGROW>  % visited as part of MLINT cleanup
    end
    if~isempty(stringofControlvars)

        stringofControlvars(end-1:end)=[];
    end
end

function modelVsConfigMap=getModelVsConfigMapPerConfiguration(topModelName,validationLog)
    modelVsConfigMap=containers.Map;
    for ii=1:numel(validationLog)
        currValidationLog=validationLog(ii);

        if strcmp(currValidationLog.Model,topModelName)
            continue;
        end

        if isempty(currValidationLog.Configuration)||isempty(currValidationLog.Configuration.Name)
            continue;
        end

        modelVsConfigMap(currValidationLog.Model)=currValidationLog.Configuration.Name;
    end
end




