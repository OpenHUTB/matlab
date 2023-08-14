function copyBDs(rMgr)






































    handleRefMdls(rMgr);
    handleLibs(rMgr);
    handleSRs(rMgr);
    errorOnLibWithAttachedDD(rMgr);
    computeBDLevelInfo(rMgr);
    rMgr.saveBDCopies();
    rMgr.throwOnError();
end

function computeBDLevelInfo(rMgr)




    allBlkInfo=rMgr.AllRefBlocksInfo.getAllRefBlks();
    for blkIdx=1:numel(allBlkInfo)
        blkInfo=allBlkInfo{blkIdx};
        redBD=getReferredReducedModel(rMgr,blkInfo);
        if isempty(redBD)




            continue;
        end


        withCallBacks=false;
        Simulink.variant.reducer.utils.loadSystem(which(redBD),withCallBacks);
        insertBDAtLevel(rMgr.RedBDLevelMap,redBD,blkInfo.Level);
        appendMaskedBDsToRedBDLevelMap(rMgr,blkInfo);
    end
end

function insertBDAtLevel(lvlInfoForRefBDs,redBD,level)


    if isKey(lvlInfoForRefBDs,level)
        currBDsAtThisLevel=lvlInfoForRefBDs(level);
        currBDsAtThisLevel{end+1}=redBD;
        lvlInfoForRefBDs(level)=unique(currBDsAtThisLevel);%#ok<NASGU>
    else
        lvlInfoForRefBDs(level)={redBD};%#ok<NASGU>
    end
end

function appendMaskedBDsToRedBDLevelMap(rMgr,blkInfo)
































    if Simulink.variant.reducer.enums.BDType.LIBRARY~=blkInfo.RefersToBDType
        return;
    end
    refBlk=blkInfo.RefersTo;
    currLevel=blkInfo.Level;
    hasLinkedRefBlk=isequal(get_param(refBlk,'StaticLinkStatus'),'resolved');
    while hasLinkedRefBlk
        libInfo=libinfo(refBlk,'FollowLinks',false);
        Simulink.variant.reducer.utils.assert(numel(libInfo)<2);
        if isempty(libInfo)
            break;
        end
        redBD=rMgr.BDNameRedBDNameMap(libInfo.Library);
        currLevel=currLevel+1;
        insertBDAtLevel(rMgr.RedBDLevelMap,redBD,currLevel);
        refBlk=libInfo.ReferenceBlock;
        hasLinkedRefBlk=isequal(get_param(refBlk,'StaticLinkStatus'),'resolved');
    end
end

function redBD=getReferredReducedModel(rMgr,blkInfo)







    redBD='';
    referredBD=i_getRootBDNameFromPath(blkInfo.RefersTo);
    if rMgr.AllRefBlocksInfo.isSubsystemReferenceBlock(blkInfo.BlockInstance)...
        &&isKey(rMgr.SRBlkInstToRedSRBD,blkInfo.BlockInstance)


        redBD=rMgr.SRBlkInstToRedSRBD(blkInfo.BlockInstance);
    elseif isKey(rMgr.BDNameRedBDNameMap,referredBD)
        redBD=rMgr.BDNameRedBDNameMap(referredBD);
    end
end

function handleSRs(rMgr)



    if slfeature('VariantReducerForSubsystemReference')<1
        return;
    end
    handleSRInsideModel(rMgr);
    handleSRInsideLibrary(rMgr);
    handleSRInsideSR(rMgr);
    fixModelsInsideSR(rMgr);
    fixLibraryInsideSR(rMgr);
    fixImplictModelBlksUnderSR(rMgr);
end

function fixImplictModelBlksUnderSR(rMgr)





    for idx=1:numel(rMgr.ModelBlocksInLinkedSR)
        mdlBlk=rMgr.ModelBlocksInLinkedSR{idx};
        if isKey(rMgr.AllLibBlksMap,mdlBlk)
            rMgr.ModelBlocksInLib(end+1)={mdlBlk};
        end
    end
