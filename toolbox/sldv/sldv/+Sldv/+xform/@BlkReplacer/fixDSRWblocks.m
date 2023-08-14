function fixDSRWblocks(obj,mdlRefItem,sharedLocalDSMToNewNameMap,dsmNamesToUpdate)





    assert(isa(mdlRefItem,'Sldv.xform.RepMdlRefBlkTreeNode'),...
    getString(message('Sldv:xform:BlkReplacer:BlkReplacer:OnlyModelRefsAllowed')));

    modelRefBlkTree=obj.MdlInfo.ModelRefBlkTree;

    topDSMInfo=modelRefBlkTree.DSMRWInformation;
    bottomDSMInfo=mdlRefItem.DSMRWInformation;

    inlinedSSPath=getfullname(mdlRefItem.ReplacementInfo.AfterReplacementH);
    refMdlName=mdlRefItem.RefMdlName;

    replacementModelName=getfullname(obj.MdlInfo.ModelH);

    if obj.MdlInlinerOnlyMode&&~isempty(topDSMInfo)
        origMdl=get_param(obj.InlinerOrigMdlH,'Name');
        for j=1:length(topDSMInfo)
            topDSMInfo(j)=fixBlockPath(topDSMInfo(j),...
            inlinedSSPath,origMdl);
        end
    end

    refmodelH=get_param(refMdlName,'Handle');
    refMdlWs=get_param(refmodelH,'modelworkspace');
    topMdlWs=get_param(obj.MdlInfo.ModelH,'modelworkspace');

    for idx=1:length(bottomDSMInfo)
        currentBotDSMInfo=fixBlockPath(bottomDSMInfo(idx),inlinedSSPath,refMdlName);
        skipLiftSignal=false;



        sharedAcrossModelInstances=false;
        sharedLocalDSMBlock=[];
        for idx2=1:length(currentBotDSMInfo.FullPath)
            isSharedLocalDSM=strcmp('on',get_param(currentBotDSMInfo.FullPath{idx2},'ShareAcrossModelInstances'));
            if isSharedLocalDSM
                sharedAcrossModelInstances=true;
                sharedLocalDSMBlock=currentBotDSMInfo.FullPath{idx2};
                numCharsToSkip=numel(inlinedSSPath)+1;
                sharedLocalDSMBlock=[refMdlName,sharedLocalDSMBlock(numCharsToSkip:end)];
                sharedLocalDSMBlock2=currentBotDSMInfo.FullPath{idx2};
                break;
            end
        end

        if sharedAcrossModelInstances
            assert(~isempty(sharedLocalDSMBlock));



            if any(strcmp(currentBotDSMInfo.Type,{'localdsmbws','globalsignalbws'}))


                errMsg=getString(message('Sldv:Compatibility:SharedLocalDSMBaseWS',sharedLocalDSMBlock));
                newExc=MException('Sldv:Compatibility:SharedLocalDSMBaseWS',errMsg);
                throw(newExc);
            end



            if~allDSMsResolveToSameBlock(currentBotDSMInfo,sharedLocalDSMBlock2)||~(numel(currentBotDSMInfo.FullPath)==1)


                errMsg=getString(message('Sldv:Compatibility:SharedLocalDSMSignalMultipleDSMs',sharedLocalDSMBlock));
                newExc=MException('Sldv:Compatibility:SharedLocalDSMSignalMultipleDSMs',errMsg);
                throw(newExc);
            end

            [currentBotDSMInfo,sharedLocalDSMToNewNameMap,dsmNamesToUpdate]=handleSharedLocalDSMs(obj,currentBotDSMInfo,inlinedSSPath,refMdlName,topMdlWs,refMdlWs,sharedLocalDSMToNewNameMap,dsmNamesToUpdate,mdlRefItem,replacementModelName);



            skipLiftSignal=true;
        end

        topSameNameIdx=findSameNameIdx(topDSMInfo,currentBotDSMInfo);

        if skipLiftSignal


        elseif~isempty(topSameNameIdx)
            topSameNameLocalIdx=findSameNameLocalIdx(topDSMInfo,topSameNameIdx);
            if strcmp(currentBotDSMInfo.Type,'globalsignalbws')||~isempty(topSameNameLocalIdx)
                for jdx=1:length(topSameNameLocalIdx)
                    topLocal=fixTopLocalDSM(topDSMInfo(topSameNameLocalIdx(jdx)),obj.incAndGetDSMId,topMdlWs,mdlRefItem,dsmNamesToUpdate,inlinedSSPath,replacementModelName,refMdlWs);
                    topDSMInfo(topSameNameLocalIdx(jdx))=topLocal;
                end
                if~isempty(topSameNameLocalIdx)&&...
                    any(strcmp(currentBotDSMInfo.Type,{'localdsmmws','localsignalmws'}))
                    moveSignalObjToTop(topMdlWs,refMdlWs,currentBotDSMInfo.DSMName);
                end
            else
                currentBotDSMInfo=fixBotLocalDSM(currentBotDSMInfo,obj.incAndGetDSMId,topMdlWs,...
                refMdlWs,mdlRefItem,dsmNamesToUpdate,inlinedSSPath,replacementModelName);
            end
        elseif any(strcmp(currentBotDSMInfo.Type,{'localdsmmws','localsignalmws'}))
            moveSignalObjToTop(topMdlWs,refMdlWs,currentBotDSMInfo.DSMName);
        end
        topDSMInfo=integrateToTopDSMInfo(topDSMInfo,currentBotDSMInfo,sharedLocalDSMToNewNameMap);
    end

    modelRefBlkTree.DSMRWInformation=topDSMInfo;
