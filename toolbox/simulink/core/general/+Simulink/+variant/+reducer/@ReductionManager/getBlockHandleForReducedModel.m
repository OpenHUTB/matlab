function blockHandle=getBlockHandleForReducedModel(rMgr,blockPath,blkInfo)
...
...
...
...
...
...
...
...
...
    [blkParent,blkRemain]=strtok(blockPath,'/');
    load_system(blkParent);
    if bdIsSubsystem(blkParent)
        SRBlkPath=getBlockInRedSR(rMgr,blockPath,blkInfo);
        blockHandle=get_param(SRBlkPath,'Handle');
    else
        redMdlBlkPath=blockPath;
        if~isequal(rMgr.getOptions().TopModelName,blkParent)
            if~isKey(rMgr.BDNameRedBDNameMap,blkParent)




                blockHandle=-1.0;
                return;
            end

            redMdl=rMgr.BDNameRedBDNameMap(blkParent);
            redMdlBlkPath=[redMdl,blkRemain];
        end
        blockHandle=get_param(redMdlBlkPath,'Handle');
    end
end