end

function fixLibraryInsideSR(rMgr)


    libInSR=rMgr.AllRefBlocksInfo.getLibraryInsideSR();
    for idx=1:numel(libInSR)
        blkInfo=libInSR{idx};
        blkInSR=Simulink.variant.reducer.utils.getDefinitionBlock(blkInfo);
        linkedBlkHandle=getBlockHandleForReducedModel(rMgr,blkInfo.RefersTo,blkInfo);
        if linkedBlkHandle<0




            continue;
        end
        blkInRedSR=getBlockInRedSR(rMgr,blkInSR,blkInfo);
        redLibBlkHandle=getSimulinkBlockHandle(blkInRedSR);
        if~isKey(rMgr.ProcessedLibBlksInRedSRBD,redLibBlkHandle)
            set_param(blkInRedSR,'ReferenceBlock',getfullname(linkedBlkHandle));
            rMgr.ProcessedLibBlksInRedSRBD(redLibBlkHandle)=redLibBlkHandle;
        end
    end
end

function fixModelsInsideSR(rMgr)


    mdlBlkInfo=rMgr.AllRefBlocksInfo.getModelInsideSR();
    for idx=1:numel(mdlBlkInfo)
        blkInfo=mdlBlkInfo{idx};
        mdlBlkInSR=Simulink.variant.reducer.utils.getDefinitionBlock(blkInfo);
        mdlBlkInRedSR=getBlockInRedSR(rMgr,mdlBlkInSR,blkInfo);
        mdlBlkHandle=getSimulinkBlockHandle(mdlBlkInRedSR);
        if~isKey(rMgr.ProcessedMdlBlksInRedSRBD,mdlBlkHandle)
            rMgr.i_modifyMdlRefBlkLink(mdlBlkInRedSR);
            rMgr.ProcessedMdlBlksInRedSRBD(mdlBlkHandle)=mdlBlkHandle;
        end
    end
end

function copySRs(rMgr,SRBlkInfo)




    for idx=1:numel(SRBlkInfo)
        blkInfo=SRBlkInfo{idx};
        blkInst=Simulink.variant.reducer.utils.getDefinitionBlock(blkInfo);
        redBH=getBlockHandleForReducedModel(rMgr,blkInst,blkInfo);
        if redBH<0




            continue;
        end
        if isKey(rMgr.ProcessedSRInstancesInRedBD,redBH)
            rMgr.SRBlkInstToRedSRBD(blkInfo.BlockInstance)=...
            rMgr.ProcessedSRInstancesInRedBD(redBH);
            continue;
        end
        redMdlName=strcat(blkInfo.RefersTo,rMgr.getOptions().Suffix);
        [~,~,ext]=fileparts(blkInfo.RefersToFilePath);
        redMdlName=Simulink.variant.reducer.utils.getUniqueFileName(...
        redMdlName,{'.slx','.mdl',ext},{});
        destFilePath=fullfile(rMgr.getOptions().AbsOutDirPath,strcat(redMdlName,ext));
        rMgr.SRBlkInstToRedSRBD(blkInfo.BlockInstance)=redMdlName;
        rMgr.Error=i_copyBDAndLoad(blkInfo.RefersToFilePath,destFilePath,rMgr);
        rMgr.throwOnError();
        set_param(redBH,'ReferencedSubsystem',redMdlName);
        rMgr.ProcessedSRInstancesInRedBD(redBH)=redMdlName;
    end
end

function handleSRInsideSR(rMgr)

    SRBlkInfo=rMgr.AllRefBlocksInfo.getSRInsideSR();
    copySRs(rMgr,SRBlkInfo);
end

function handleSRInsideModel(rMgr)

    SRBlkInfo=rMgr.AllRefBlocksInfo.getSRInsideModel();
    copySRs(rMgr,SRBlkInfo);