end

function moveSignalObjToTop(topMdlWs,refMdlWs,dsmName)
    signalObject=refMdlWs.getVariable(dsmName);
    topMdlWs.assignin(dsmName,signalObject);
end

function topDSMInfo=integrateToTopDSMInfo(topDSMInfo,currentBotDSMInfo,sharedLocalDSMToNewNameMap)
    idxList1=findSameNameIdx(topDSMInfo,currentBotDSMInfo);
    if isempty(idxList1)
        topDSMInfo(end+1)=currentBotDSMInfo;
    else
        sameNametopDSMInfo=topDSMInfo(idxList1);
        idxList2=strmatch(currentBotDSMInfo.Type,{sameNametopDSMInfo.Type},'exact');
        if isempty(idxList2)
            topDSMInfo(end+1)=currentBotDSMInfo;
        else



            assert(length(idxList2)==1);
            idxTop=idxList1(idxList2);




            topDSMInfo(idxTop).DSRWBlks=cat(1,topDSMInfo(idxTop).DSRWBlks,currentBotDSMInfo.DSRWBlks);
        end
    end
end

function dsmInfo=fixBlockPath(info,inlinedSSPath,refMdlName)
    dsmInfo=info;

    fullPaths=dsmInfo.FullPath;
    for idx=1:length(fullPaths)
        fullPaths{idx}=regexprep(fullPaths{idx},[refMdlName,'/'],[inlinedSSPath,'/'],1);
    end
    dsmInfo.FullPath=fullPaths;

    dsrwBlocks=dsmInfo.DSRWBlks;
    for idx=1:length(dsrwBlocks)
        dsrwBlocks{idx}=...
        regexprep(dsrwBlocks{idx},[refMdlName,'/'],[inlinedSSPath,'/'],1);
    end
    dsmInfo.DSRWBlks=dsrwBlocks;
end

function idxList=findSameNameIdx(topDSMInfo,currentBotDSMInfo)
    idxList=strmatch(currentBotDSMInfo.DSMName,{topDSMInfo.DSMName},'exact');
end

function idxList=findSameNameLocalIdx(topDSMInfo,topSameNameIdx)
    localdsmIDx=strmatch('localdsm',{topDSMInfo.Type},'exact');
    idxList=localdsmIDx;
    localdsmmwsIDx=strmatch('localdsmmws',{topDSMInfo.Type},'exact');
    idxList=union(localdsmmwsIDx,idxList);
    localdsmbwsIDx=strmatch('localdsmbws',{topDSMInfo.Type},'exact');
    idxList=union(localdsmbwsIDx,idxList);
    localsignalmwsIDx=strmatch('localsignalmws',{topDSMInfo.Type},'exact');
    idxList=union(localsignalmwsIDx,idxList);
    idxList=intersect(topSameNameIdx,idxList);
end

function local=fixTopLocalDSM(local,dsmId,topMdlWs,mdlRefItem,dsmNamesToUpdate,inlinedSSPath,replacementModelName,refMdlWs)
    old_name=local.DSMName;
    if strcmp(local.Type,'localdsm')
        local.DSMName=sprintf('localDVDSM%d',dsmId);
    else
        if any(strmatch(local.Type,{'localdsmmws','localsignalmws'},'exact'))
            signalObject=topMdlWs.getVariable(local.DSMName);
            topMdlWs.clear(local.DSMName);
        else
            assert(strcmp(local.Type,'localdsmbws'));
            signalObject=evalin('base',local.DSMName);
        end

        combinedWSVars=getCombinedWorkspaceVariableList(topMdlWs,refMdlWs,replacementModelName,dsmNamesToUpdate);



        local.DSMName=genuniquemwsvar(combinedWSVars,local.DSMName);
        assert(~signalObject.CoderInfo.HasContext,'Expected signal objects without context');
        topMdlWs.assignin(local.DSMName,signalObject.copy);
    end

    local=fixFullPaths(local,mdlRefItem,inlinedSSPath,old_name);
