function updateSurrogateModule(syncObj,moduleInfo)











    rmiut.progressBarFcn('set',0.05,getString(message('Slvnv:rmiut:progressBar:SyncPleaseWait')));



    [allObjH,allObjPidx,allIsSf,isAnnotation]=rmisl.getObjectHierarchy(syncObj.modelH);
    hasSf=any(allIsSf);
    allObjCnt=length(allObjH);


    allIsSigB=false(allObjCnt,1);
    allIsSigB(~allIsSf)=rmisl.is_signal_builder_block(allObjH(~allIsSf));
    sigbCnt=sum(allIsSigB);

    if sigbCnt>0

        removeIdx=rmisl.getChildIndices(allObjPidx,allIsSigB);
        allObjH(removeIdx)=[];
        allObjPidx(removeIdx)=[];
        allIsSf(removeIdx)=[];
        isAnnotation(removeIdx)=[];
        allIsSigB(removeIdx)=[];
        oldCnt=allObjCnt;
        allObjCnt=length(allObjH);


        oldIdx=1:oldCnt;
        oldIdx(removeIdx)=[];
        newIdxVals=zeros(oldCnt,1);
        newIdxVals(oldIdx)=1:allObjCnt;
        allObjPidx(2:end)=newIdxVals(allObjPidx(2:end));
    end

    allIsMasked=rmisync.dfs_inside_mask(allObjH,allObjPidx,allIsSf,isAnnotation);
    allHasChildren=false(allObjCnt,1);
    allHasChildren(allObjPidx(2:end))=true;


    [filtAll,filtNone,filtMask,filtSf,filtSl,filtLeav]=rmisync.interpretDetailLevel(syncObj.detailLevel);



    allReqInfo(~allIsSf)=rmisl.getReqInfoForObjects(allObjH(~allIsSf),syncObj.modelH,false);
    allObjIsa=-1*ones(allObjCnt,1);


    if hasSf
        [sfObjIsa,sfReqInfo]=rmisf.getReqInfoForObjects(syncObj.modelH,allObjH(allIsSf));

        allObjIsa(allIsSf)=sfObjIsa;
        allReqInfo(allIsSf)=sfReqInfo;
    end
    allReqInfo=allReqInfo(:);

    allIsEmptyReqInfo=strcmp(allReqInfo,'{}')|strcmp(allReqInfo,'');

    if sigbCnt>0
        rmiut.progressBarFcn('set',0.25,getString(message('Slvnv:rmiut:progressBar:SyncAnalyzingSigbuilders')));

        sigbGroupNames=cell(1,sigbCnt);
        sigbGroupSrgIds=cell(1,sigbCnt);
        sigbGroupReqs=cell(1,sigbCnt);
        sigbGroupHasSrgReqs=cell(1,sigbCnt);
        sigbH=allObjH(allIsSigB)';
        sigAllIdx=find(allIsSigB');
        sigbReqInfo=allReqInfo(allIsSigB);
        sigbGroupCnt=zeros(1,sigbCnt);
        sigbHasNew=false(1,sigbCnt);

        allIdx2SbIdx=-1*ones(allObjCnt,1);
        allIdx2SbIdx(allIsSigB)=(1:sigbCnt)';



        sigbGrpModSrgId=cell(1,sigbCnt);
        sigbGrpInUpdate=cell(1,sigbCnt);

        for idx=1:sigbCnt
            [jnkT,jnkD,jnkSigLab,actGroupNames]=signalbuilder(sigbH(idx));%#ok

            groupCnt=length(actGroupNames);
            groupReqs=cell(groupCnt,1);
            groupSrgIds=-1*ones(1,groupCnt);
            groupHasTypeReqs=false(1,groupCnt);

            if~isempty(sigbReqInfo{idx})
                slReqs=rmi.parsereqs(sigbReqInfo{idx});

                if~isempty(slReqs)
                    reqCnt=length(slReqs);
                    reqSys={slReqs.reqsys};
                    isSurrRq=strcmp(reqSys,syncObj.srgSys);
                    isTypeRq=strcmp(reqSys,syncObj.reqSys);
                    reqIds=zeros(1,reqCnt);
                    reqIds(isSurrRq)=str2double({slReqs(isSurrRq).id});





                    if rmidata.isExternal(syncObj.modelH)
                        [~,allGrpRqIdx]=slreq.getSigbGrpData(sigbH(idx));
                    else
                        blkInfo=rmisl.sigb_get_info(sigbH(idx));
                        allGrpRqIdx=rmidata.convertSigbGrpInfo(blkInfo,reqCnt);
                    end

                    for grpIdx=1:groupCnt
                        grpRqIdx=find(allGrpRqIdx==grpIdx);
                        if~isempty(grpRqIdx)
                            groupReqs{grpIdx}=slReqs(grpRqIdx);
                            if any(isSurrRq(grpRqIdx))
                                grpIds=reqIds(grpRqIdx);
                                grpIds(grpIds==0)=[];
                                groupSrgIds(grpIdx)=grpIds(1);
                            end
                            groupHasTypeReqs(grpIdx)=any(isTypeRq(grpRqIdx));
                        end
                    end
                end
            end

            sigbGroupNames{idx}=actGroupNames;
            sigbGroupReqs{idx}=groupReqs;
            sigbGroupSrgIds{idx}=groupSrgIds;
            sigbGroupCnt(idx)=groupCnt;
            sigbGroupHasSrgReqs{idx}=groupHasTypeReqs;
        end
        sigbNewReqs=sigbGroupReqs;
    end










    if~isempty(moduleInfo)

        rmiut.progressBarFcn('set',0.30,getString(message('Slvnv:rmiut:progressBar:SyncAnalyzingSurrogate')));


        dmIdStrs=moduleInfo(:,1);
        dmDepthStrs=moduleInfo(:,2);
        dmPaths=moduleInfo(:,3);
        dmTypes=moduleInfo(:,4);





        linkInfo=moduleInfo(:,5);


        dmIsSigBuilder=strcmp(dmTypes,'Signal Group');

        dmIsState=strcmp(dmTypes,'Stateflow State');
        dmIsTrans=strcmp(dmTypes,'Stateflow Transition');
        dmIsBlock=~(dmIsSigBuilder|dmIsState|dmIsTrans);


        dmSrgIds=syncObj.idStrToNum(dmIdStrs(:));
        dmDepths=str2double(dmDepthStrs(:));
        dmItemCnt=length(dmSrgIds);


        dmSigbGroupNames={};
        dmSigbSrgIds={};
        dmSigbGroupCnt=[];
        dmSigbSurrIdx={};
        dmSigbObjH=[];



        dmObjH=[];


        parentIdx=[];
        parentPaths={};
        parentH=[];
        prevIdx=[];

        idx=1;
        while idx<=dmItemCnt
            objDepth=dmDepths(idx);
            objIsGood=true;


            if idx==1
                objH=syncObj.modelH;
            else
                if dmIsSigBuilder(idx)
                    groupCnt=cache_surrogate_signal_builder_info(idx);


                    idx=idx+groupCnt-1;

                elseif dmIsBlock(idx)
                    try
                        if~isempty(dmPaths{idx})
                            objH=get_param(dmPaths{idx},'Handle');
                        else
                            objH=-1;
                        end
                    catch ME %#ok<NASGU>
                        objH=-1;
                    end

                elseif dmIsState(idx)

                    statePath=dmPaths{idx};
                    bwdName=strtok(fliplr(statePath),' ,/\.');
                    stateName=fliplr(bwdName);


                    if(dmIsBlock(parentIdx(1)))
                        parentId=sf('Private','block2chart',parentH(1));
                    else
                        parentId=parentH(1);
                    end


                    subStates=sf('AllSubstatesOf',parentId);
                    objH=sf('find',subStates,'.name',stateName);
                    if isempty(objH)
                        objH=-1;
                    end

                elseif dmIsTrans(idx)


                    remainIsTrans=dmIsTrans((idx+1):end);
                    remainIsSameDepth=(dmDepths((idx+1):end)==dmDepths(idx));
                    nextNonTrans=find(~(remainIsTrans&remainIsSameDepth));
                    if isempty(nextNonTrans)
                        transCnt=length(remainIsTrans)+1;
                    else
                        transCnt=nextNonTrans(1);
                    end
                    transIdx=idx+(1:transCnt)-1;


                    if(dmIsBlock(parentIdx(1)))
                        parentId=sf('Private','block2chart',parentH(1));
                    else
                        parentId=parentH(1);
                    end

                    objH=rmisync.resolveTransitions(transIdx,dmPaths,parentPaths,parentId);


                    idx=idx+transCnt-1;
                end

                if isempty(objH)||objH(1)==-1
                    objIsGood=false;
                end

            end


            dmObjH=[dmObjH;objH(:)];%#ok<*AGROW>


            if objIsGood

                nextIdx=idx+1;
            else


                nextIdx=next_non_descendent(idx,dmDepths);
                skipCnt=nextIdx-idx-1;
                if skipCnt>0
                    dmObjH=[dmObjH;-1*ones(skipCnt,1)];
                    cache_skipped_range_signal_builder_info(idx+1,nextIdx-1);
                end
            end


            prevIdx(1)=idx;


            if(nextIdx<=dmItemCnt)
                if(dmDepths(nextIdx)>objDepth)

                    parentIdx=[idx,parentIdx];
                    parentPaths=[dmPaths(idx),parentPaths];
                    prevIdx=[-1,prevIdx];
                    parentH=[objH,parentH];

                elseif(dmDepths(nextIdx)<objDepth)

                    popCount=objDepth-dmDepths(nextIdx);
                    parentIdx(1:popCount)=[];
                    parentPaths(1:popCount)=[];
                    prevIdx(1:popCount)=[];
                    parentH(1:popCount)=[];

                end
            end
            idx=nextIdx;
        end




        dmIsValid=(dmObjH>0);
        allSrgIds=zeros(allObjCnt,1);
        validObjs=dmObjH(dmIsValid);
        validIds=dmSrgIds(dmIsValid);
        [allIsSurrNoChange,validSurrogateIdx,fmatch]=rmiut.setmap(validObjs,allObjH);
        allSrgIds(validSurrogateIdx)=validIds(fmatch);
    else
        dmSrgIds=[];
        dmDeletedIds=[];
        dmIsValid=[];
        allSrgIds=zeros(allObjCnt,1);
        allIsSurrNoChange=false(allObjCnt,1);
    end


    dmIsRemap=false(length(dmIsValid),1);
    allIsSurrChange=false(allObjCnt,1);
    surrogateLinkUpdates={};



    if sigbCnt>0

        if isempty(dmSrgIds)
            dmSigbCnt=0;
        else
            dmSigbCnt=length(dmSigbObjH);
        end
        sigbDmMatch=-1*ones(sigbCnt,1);

        if(dmSigbCnt>0)
            dmSigbValid=(dmSigbObjH>0);

            sigbInSurr=[];
            if any(dmSigbValid)

                [sigbInSurr,validDmSigbIdx]=rmiut.findidx(dmSigbObjH(dmSigbValid),sigbH);

                v=(1:dmSigbCnt)';
                sigbDmMatch(validDmSigbIdx)=v(dmSigbValid);



                for mdlIdx=1:sigbCnt
                    dmSigbIdx=sigbDmMatch(mdlIdx);
                    if dmSigbIdx>0
                        map_signal_builder_groups(dmSigbIdx,mdlIdx,true);
                    end
                end
            end

            dmSigbRemap=false(dmSigbCnt,1);

            if any(~dmSigbValid)


                mdlSBGrpSrgIds=[sigbGroupSrgIds{:}];
                mdlSBGrpBlkIdx=rmisync.sigbGrpCntsToIdx(sigbGroupCnt);
                if~isempty(sigbInSurr)
                    mdlRemove=sigbInSurr(mdlSBGrpBlkIdx);
                    mdlSBGrpSrgIds(mdlRemove)=[];
                    mdlSBGrpBlkIdx(mdlRemove)=[];
                end

                dmSBGrpreqIds=cat(1,dmSigbSrgIds{:});
                dmSBGrpBlkIdx=rmisync.sigbGrpCntsToIdx(dmSigbGroupCnt);
                dmRemove=dmSigbValid(dmSBGrpBlkIdx);
                dmSBGrpreqIds(dmRemove)=[];
                dmSBGrpBlkIdx(dmRemove)=[];

                [inMdl,dmGrpIdx,isMdlGrpRemap]=rmiut.setmap(mdlSBGrpSrgIds,dmSBGrpreqIds);%#ok

                sigbMap2dmIdx=zeros(sigbCnt,1);
                sigbMap2dmIdx(mdlSBGrpBlkIdx(isMdlGrpRemap))=dmSBGrpBlkIdx(dmGrpIdx);

                for mdlIdx=1:sigbCnt
                    dmSigbIdx=sigbMap2dmIdx(mdlIdx);
                    if dmSigbIdx>0
                        map_signal_builder_groups(dmSigbIdx,mdlIdx,false);
                        dmSigbRemap(dmSigbIdx)=true;
                        sigbDmMatch(mdlIdx)=dmSigbIdx;
                    end
                end
            end




        end


        sigbNewBlk=(sigbDmMatch<1);
        newBlkInd=find(sigbNewBlk);


        if~isempty(newBlkInd)
            for blkIdx=newBlkInd(:)'
                allGrpsInSurr=filtNone||~(filtAll||(filtMask&&allIsMasked(sigAllIdx(blkIdx))));
                grpCnt=sigbGroupCnt(blkIdx);
                if(allGrpsInSurr)
                    sigbGrpModSrgId{blkIdx}=-1*ones(grpCnt,1);
                    sigbGrpInUpdate{blkIdx}=true(grpCnt,1);
                else
                    hasSysReqs=sigbGroupHasSrgReqs{blkIdx};
                    slGrpModSrgId=zeros(grpCnt,1);
                    slGrpInUpdate=false(grpCnt,1);
                    slGrpModSrgId(hasSysReqs)=-1;
                    slGrpInUpdate(hasSysReqs)=true;
                    sigbGrpModSrgId{blkIdx}=slGrpModSrgId;
                    sigbGrpInUpdate{blkIdx}=slGrpInUpdate;
                end
                sigbHasNew(blkIdx)=allGrpsInSurr||any(hasSysReqs);
            end
        end
    end










    rmiut.progressBarFcn('set',0.3,getString(message('Slvnv:rmiut:progressBar:SyncMappingObjects')));

    allIsUnmappedSl=(~allIsSurrNoChange&~allIsSf&~allIsSigB);
    allIsUnmappedSf=(~allIsSurrNoChange&allIsSf);

    if any(allIsUnmappedSl)
        sl_srgId=syncObj.srgIds(allReqInfo(allIsUnmappedSl));
        slHasRemap=true;
    else
        slHasRemap=false;
    end

    if hasSf&&any(allIsUnmappedSf)
        sf_reqId=syncObj.srgIds(allReqInfo(allIsUnmappedSf));
    end

    allIsSlSurrChange=false(allObjCnt,1);
    allIsSfSurrChange=false(allObjCnt,1);

    if isempty(dmIsValid)
        unmappedSrgIds=[];
    else
        unmappedSrgIds=dmSrgIds(~dmIsValid);
    end

    if~isempty(unmappedSrgIds)
        if slHasRemap
            [maps2sl,unmapSlIdx,isSlremap]=rmiut.setmap(sl_srgId,unmappedSrgIds);%#ok
            allIsSlSurrChange(allIsUnmappedSl)=isSlremap;
            allSrgIds(allIsSlSurrChange)=unmappedSrgIds(unmapSlIdx);
        end

        if hasSf&&any(allIsUnmappedSf)
            [maps2sf,unmapSfIdx,isSfremap]=rmiut.setmap(sf_reqId,unmappedSrgIds);%#ok
            allIsSfSurrChange(allIsUnmappedSf)=isSfremap;
            allIsSurrChange=(allIsSlSurrChange|allIsSfSurrChange);
            allSrgIds(allIsSfSurrChange)=unmappedSrgIds(unmapSfIdx);
        else
            allIsSurrChange(~allIsSigB)=allIsSlSurrChange(~allIsSigB);
        end

    end

    if~isempty(unmappedSrgIds)
        srgInvalidIdx=find(~dmIsValid);
        if slHasRemap
            remap2slIdx=srgInvalidIdx(unmapSlIdx);
        end

        if hasSf&&any(allIsUnmappedSf)
            remap2sfIdx=srgInvalidIdx(unmapSfIdx);
            if slHasRemap
                dmIsRemap([remap2slIdx;remap2sfIdx])=true;
            else
                dmIsRemap(remap2sfIdx)=true;
            end
        elseif slHasRemap
            dmIsRemap(remap2slIdx)=true;
        end
    end




    allMergeIdx=find(allIsSurrNoChange&~allIsSigB);
    if~isempty(allMergeIdx)
        [jnk,dmChangedIdx,dmJnkIdx]=rmiut.setmap(allSrgIds(allIsSurrNoChange&~allIsSigB),dmSrgIds);%#ok
        myTotal=length(allMergeIdx);
        for my_i=1:myTotal
            mdlIdx=allMergeIdx(my_i);
            dmIdx=dmChangedIdx(my_i);
            newLinkStr=rmisync.setMergedReqs(allObjH(mdlIdx),allReqInfo{mdlIdx},syncObj,...
            allSrgIds(mdlIdx),linkInfo{dmIdx});
            if~isempty(newLinkStr)
                surrogateLinkUpdates=[surrogateLinkUpdates;{allSrgIds(mdlIdx),newLinkStr}];
            end
            if mod(my_i,100)==0
                if rmiut.progressBarFcn('isCanceled')
                    break;
                else
                    rmiut.progressBarFcn('set',0.3+my_i/myTotal/2,getString(message('Slvnv:rmiut:progressBar:SyncMappingObjects')));
                end
            end
        end
    end

    allMergeIdx=find(allIsSurrChange&~allIsSigB);
    if~isempty(allMergeIdx)
        [jnk,dmChangedIdx,dmJnkIdx]=rmiut.setmap(allSrgIds(allIsSurrChange&~allIsSigB),dmSrgIds);%#ok
        myTotal=length(allMergeIdx);
        for my_i=1:myTotal
            mdlIdx=allMergeIdx(my_i);
            dmIdx=dmChangedIdx(my_i);
            newLinkStr=rmisync.setMergedReqs(allObjH(mdlIdx),allReqInfo{mdlIdx},syncObj,...
            allSrgIds(mdlIdx),linkInfo{dmIdx});
            if~isempty(newLinkStr)
                surrogateLinkUpdates=[surrogateLinkUpdates;{allSrgIds(mdlIdx),newLinkStr}];
            end
            if mod(my_i,100)==0
                if rmiut.progressBarFcn('isCanceled')
                    break;
                else
                    rmiut.progressBarFcn('set',0.3+my_i/myTotal/2,getString(message('Slvnv:rmiut:progressBar:SyncMappingObjects')));
                end
            end
        end
    end











    rmiut.progressBarFcn('set',0.4,getString(message('Slvnv:rmiut:progressBar:SyncMappingNew')));

    allIsUnrslvReq=(allSrgIds==0&~allIsEmptyReqInfo);
    allIsUnresolvedThisSysReq=false(allObjCnt,1);
    allIsUnresolvedThisSysReq(allIsUnrslvReq)=syncObj.hasSysReq(allReqInfo(allIsUnrslvReq));


    if(filtAll)
        allIsNew=allIsUnresolvedThisSysReq;
    elseif filtNone
        allIsNew=(allIsUnresolvedThisSysReq|allSrgIds==0);
    else
        if(~isempty(filtSf)||~isempty(filtSl))
            allIsTrivial=rmisync.matchObjTypes(allObjH,...
            allIsSf,...
            filtSl,...
            filtSf,isAnnotation);
        else
            allIsTrivial=false(allObjCnt,1);
        end

        if filtMask
            if filtLeav
                allIsNew=(allIsUnresolvedThisSysReq|(allSrgIds==0&allHasChildren&(~allIsTrivial)&(~allIsMasked)));
            else
                allIsNew=(allIsUnresolvedThisSysReq|(allSrgIds==0&(~allIsTrivial)&(~allIsMasked)));
            end
        else
            if filtLeav
                allIsNew=(allIsUnresolvedThisSysReq|(allSrgIds==0&allHasChildren&(~allIsTrivial)));
            else
                allIsNew=(allIsUnresolvedThisSysReq|(allSrgIds==0&(~allIsTrivial)));
            end
        end
    end


    if allSrgIds(1)==0
        allIsNew(1)=true;
    end

    if sigbCnt>0
        allIsNew(allIsSigB)=sigbHasNew;
    end
    allSrgIds(allIsNew)=-1;



    allSrgIds=rmisync.dfs_identify_objects(allObjH,allObjPidx,allSrgIds);
    allIsNew=(allSrgIds==-1);


    lastIds=zeros(sigbCnt,1);
    if(sigbCnt>0&&any(allIsNew&allIsSigB))
        sbAllIdx=find(allIsNew&allIsSigB);
        sigbNewCnt=length(sbAllIdx);
        nextNewId=-1;

        for elmIdx=1:sigbNewCnt
            assign_blk_sigb_range_unique_ids(sbAllIdx,elmIdx);
        end
    else
        sbAllIdx=[];
        if(sigbCnt>0)
            for i=1:sigbCnt
                nonZeroIds=sigbGrpModSrgId{i}(sigbGrpModSrgId{i}~=0);
                if isempty(nonZeroIds)

                    lastIds(i)=0;
                else

                    lastIds(i)=nonZeroIds(end);
                end
            end
        end

        newCnt=sum(allIsNew);
        allSrgIds(allIsNew)=-(1:newCnt)';
    end





    rmiut.progressBarFcn('set',0.45,getString(message('Slvnv:rmiut:progressBar:SyncUpdatingLinks')));



    if~isempty(dmSrgIds)
        dmDeletedIds=dmSrgIds(~dmIsValid&~dmIsRemap);
    end











    allIsInUpdate=(allIsNew|allIsSurrChange);


    allLastSrgIds=allSrgIds;
    if sigbCnt>0
        allLastSrgIds(allIsSigB)=lastIds;
        allIsInUpdate(allIsSigB)=false;

        sigbAllGrpInUpdate=cat(1,sigbGrpInUpdate{:});
        sigbUpdateCnt=sum(sigbAllGrpInUpdate);

        if(sigbUpdateCnt>0)
            allInsPts=cumsum(allIsInUpdate)+1;
            sigbInsPts=[];
            sigbInsCts=[];

            for blkIdx=1:sigbCnt
                grpUpCnt=sum(sigbGrpInUpdate{blkIdx});
                sigbInsPts(end+1)=allInsPts(sigAllIdx(blkIdx));
                sigbInsCts(end+1)=grpUpCnt;
            end
        end
    else
        sigbUpdateCnt=0;
    end

    updatesCnt=sum(allIsInUpdate);

    if updatesCnt+sigbUpdateCnt>0
        allDepths=rmisl.getDepths(allObjPidx);
        allSrgOlderBro=rmisync.dfs_older_bro(allObjH,allObjPidx,allLastSrgIds);
    end


    if(sigbUpdateCnt>0)
        sigbMods=cell(sigbUpdateCnt,7);
        grpStartIdx=1;

        for blkIdx=1:sigbCnt
            allIdx=sigAllIdx(blkIdx);
            grpUpCnt=sum(sigbGrpInUpdate{blkIdx});
            grpNames=sigbGroupNames{blkIdx};

            if(grpUpCnt>0)
                modsIdx=grpStartIdx+(1:grpUpCnt)-1;
                blkGrpIdx=sigbGrpInUpdate{blkIdx};
                grpInSurr=(sigbGrpModSrgId{blkIdx}~=0);

                blkFullPath={getfullname(allObjH(allIdx))};
                blkName={get_param(allObjH(allIdx),'Name')};
                blkParentId={allSrgIds(allObjPidx(allIdx))};
                blkDepth={allDepths(allIdx)};


                firstOlderBro=allSrgOlderBro(allIdx);
                olderBroIds=zeros(1,length(sigbGrpInUpdate{blkIdx}));
                validOlderIds=[firstOlderBro;sigbGrpModSrgId{blkIdx}(grpInSurr)];
                validOlderIds(end)=[];
                olderBroIds(grpInSurr)=validOlderIds;

                sigbMods(modsIdx,1)=num2cell(sigbGrpModSrgId{blkIdx}(blkGrpIdx));
                sigbMods(modsIdx,2)=blkParentId;
                sigbMods(modsIdx,3)=num2cell(olderBroIds(blkGrpIdx));
                sigbMods(modsIdx,4)=strcat(blkFullPath,'/',grpNames(blkGrpIdx));
                sigbMods(modsIdx,5)=strcat(blkName,':',grpNames(blkGrpIdx));
                sigbMods(modsIdx,6)={'Signal Group'};
                sigbMods(modsIdx,7)=blkDepth;

                grpStartIdx=grpStartIdx+grpUpCnt;
            end
        end


        [nonSBUpdateIdx,SBUpdateIdx]=rmiut.listInsertIdxVect(sigbInsPts,sigbInsCts,updatesCnt);
    end

    rmiut.progressBarFcn('set',0.5,getString(message('Slvnv:rmiut:progressBar:SyncUpdatingLinks')));


    if updatesCnt+sigbUpdateCnt>0
        if updatesCnt>0
            updates=cell(updatesCnt,7);

            updates(:,1)=num2cell(allSrgIds(allIsInUpdate));
            if allIsInUpdate(1)
                updates(:,2)=[{0};num2cell(allSrgIds(allObjPidx([false;allIsInUpdate(2:end)])))];
            else
                updates(:,2)=num2cell(allSrgIds(allObjPidx(allIsInUpdate)));
            end
            updates(:,3)=num2cell(allSrgOlderBro(allIsInUpdate));

            upIsSf=allIsSf(allIsInUpdate);
            upIsAnnotation=isAnnotation(allIsInUpdate);

            if any(upIsSf)
                parentsH=[-1;allObjH(allObjPidx(2:end))];
                [sfFullname,sfShortname,sfTypes]=rmisf.objsInfo(...
                allObjH(allIsInUpdate&allIsSf),...
                allObjIsa(allIsInUpdate&allIsSf),...
                parentsH(allIsInUpdate&allIsSf));
                updates(upIsSf,4)=sfFullname;
                updates(upIsSf,5)=sfShortname;
                updates(upIsSf,6)=sfTypes;
            end

            upCanUseName=~upIsSf&~upIsAnnotation;
            allUpCanUseName=allIsInUpdate&~allIsSf&~isAnnotation;
            updates(upCanUseName,4)=cell_getfullname(allObjH(allUpCanUseName));
            updates(upCanUseName,5)=rmisl.cellGetParam(allObjH(allUpCanUseName),'Name');



            upSlAnnotation=find(~upIsSf&upIsAnnotation);
            allUpIsSlAnnotation=allIsInUpdate&~allIsSf&isAnnotation;
            upSlAnnObjH=allObjH(allUpIsSlAnnotation);
            for i=1:length(upSlAnnotation)
                sid=Simulink.ID.getSID(upSlAnnObjH(i));
                text=get_param(upSlAnnObjH(i),'Text');
                updates(upSlAnnotation(i),4:5)={sid,trimAnnotationText(text)};
            end


            for my_i=1:updatesCnt
                if~isempty(updates{my_i,5})
                    updates{my_i,5}=strrep(updates{my_i,5},newline,' ');
                end
            end

            slInUpdate=allIsInUpdate&~allIsSf;
            updates(~upIsSf,6)=rmisync.getSlObjType(allObjH(slInUpdate),isAnnotation(slInUpdate));

            updates(:,7)=num2cell(allDepths(allIsInUpdate));

            if sigbUpdateCnt>0
                allUpdates(nonSBUpdateIdx,:)=updates;
                allUpdates(SBUpdateIdx,:)=sigbMods;
            else
                allUpdates=updates;
            end
        else
            allUpdates=sigbMods;
        end

        firstNewId=syncObj.updateModule(allUpdates,dmDeletedIds);


        newIdx=firstNewId;
        if(sigbUpdateCnt==0||isempty(sbAllIdx))
            merge_blk_range_new_reqs;
            if(sigbCnt>0)
                for sbI=1:sigbCnt
                    updateSigBuilderReqs(sigbH(sbI),sigbNewReqs{sbI},syncObj);
                end
            end
        else

            merge_blk_range_new_reqs([],sigAllIdx(1)-1);

            for my_i=1:sigbCnt
                if rmiut.progressBarFcn('isCanceled')
                    break;
                end
                merge_sigb_new_tab_reqs(my_i);

                if my_i==sigbCnt
                    merge_blk_range_new_reqs(sigAllIdx(my_i)+1,[]);
                else
                    merge_blk_range_new_reqs(sigAllIdx(my_i)+1,sigAllIdx(my_i+1)-1);
                end
            end
        end

    else

        for sbI=1:sigbCnt
            updateSigBuilderReqs(sigbH(sbI),sigbNewReqs{sbI},syncObj);
        end

        if~isempty(dmDeletedIds)
            syncObj.markDeleted(dmDeletedIds);
        else

            if~syncObj.isTesting
                syncObj.openSrgModule();
            end
        end
        firstNewId=0;
    end


    if syncObj.isTesting
        newFileName='actual_update_data.mat';
        save(newFileName,'dmDeletedIds','surrogateLinkUpdates','firstNewId');
    else
        syncObj.updateSrgLinks(surrogateLinkUpdates);

        [capture,dirName]=rmisync.syncTestCapture();
        if capture
            modelName=get_param(syncObj.modelH,'Name');
            newFileName=fullfile(dirName,[modelName,'_update_data.mat']);
            save(newFileName,'dmDeletedIds','surrogateLinkUpdates','firstNewId');
        end
    end



    if syncObj.saveModel
        try
            save_system(syncObj.modelH);
        catch Mex
            msg=['Could not save "',get_param(syncObj.modelH,'Name'),'", error message: ',Mex.message];
            warndlg(msg);
        end
    end

    if~syncObj.isTesting
        syncObj.updateModuleProps();
    end

    rmiut.progressBarFcn('delete');









    function map_signal_builder_groups(dmSigbIdx,mdlSigbIdx,pathMatches)







        reqIds=dmSigbSrgIds{dmSigbIdx};
        srgNames=dmSigbGroupNames{dmSigbIdx};
        dmIdxVect=dmSigbSurrIdx{dmSigbIdx};
        dmIsValid(dmIdxVect)=false;
        dmIsRemap(dmIdxVect)=false;

        slNames=sigbGroupNames{mdlSigbIdx};
        slIds=sigbGroupSrgIds{mdlSigbIdx};
        slCnt=sigbGroupCnt(mdlSigbIdx);

        slGrpModSrgId=zeros(slCnt,1);
        slGrpModItemIdx=zeros(slCnt,1);
        slGrpInUpdate=false(slCnt,1);


        [slIsNameMatch,slGrpIdx,srgMatch]=rmiut.setmap(srgNames,slNames);
        slGrpModSrgId(slGrpIdx)=reqIds(srgMatch);
        slGrpModItemIdx(slGrpIdx)=dmIdxVect(srgMatch);

        if(pathMatches)
            if length(slGrpIdx)>1
                isorigidx=[slGrpIdx(1)==1,diff(slGrpIdx)==1];
                valid=srgMatch';
                valid(valid)=isorigidx;
                remap=srgMatch';
                remap(remap)=(~isorigidx);
                dmIsValid(dmIdxVect(valid))=true;
                dmIsRemap(dmIdxVect(remap))=true;
                slGrpInUpdate(slGrpIdx(~isorigidx))=true;
            else
                dmIsValid(dmIdxVect(srgMatch))=true;
            end
        else
            dmIsRemap(dmIdxVect(srgMatch))=true;
            slGrpInUpdate(slIsNameMatch)=true;
        end


        if any(~slIsNameMatch)
            if any(~srgMatch)
                slIdUnMap=slIds(~slIsNameMatch);
                dIdUnMap=reqIds(~srgMatch);
                dIdxVectUnMap=dmIdxVect(~srgMatch);
                [dM,map_idx,slM]=rmiut.setmap(slIdUnMap,dIdUnMap);

                if any(slM)
                    remap=~srgMatch;
                    remap(remap)=dM;
                    dmIsRemap(dmIdxVect(remap))=true;

                    notMatchIdx=find(~slIsNameMatch);
                    slGrpModSrgId(notMatchIdx(slM))=dIdUnMap(map_idx);
                    slGrpModItemIdx(notMatchIdx(slM))=dIdxVectUnMap(map_idx);
                    slGrpInUpdate(notMatchIdx(slM))=true;
                end
            end
        else
            if(pathMatches)

                allIsSurrNoChange(sigAllIdx(mdlSigbIdx))=true;
            end
        end


        for gIdx=1:slCnt
            dmItemIdx=slGrpModItemIdx(gIdx);
            if dmItemIdx>0
                [newReqs,myNewLinkStr]=rmisync.mergeLinks(...
                sigbGroupReqs{mdlSigbIdx}{gIdx},...
                syncObj,...
                dmSrgIds(dmItemIdx),...
                linkInfo{dmItemIdx});
                if~isempty(myNewLinkStr)
                    surrogateLinkUpdates=[surrogateLinkUpdates;{dmSrgIds(dmItemIdx),myNewLinkStr}];
                end

                if isempty(sigbNewReqs{mdlSigbIdx})
                    newReqCell={};
                else
                    newReqCell=sigbNewReqs{mdlSigbIdx};
                end
                newReqCell{gIdx}=newReqs;
                sigbNewReqs{mdlSigbIdx}=newReqCell;
            end
        end


        allGrpsInSurr=filtNone||~(filtAll||(filtMask&&allIsMasked(sigAllIdx(mdlSigbIdx))));
        if(allGrpsInSurr)
            slGrpInUpdate(slGrpModSrgId==0)=true;
            slGrpModSrgId(slGrpModSrgId==0)=-1;
        else

            hasSysReqs=sigbGroupHasSrgReqs{mdlSigbIdx};
            slGrpNewinSurr=((slGrpModSrgId'==0)&(slIds>0|hasSysReqs));
            slGrpModSrgId(slGrpNewinSurr)=-1;
            slGrpInUpdate(slGrpNewinSurr)=true;
        end


        if any(slGrpInUpdate)
            allIsSurrChange(sigAllIdx(mdlSigbIdx))=true;
        end


        sigbGrpModSrgId{mdlSigbIdx}=slGrpModSrgId;
        sigbGrpInUpdate{mdlSigbIdx}=slGrpInUpdate;
        sigbHasNew(mdlSigbIdx)=any(slGrpModSrgId==-1);
    end

    function cache_skipped_range_signal_builder_info(firstIdx,lastIdx)


        parentPathCache=parentPaths;

        lastCheckedIdx=firstIdx-1;

        if any(dmIsSigBuilder(firstIdx:lastIdx))
            thisIdx=lastCheckedIdx+1;

            while(thisIdx<=lastIdx)

                if(dmDepths(thisIdx)>dmDepths(lastCheckedIdx))

                    parentPaths=[dmPaths(lastCheckedIdx),parentPaths];
                elseif(dmDepths(thisIdx)<dmDepths(lastCheckedIdx))

                    popCount=dmDepths(lastCheckedIdx)-dmDepths(thisIdx);
                    parentPaths(1:popCount)=[];
                end

                lastCheckedIdx=thisIdx;

                if dmIsSigBuilder(thisIdx)
                    groupCnt=cache_surrogate_signal_builder_info(thisIdx);
                    thisIdx=thisIdx+groupCnt;
                else
                    thisIdx=thisIdx+1;
                end
            end
        end


        parentPaths=parentPathCache;
    end

    function groupCnt=cache_surrogate_signal_builder_info(my_idx)
        remainIsSigB=dmIsSigBuilder((my_idx+1):end);
        nextNonSigb=find(~remainIsSigB);
        if isempty(nextNonSigb)
            groupCnt=length(remainIsSigB)+1;
        else
            groupCnt=nextNonSigb(1);
        end
        groupIdx=my_idx+(1:groupCnt)-1;

        [objH,groupNames,actCnt]=rmisync.resolveSigBuilderGroup(parentPaths{1},dmPaths,groupIdx);



        if actCnt<groupCnt
            groupIdx((actCnt+1):end)=[];
            groupCnt=actCnt;
        end

        dmSigbGroupNames{end+1}=groupNames;
        dmSigbSrgIds{end+1}=dmSrgIds(groupIdx);
        dmSigbSurrIdx{end+1}=groupIdx;
        dmSigbObjH(end+1)=objH(1);
        dmSigbGroupCnt(end+1)=groupCnt;
    end

    function assign_blk_sigb_range_unique_ids(sigbHasNewAllIdx,elmIdx)

        sbIdx=allIdx2SbIdx(sigbHasNewAllIdx(elmIdx));


        if elmIdx==1
            preBlkIdx=1:(sigbHasNewAllIdx(1)-1);
        else
            startIdx=sigbHasNewAllIdx(elmIdx-1)+1;
            preBlkIdx=startIdx:(sigbHasNewAllIdx(elmIdx)-1);
        end
        assign_blk_range(preBlkIdx);


        grpCnt=sum(sigbGrpModSrgId{sbIdx}==-1);
        if grpCnt>0
            sigbGrpModSrgId{sbIdx}(sigbGrpModSrgId{sbIdx}==-1)=nextNewId-(0:(grpCnt-1));
            nextNewId=nextNewId-grpCnt;
        end

        nonZeroIds=sigbGrpModSrgId{sbIdx}(sigbGrpModSrgId{sbIdx}~=0);

        lastIds(sbIdx)=nonZeroIds(end);


        if(elmIdx==length(sigbHasNewAllIdx))
            postBlkIdx=(sigbHasNewAllIdx(end)+1):allObjCnt;
            assign_blk_range(postBlkIdx);
        end


        function assign_blk_range(blkRange)
            newBlkCnt=sum(allIsNew(blkRange));
            tempIds=allSrgIds(blkRange);
            tempIds(allIsNew(blkRange))=nextNewId-(0:(newBlkCnt-1));
            allSrgIds(blkRange)=tempIds;
            nextNewId=nextNewId-newBlkCnt;
        end
    end


    function merge_blk_range_new_reqs(startIdx,endIdx)
        if nargin==0
            myAllMergeIdx=find(allIsNew);
        else
            if isempty(startIdx)
                myAllMergeIdx=find(allIsNew(1:endIdx));
            else
                if isempty(endIdx)
                    myAllMergeIdx=find(allIsNew(startIdx:end))+startIdx-1;
                else
                    myAllMergeIdx=find(allIsNew(startIdx:endIdx))+startIdx-1;
                end
            end
        end

        if~isempty(myAllMergeIdx)
            totalObjs=length(allObjH);
            for j=myAllMergeIdx(:)'
                myNewLinkStr=rmisync.setMergedReqs(allObjH(j),allReqInfo{j},syncObj,newIdx,'');
                if~isempty(myNewLinkStr)
                    surrogateLinkUpdates=[surrogateLinkUpdates;{newIdx,myNewLinkStr}];
                end
                if mod(j,100)==0
                    if rmiut.progressBarFcn('isCanceled')
                        return;
                    else
                        rmiut.progressBarFcn('set',0.5+j/totalObjs/2,...
                        getString(message('Slvnv:rmiut:progressBar:SyncUpdatingLinks')));
                    end
                end
                newIdx=newIdx+1;
            end
        end
    end


    function merge_sigb_new_tab_reqs(sigbMdlIdx)
        sbH=sigbH(sigbMdlIdx);
        grpMergeIdx=find(sigbGrpModSrgId{sigbMdlIdx}<0);
        origReqs=sigbGroupReqs{sigbMdlIdx};
        newGrpReqs=sigbNewReqs{sigbMdlIdx};

        if~isempty(grpMergeIdx)
            for gIdx=grpMergeIdx(:)'
                [newReqs,myNewLinkStr]=rmisync.mergeLinks(...
                origReqs{gIdx},...
                syncObj,...
                newIdx,...
                '');
                newGrpReqs{gIdx}=newReqs;

                if~isempty(myNewLinkStr)
                    surrogateLinkUpdates=[surrogateLinkUpdates;{newIdx,myNewLinkStr}];
                end
                newIdx=newIdx+1;
            end
            sigbNewReqs{sigbMdlIdx}=newGrpReqs;
        end
        updateSigBuilderReqs(sbH,newGrpReqs,syncObj);
    end


    function out=cell_getfullname(objH)
        out=getfullname(objH);
        if~iscell(out)
            out={out};
        end
    end

    function outIdx=next_non_descendent(thisIdx,depths)
        nonDescendentIdx=find(depths<=depths(thisIdx));
        nonDescendentIdx(nonDescendentIdx<=thisIdx)=[];
        if~isempty(nonDescendentIdx)
            outIdx=nonDescendentIdx(1);
        else
            outIdx=length(depths)+1;
        end
    end

end


function updateSigBuilderReqs(blockH,newReqs,syncObj)

    if isempty(newReqs)
        return;
    end


    grpCnt=length(newReqs);
    for gIdx=1:grpCnt
        updatedReqs=syncObj.updateDocNames(newReqs{gIdx});
        rmi('set',blockH,updatedReqs,gIdx);
    end


    figH=get_param(blockH,'UserData');
    if~isempty(figH)&&ishandle(figH)
        UD=get(figH,'UserData');

        if isfield(UD,'verify')&&isfield(UD.verify,'jVerifyPanel')
            vnv_panel_mgr('sbGroupChange',blockH,UD.verify.jVerifyPanel);
        end
    end
end

function txt=trimAnnotationText(txt)

    txt=strrep(txt,newline,' ');

    txt=regexprep(strtrim(txt),'<[^>]+>',' ');
    txt=strtrim(regexprep(txt,'\s\s+',' '));
    if length(txt)>50
        txt=[txt(1:50),'...'];
    end
end