end

function handleSRInsideLibrary(rMgr)

    SRBlkInfo=rMgr.AllRefBlocksInfo.getSRInsideLibrary();
    copySRs(rMgr,SRBlkInfo);
end

function libInfo=getLibInfoForImplicitSRBlocks(blkInfo,blkInsideSR)









    libInfo=struct(...
    'Block','',...
    'Library','',...
    'ReferenceBlock','',...
    'LinkStatus','',...
    'FromLibrary',false...
    );
    libName=i_getRootBDNameFromPath(blkInfo.ReferredFrom);

    libInfo.Block=blkInsideSR;
    libInfo.Library=libName;
    libInfo.ReferenceBlock=Simulink.variant.reducer.utils.getDefinitionInstanceFromModelInstance(blkInfo,blkInsideSR);
    libInfo.LinkStatus='implicit';
end

function nonLinkedBlks=getNonLinkedActiveBlks(activeBlks)
    linkStatus=get_param(activeBlks,'StaticLinkStatus');
    nonLinkedIndices=strcmp(linkStatus,'none');
    nonLinkedBlks=activeBlks(nonLinkedIndices);
end

function appendAllLibInfoWithImplicitSRBlocks(rMgr,nonLinkedBlks,currSRBlkInfo)



    for blkIdx=1:numel(nonLinkedBlks)
        currActiveBlk=nonLinkedBlks{blkIdx};


        isCurrBlkInsideSR=startsWith(currActiveBlk,currSRBlkInfo.BlockInstance);
        currBlkHandle=getSimulinkBlockHandle(currActiveBlk);
        isNewBlk=~isKey(rMgr.ProcessedImplicitSRBlocks,currBlkHandle);
        if isCurrBlkInsideSR&&isNewBlk
            libInfo=getLibInfoForImplicitSRBlocks(currSRBlkInfo,currActiveBlk);
            rMgr.AllLibInfo(end+1)=libInfo;


            rMgr.ProcessedImplicitSRBlocks(currBlkHandle)=currBlkHandle;
        end
    end
end

function computeImplicitSRBlocks(rMgr,activeBlks)











    if slfeature('VariantReducerForSubsystemReference')<1
        return;
    end

    nonLinkedBlks=getNonLinkedActiveBlks(activeBlks);
    lvlOrderedSRBlkInfo=rMgr.AllRefBlocksInfo.getLevelOrderedSRBlksInsideLibrary('descend');
    for SRInfoIdx=1:numel(lvlOrderedSRBlkInfo)
        currSRBlkInfo=lvlOrderedSRBlkInfo(SRInfoIdx);
        appendAllLibInfoWithImplicitSRBlocks(rMgr,nonLinkedBlks,currSRBlkInfo);
    end
end

function handleRefMdls(rMgr)

    rMgr.ModelRefModelInfoStructsVec(1).FullPath=rMgr.ProcessedModelInfoStructsVec.FullPath;
    for mrefIdx=2:numel(rMgr.ModelRefModelInfoStructsVec)
        copyAndLoadModels(rMgr,mrefIdx);
    end
    fixRefModelLinks(rMgr);
end

function handleLibs(rMgr)



    computeAllLibInfo(rMgr);
    if isempty(rMgr.AllLibInfo)
        return;
    end
    computeLibsToCopy(rMgr);
    if isempty(rMgr.LibsToCopy)
        return;
    end

    computeResolveLibInfo(rMgr);
    throwForDirtyLibs(rMgr);
    copyLibraries(rMgr);
    modifyResLibInfoWithSuffix(rMgr);
    findBDforResolvedBlks(rMgr);
    setReferenceBlockProperty(rMgr);
    createBlocksToReferenceBlocksMap(rMgr);
    modifyModelBlksInLib(rMgr);
end