end

function local=fixBotLocalDSM(local,dsmId,topMdlWs,refMdlWs,mdlRefItem,dsmNamesToUpdate,inlinedSSPath,replacementModelName)
    old_name=local.DSMName;

    if strcmp(local.Type,'localdsm')
        local.DSMName=sprintf('localDVDSM%d',dsmId);
    else
        if any(strmatch(local.Type,{'localdsmmws','localsignalmws'},'exact'))
            signalObject=refMdlWs.getVariable(local.DSMName);
        else
            assert(strcmp(local.Type,'localdsmbws'));
            signalObject=evalin('base',local.DSMName);
        end








        combinedWSVars=getCombinedWorkspaceVariableList(topMdlWs,refMdlWs,replacementModelName,dsmNamesToUpdate);



        local.DSMName=genuniquemwsvar(combinedWSVars,local.DSMName);
        assert(~signalObject.CoderInfo.HasContext,'Expected signal objects without context');
        topMdlWs.assignin(local.DSMName,signalObject.copy);
    end
    local=fixFullPaths(local,mdlRefItem,inlinedSSPath,old_name);
end

function local=fixFullPaths(local,mdlRefItem,inlinedSSPath,old_name)
    fullPaths=local.FullPath;
    for idx=1:length(fullPaths)
        if~isempty(fullPaths{idx})
            Sldv.xform.BlkReplacer.breakLibraryLinks(fullPaths{idx},mdlRefItem);
            set_param(fullPaths{idx},'DataStoreName',local.DSMName);
        end
    end
    dsrwBlocks=local.DSRWBlks;
    for idx=1:length(dsrwBlocks)
        currBlock=dsrwBlocks{idx};
        Sldv.xform.BlkReplacer.breakLibraryLinks(currBlock,mdlRefItem);
        if Stateflow.SLUtils.isStateflowBlock(currBlock)
            Stateflow.Refactor.renameDataAndRefactorUsagesForBlock(...
            currBlock,old_name,local.DSMName);
        else
            set_param(currBlock,'DataStoreName',local.DSMName);

            dsElements=get_param(currBlock,'DataStoreElements');


            dsElementsSplit=split(dsElements,'#');
            for i=1:size(dsElementsSplit)
                if(strfind(dsElementsSplit{i},old_name)==1)

                    dsElementsSplit{i}=[local.DSMName,dsElementsSplit{i}(length(old_name)+1:end)];
                end
            end
            dsElementsJoin=join(dsElementsSplit,'#');
            set_param(currBlock,'DataStoreElements',dsElementsJoin{1});
        end
    end
end

function newmwsvar=genuniquemwsvar(modelwsvars,dsrwname)
    newmwsvar=sprintf('%sdv',dsrwname);
    count=1;
    while any(strcmp(newmwsvar,modelwsvars))
        newmwsvar=sprintf('%s%d',newmwsvar,count);
        count=count+1;
    end
end

