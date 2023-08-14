function cleanUpSRFiles(rMgr)









    try
        computeSRFilesToDelete(rMgr);
        deleteFiles(rMgr);
    catch ex
        Simulink.variant.reducer.utils.logException(ex);
        rethrow(ex);
    end
end

function computeSRFilesToDelete(rMgr)
...
...
...
...
    SRFileToBlks=rMgr.AllRefBlocksInfo.getSRFileToBlockMap();
    for SRFileKey=keys(SRFileToBlks)
        updateGroupedInstances(rMgr,SRFileToBlks(SRFileKey{1}));
    end
end

function changeReferredSubsystemInRedModel(rMgr,currSRInfo,SRFile)
...
...
...
...
...
    blkInst=Simulink.variant.reducer.utils.getDefinitionBlock(currSRInfo);
    redBH=getBlockHandleForReducedModel(rMgr,blkInst,currSRInfo);
    set_param(redBH,'ReferencedSubsystem',SRFile);
end

function updateGroupedInstances(rMgr,SRInfos)
...
...
...
...
    [SRBlksInfo,redBDName]=getGroupedInstances(rMgr,SRInfos);
    for blkIdx=1:numel(SRBlksInfo)
        SRBlkInfo=SRBlksInfo{blkIdx};
        if~isKey(rMgr.SRBlkInstToRedSRBD,SRBlkInfo.BlockInstance)


            continue;
        end
        prevFile=rMgr.SRBlkInstToRedSRBD(SRBlkInfo.BlockInstance);
        if~isequal(prevFile,redBDName)
            changeReferredSubsystemInRedModel(rMgr,SRBlkInfo,redBDName);
            [~,~,ext]=fileparts(SRBlkInfo.RefersToFilePath);
            rMgr.RedundantSRFiles(prevFile)=ext;
        end
    end
end

function[SRBlksInfo,redBDName]=getGroupedInstances(rMgr,SRInfos)
...
...
...
...
...
...
...
    SRBlksInfo={};
    redBDName='';
    for idx=1:numel(SRInfos)
        currSRInfo=SRInfos{idx};
        blkInst=currSRInfo.BlockInstance;
        if~isTreatAsGrouped(blkInst)
            continue;
        end
        SRBlksInfo{end+1}=currSRInfo;%#ok<AGROW>
        if~isKey(rMgr.SRBlkInstToRedSRBD,blkInst)


            continue;
        end
        currRedBDName=rMgr.SRBlkInstToRedSRBD(blkInst);

        if isempty(redBDName)||numel(currRedBDName)<numel(redBDName)

            redBDName=currRedBDName;
        end
    end
end

function tf=isTreatAsGrouped(blkInst)
    tf=isequal(get_param(blkInst,...
    'TreatAsGroupedWhenPropagatingVariantConditions'),'on');
end

function deleteFiles(rMgr)
    fileNames=rMgr.RedundantSRFiles.keys;
    for fidx=1:numel(fileNames)
        fname=fileNames{fidx};
        ext=rMgr.RedundantSRFiles(fname);
        file=[fname,ext];
        delete(file);
    end
end