function copyAndLoadModels(rMgr,mrefIdx)

    currModel=rMgr.ModelRefModelInfoStructsVec(mrefIdx).OrigName;


    currModelRedName=Simulink.variant.reducer.utils.getUniqueName(...
    [currModel,rMgr.getOptions().Suffix],{rMgr.ModelRefModelInfoStructsVec.OrigName});
    fullNameWithPathOrig=get_param(currModel,'FileName');
    [~,~,ext]=fileparts(fullNameWithPathOrig);
    fullNameWithPath=[rMgr.getOptions().AbsOutDirPath,filesep,currModelRedName,ext];
    rMgr.ModelRefModelInfoStructsVec(mrefIdx).FullPath=fullNameWithPath;
    rMgr.BDNameRedBDNameMap(currModel)=currModelRedName;
    rMgr.Error=i_copyBDAndLoad(fullNameWithPathOrig,fullNameWithPath,rMgr);
    rMgr.throwOnError();
    rMgr.ModelRefModelInfoStructsVec(mrefIdx).Name=currModelRedName;
end

function fixRefModelLinks(rMgr)


    mdlBlksInLib=rMgr.ActiveMdlRefBlks;
    for mdlBlkIter=numel(rMgr.ActiveMdlRefBlks):-1:1
        mdlRefBlk=rMgr.ActiveMdlRefBlks{mdlBlkIter};
        if rMgr.AllRefBlocksInfo.isBlockInsideSubsystemReference(mdlRefBlk)
            mdlBlksInLib(mdlBlkIter)=[];
            rMgr.ModelBlocksInLinkedSR(end+1)={mdlRefBlk};
            continue;
        end
        if~any(strcmp(get_param(mdlRefBlk,'StaticLinkStatus'),{'resolved','implicit'}))
            mdlBlksInLib(mdlBlkIter)=[];
            rMgr.i_modifyMdlRefBlkLink(mdlRefBlk);
        end
    end
    rMgr.ModelBlocksInLib=mdlBlksInLib;
    processedMdlName=rMgr.BDNameRedBDNameMap(rMgr.ProcessedModelInfoStructsVec.OrigName);
    rMgr.ProcessedModelInfoStructsVec.Name=processedMdlName;
end

function computeAllLibInfo(rMgr)
    compiledBlocks={rMgr.ProcessedModelInfoStructsVec(1).ConfigInfos.CompiledBlocks};


    activeBlks=vertcat(compiledBlocks{:});
    activeBlks=unique(activeBlks);



    activeBlks=i_pruneOutInvalidBlks(activeBlks);
    rMgr.AllLibInfo=Simulink.variant.reducer.utils.getLibInfo(activeBlks);
    computeImplicitSRBlocks(rMgr,activeBlks);
end

function computeResolveLibInfo(rMgr)


    rMgr.ResMRLibInfo=rMgr.ResolvedLibBlockInfo(...
    cellfun(...
    @(x)~any(strcmp(x,rMgr.LibsToCopy)),...
    {rMgr.ResolvedLibBlockInfo.Library}...
    )...
    );


    rMgr.ResolvedLibBlockInfo=rMgr.ResolvedLibBlockInfo(...
    cellfun(...
    @(x)any(strcmp(x,rMgr.LibsToCopy)),...
    {rMgr.ResolvedLibBlockInfo.Library}...
    )...
    );
end

function computeLibsToCopy(rMgr)
    throwForDisabledLinks(rMgr);

    rMgr.ResolvedLibBlockInfo=rMgr.AllLibInfo;
    rMgr.ResolvedLibBlockInfo(~strcmp('resolved',{rMgr.ResolvedLibBlockInfo.LinkStatus}))=[];


    rMgr.LibsToCopy=unique({rMgr.ResolvedLibBlockInfo.Library});



    [rMgr.LibsToCopyWithPath,libIdxUnderML]=...
    cellfun(@(x)Simulink.variant.utils.resolveBDFile(x),rMgr.LibsToCopy,'UniformOutput',false);
    libIdxUnderML=Simulink.variant.utils.i_cell2mat(libIdxUnderML);
    rMgr.LibsToCopyWithPath(libIdxUnderML)=[];
    rMgr.LibsToCopy(libIdxUnderML)=[];