function[currentBotDSMInfo,sharedLocalDSMToNewNameMap,dsmNamesToUpdate]=handleSharedLocalDSMs(blkReplacer,currentBotDSMInfo,inlinedSSPath,refMdlName,topMdlWs,refMdlWs,sharedLocalDSMToNewNameMap,dsmNamesToUpdate,mdlRefItem,replacementModelName)


    new_dsm_name='';
    fullPathReplacement=currentBotDSMInfo.FullPath{1};
    numCharsToSkip=numel(inlinedSSPath)+1;
    fullPathToDSM=[refMdlName,fullPathReplacement(numCharsToSkip:end)];

    skipLiftSignalAndSkipAddBlock=false;

    if~isKey(sharedLocalDSMToNewNameMap,fullPathToDSM)



        combinedWSVars=getCombinedWorkspaceVariableList(topMdlWs,refMdlWs,replacementModelName,dsmNamesToUpdate);

        new_dsm_name=genuniquemwsvar(combinedWSVars,currentBotDSMInfo.DSMName);
        sharedLocalDSMToNewNameMap(fullPathToDSM)=new_dsm_name;
    else
        new_dsm_name=sharedLocalDSMToNewNameMap(fullPathToDSM);
        skipLiftSignalAndSkipAddBlock=true;
    end



    old_name=currentBotDSMInfo.DSMName;
    if~skipLiftSignalAndSkipAddBlock&&~any(strcmp(currentBotDSMInfo.Type,{'localdsmmws','localsignalmws'}))
    elseif~skipLiftSignalAndSkipAddBlock

        topMdlWs.assignin(new_dsm_name,refMdlWs.getVariable(old_name));
    end



    assert(numel(currentBotDSMInfo.FullPath)==1);

    currPath=currentBotDSMInfo.FullPath{1};
    if~isempty(currPath)
        Sldv.xform.BlkReplacer.breakLibraryLinks(currPath,mdlRefItem);
        set_param(currPath,'DataStoreName',new_dsm_name);
    end

    dsrwBlocks=currentBotDSMInfo.DSRWBlks;
    for idx=1:length(dsrwBlocks)
        currBlock=dsrwBlocks{idx};
        Sldv.xform.BlkReplacer.breakLibraryLinks(currBlock,mdlRefItem);
        if Stateflow.SLUtils.isStateflowBlock(currBlock)
            Stateflow.Refactor.renameDataAndRefactorUsagesForBlock(...
            currBlock,old_name,new_dsm_name);
        else
            set_param(currBlock,'DataStoreName',new_dsm_name);
        end
    end






    if~skipLiftSignalAndSkipAddBlock
        h=blkReplacer.addBlock(fullPathReplacement,[bdroot(fullPathReplacement),'/Data Store Memory'],'MakeNameUnique','on');
        set_param(h,'DataStoreName',new_dsm_name);
        dsmNamesToUpdate(h)=new_dsm_name;
        blkReplacer.deleteBlock(currentBotDSMInfo.FullPath{1});
        currentBotDSMInfo.FullPath={getfullname(h)};
    else
        blkReplacer.deleteBlock(currentBotDSMInfo.FullPath{1});
        updated=false;
        keyList=keys(dsmNamesToUpdate);
        for keyId=1:length(keyList)
            if strcmp(dsmNamesToUpdate(keyList{keyId}),new_dsm_name)
                currentBotDSMInfo.FullPath={getfullname(keyList{keyId})};
                updated=true;
                break;
            end
        end

        assert(updated);
    end

    currentBotDSMInfo.DSMName=new_dsm_name;
end

function combinedWSVars=getCombinedWorkspaceVariableList(topMdlWs,refMdlWs,pathToSystem,dsmNamesToUpdate)
    combinedWSVars={};
    if~isempty(topMdlWs)&&~isempty(topMdlWs.data)
        combinedWSVars={topMdlWs.data.Name};
    end
    if~isempty(refMdlWs)&&~isempty(refMdlWs.data)
        combinedWSVars=[combinedWSVars,{refMdlWs.data.Name}];%#ok<AGROW>
    end



    dsmBlockList=find_system(pathToSystem,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks','on','LookUnderMasks','all','BlockType','DataStoreMemory');
    dsmNameList={};
    for idx=1:length(dsmBlockList)
        dsmNameList{idx}=get_param(dsmBlockList{idx},'DataStoreName');
    end

    topWs={evalin('base','who')};
    topWs=(topWs{1})';

    dataDictionary={};
    dd=get_param(pathToSystem,'DataDictionary');
    if~isempty(dd)
        myDictionaryObj=Simulink.data.dictionary.open(dd);
        dDataSectObj=getSection(myDictionaryObj,'Design Data');
        dataDictionary=evalin(dDataSectObj,'who')';
    end






    combinedWSVars=[combinedWSVars,topWs,dataDictionary,dsmNameList,values(dsmNamesToUpdate)];
end

function safe=allDSMsResolveToSameBlock(currBotDSMInfo,sharedLocalDSMBlock)
    if isempty(currBotDSMInfo.FullPath)

        assert(false)
    end

    currHandleStruct=get_param(sharedLocalDSMBlock,'DSReadWriteBlocks');
    currHandleStruct={currHandleStruct.handle};
    safe=isEmptyAfteRemovingCommonPaths(currBotDSMInfo.DSRWBlks,currHandleStruct);
end

function isSafe=isEmptyAfteRemovingCommonPaths(allDSRWBlks,currHandleStruct)
    allDSRWHandles=[];
    for idx=1:length(allDSRWBlks)
        allDSRWHandles(idx)=getSimulinkBlockHandle(allDSRWBlks{idx});
    end

    currHandleArray=[];
    for idx=1:length(currHandleStruct)
        currHandleArray(idx)=currHandleStruct{idx};
    end

    remainingBlockHandles=setdiff(allDSRWHandles,currHandleArray);
    isSafe=isempty(remainingBlockHandles);
end




