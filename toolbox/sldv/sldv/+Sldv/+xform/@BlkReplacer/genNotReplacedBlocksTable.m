function genNotReplacedBlocksTable(obj)




    mdlRefBlockInlined=~isempty(obj.ReplacedMdlRefBlks);
    for idx=1:length(obj.MdlRefBlksRejectedForReplacement)
        blockInfo=obj.MdlRefBlksRejectedForReplacement{idx};
        replacementInfo=blockInfo.ReplacementInfo;

        if~replacementInfo.IsInactiveMdlBlk
            blockH=replacementInfo.BlockToReplaceH;
            repInfo.BeforeRepFullPath=loc_getPathInReplacementModel(blockInfo);
            repBlockH=get_param(repInfo.BeforeRepFullPath,'handle');
            repInfo.IsReplaceableMsgs=unique(replacementInfo.IsReplaceableMsgs);
            repInfo.BeforeRepFullPath=obj.deriveOriginalBlockPath(blockH,...
            repInfo.BeforeRepFullPath,mdlRefBlockInlined);
            obj.NotReplacedBlocksTable(repBlockH)=repInfo;
        end
    end
end

function fullPath=loc_getPathInReplacementModel(blockInfo)
    blockH=blockInfo.ReplacementInfo.BlockToReplaceH;

    fullPath=getfullname(blockH);
    mdlPath_idx=strfind(fullPath,'/');
    if~isempty(mdlPath_idx)
        relativePath=fullPath(mdlPath_idx(1)+1:end);
        parentInfo=blockInfo.Up;
        if~isempty(parentInfo)


            fullPath=[getfullname(parentInfo.ReplacementInfo.AfterReplacementH),'/',relativePath];
        end
    end

end