end

function copyLibraries(rMgr)


    suffix=rMgr.getOptions().Suffix;
    for libIter=numel(rMgr.LibsToCopy):-1:1
        libName=rMgr.LibsToCopy{libIter};
        libFullPathOrig=rMgr.LibsToCopyWithPath{libIter};

        redLibName=Simulink.variant.reducer.utils.getUniqueName([libName,suffix],...
        [rMgr.BDNameRedBDNameMap.keys,rMgr.LibsToCopy]);
        [~,~,ext]=fileparts(libFullPathOrig);
        libFullPath=[rMgr.getOptions().AbsOutDirPath,filesep,redLibName,ext];
        rMgr.LibInfoStructsVec(libIter).FullPath=libFullPath;
        rMgr.BDNameRedBDNameMap(libName)=redLibName;
        rMgr.Error=i_copyBDAndLoad(libFullPathOrig,libFullPath,rMgr);
        rMgr.throwOnError();

        set_param(redLibName,'Lock','off');
    end
end

function modifyResLibInfoWithSuffix(rMgr)


    for libBlkIter=1:numel(rMgr.ResolvedLibBlockInfo)
        currLibInfo=rMgr.ResolvedLibBlockInfo(libBlkIter);
        currLib=currLibInfo.Library;
        Simulink.variant.reducer.utils.assert(isKey(rMgr.BDNameRedBDNameMap,currLib))
        currLibInfo.Library=rMgr.BDNameRedBDNameMap(currLib);
        currLibInfo.ReferenceBlock=[rMgr.BDNameRedBDNameMap(currLib),currLibInfo.ReferenceBlock(numel(currLib)+1:end)];

        if currLibInfo.FromLibrary
            blkLib=i_getRootBDNameFromPath(currLibInfo.Block);
            Simulink.variant.reducer.utils.assert(isKey(rMgr.BDNameRedBDNameMap,blkLib))
            currLibInfo.Block=[rMgr.BDNameRedBDNameMap(blkLib),currLibInfo.Block(numel(blkLib)+1:end)];
        end

        rMgr.ResolvedLibBlockInfo(libBlkIter)=currLibInfo;
    end
end

function setReferenceBlockProperty(rMgr)


    resBlks={rMgr.ResolvedLibBlockInfo.Block};
    for ii=1:numel(resBlks)
        refBlk=rMgr.ResolvedLibBlockInfo(ii).ReferenceBlock;
        libBlk=resBlks{ii};
        if rMgr.AllRefBlocksInfo.isBlockInsideSubsystemReference(libBlk)
            continue;
        end
        set_param(rMgr.AllLibBlksMap(libBlk),'ReferenceBlock',refBlk);
    end
end

function throwForDirtyLibs(rMgr)
    resLibInfo=rMgr.ResolvedLibBlockInfo;
    dirtyFlagArray(1,numel(resLibInfo))=false;
    for ii=1:numel(resLibInfo)
        origLibName=resLibInfo(ii).Library;
        dirtyFlagArray(ii)=bdIsLoaded(origLibName)&&strcmp('on',get_param(origLibName,'dirty'));
    end

    if~any(dirtyFlagArray)
        return;
    end


    libs={resLibInfo.Library};
    dirtyLibs=strjoin(libs(dirtyFlagArray),', ');
    errid='Simulink:VariantReducer:InvalidOrigLibDirty';
    errmsg=message(errid,rMgr.getOptions().TopModelOrigName,dirtyLibs);
    err=MException(errmsg);
    throw(err);
end

function throwForDisabledLinks(rMgr)




    disabledLibInfo=rMgr.AllLibInfo;
    disabledLibInfo(~strcmp('inactive',{disabledLibInfo.LinkStatus}))=[];
    if isempty(disabledLibInfo)
        return;
    end
    eid='Simulink:Variants:ReducerDisabledLinks';
    disabledLinks=[newline,strjoin({disabledLibInfo.Block},newline)];
    err=MException(message(eid,rMgr.getOptions().TopModelOrigName,disabledLinks));
    throw(err);
end

function modifyModelBlksInLib(rMgr)


    mdlRefBlks=rMgr.ModelBlocksInLib;
    mdlBlksAnalyzed={};
    for iter=1:numel(mdlRefBlks)
        mdlRefBlk=mdlRefBlks{iter};
        Simulink.variant.reducer.utils.assert(isKey(rMgr.AllLibBlksMap,mdlRefBlk));
        mdlRefBlk=rMgr.AllLibBlksMap(mdlRefBlk);
        if iscell(mdlRefBlk)


            Simulink.variant.reducer.utils.assert(numel(mdlRefBlk)==2);
            tempRefsBlock=mdlRefBlk;
            mdlRefBlkTemp=mdlRefBlk;
            while~isempty(tempRefsBlock)



                [tempRefsBlock,mdlRefBlkTemp]=accumulateRefsForBlkIteratively(rMgr,tempRefsBlock,mdlRefBlkTemp);
            end
            mdlRefBlk=mdlRefBlkTemp{end};
        else
            mdlRefBlkTemp={mdlRefBlk};
        end





        if~isempty(i_searchNameInCell(mdlRefBlk,mdlBlksAnalyzed))
            continue;
        end


        rMgr.i_modifyMdlRefBlkLink(mdlRefBlk);
        mdlBlksAnalyzed{end+1}=mdlRefBlk;%#ok<AGROW> % visited as part of MLINT cleanup






        if isempty(mdlRefBlkTemp),continue;end
        for ij=numel(mdlRefBlkTemp):-1:1
            try
                mdlBlkObj=get_param(mdlRefBlkTemp{ij},'Object');
                mdlBlkObj.refreshModelBlock;
            catch me %#ok<NASGU> % visited as part of MLINT cleanup
            end
        end
    end
end

function createBlocksToReferenceBlocksMap(rMgr)


    ignoreIdx=~(strcmp({rMgr.AllLibInfo.LinkStatus},'implicit')|strcmp({rMgr.AllLibInfo.LinkStatus},'resolved'));
    rMgr.AllLibInfo(ignoreIdx)=[];
    tempLibInfo=rMgr.AllLibInfo;
    for ii=1:numel(tempLibInfo)
        libName=tempLibInfo(ii).Library;
        if~isKey(rMgr.BDNameRedBDNameMap,libName),continue;end
        refBlk=tempLibInfo(ii).ReferenceBlock;

        if tempLibInfo(ii).FromLibrary
            blkLib=i_getRootBDNameFromPath(tempLibInfo(ii).Block);
            Simulink.variant.reducer.utils.assert(isKey(rMgr.BDNameRedBDNameMap,blkLib))
            tempLibInfo(ii).Block=[rMgr.BDNameRedBDNameMap(blkLib),tempLibInfo(ii).Block(numel(blkLib)+1:end)];
        end

        updateBlk=i_replaceCarriageReturnWithSpace([rMgr.BDNameRedBDNameMap(libName),refBlk((numel(libName)+1):end)]);

        if~isKey(rMgr.AllLibBlksMap,tempLibInfo(ii).Block)
            rMgr.AllLibBlksMap(tempLibInfo(ii).Block)=updateBlk;
        else





            rMgr.AllLibBlksMap(tempLibInfo(ii).Block)={rMgr.AllLibBlksMap(tempLibInfo(ii).Block);updateBlk};
        end
    end
end

function findBDforResolvedBlks(rMgr)





    resLibInfo=[rMgr.ResolvedLibBlockInfo;rMgr.ResMRLibInfo];
    rMgr.AllLibBlksMap=containers.Map();
    if isempty(resLibInfo),return;end

    resBlks={resLibInfo.Block}';
    rMgr.AllLibBlksMap=containers.Map(resBlks,cell(1,numel(resLibInfo)));
    resBlkToNextResBlksMap=getNearestResovledBlock(resBlks);
    resBlkKeys=resBlkToNextResBlksMap.keys;


    for ii=1:length(resBlkToNextResBlksMap)
        prevResBlk=resBlkKeys{ii};

        blks=resBlkToNextResBlksMap(prevResBlk);
        for ij=1:numel(blks)
            blk=blks{ij};
            Simulink.variant.reducer.utils.assert(isKey(rMgr.AllLibBlksMap,blk));
            callingBlk=blk;
            callingBlockRoot=i_getRootBDNameFromPath(callingBlk);
            if isKey(rMgr.BDNameRedBDNameMap,callingBlockRoot)
                callingBlk=[rMgr.BDNameRedBDNameMap(callingBlockRoot),callingBlk((numel(callingBlockRoot)+1):end)];
            end
            if isKey(rMgr.AllLibBlksMap,prevResBlk)

                idx=i_searchNameInCell(prevResBlk,resBlks);
                Simulink.variant.reducer.utils.assert(~isempty(idx));
                callingBlk=[resLibInfo(idx).ReferenceBlock,blk((numel(prevResBlk)+1):end)];
            end
            rMgr.AllLibBlksMap(blk)=callingBlk;
        end
    end
end

function resBlkToNextResBlksMap=getNearestResovledBlock(resBlks)
    resBlkToNextResBlksMap=containers.Map();
    for ii=1:numel(resBlks)
        blk=resBlks{ii};
        pBlks=i_getAllParentBlksExcludingRoot(blk);
        prevResBlk=i_getRootBDNameFromPath(blk);
        for ij=numel(pBlks):-1:1
            if~isempty(i_searchNameInCell(pBlks{ij},resBlks))
                prevResBlk=pBlks{ij};
                break;
            end
        end
        if isKey(resBlkToNextResBlksMap,prevResBlk)
            resBlkToNextResBlksMap(prevResBlk)=[resBlkToNextResBlksMap(prevResBlk);blk];
        else
            resBlkToNextResBlksMap(prevResBlk)={blk};
        end
    end
end

function errorOnLibWithAttachedDD(rMgr)
    topMdl=rMgr.ReductionOptions.TopModelOrigName;



    refMdls=rMgr.AllRefBlocksInfo.getActiveMdlRefs();
    allMdls=horzcat(topMdl,refMdls);
    allMdls=unique(allMdls);
    exceptionList={};
    for mdlIdx=1:numel(allMdls)
        currMdl=allMdls{mdlIdx};
        isProtected=Simulink.variant.utils.getIsProtectedModelAndFullFile(currMdl);
        if isProtected


            continue;
        end

        ddAttachedToLibs=slprivate('getAllDictionariesOfLibrary',currMdl);
        if isempty(ddAttachedToLibs)
            continue;
        end
        errid='Simulink:VariantReducer:LibraryDataDictionaryNotSupported';
        libsWithDDStr=strjoin(ddAttachedToLibs,', ');
        msg=message(errid,currMdl,libsWithDDStr);
        exceptionList{end+1}=MException(msg);%#ok<AGROW>
    end

    if isempty(exceptionList)
        return;
    elseif numel(exceptionList)==1


        throw(exceptionList{1});
    else


        errid='SL_SERVICES:utils:MultipleErrorsMessagePreamble';
        err=MException(message(errid));
        for idx=1:numel(exceptionList)
            err=err.addCause(exceptionList{idx});
        end
        throw(err);
    end
end


