function newblocklist=resolveSyntheticModelRefBlocks(~,blocklist)








    newblocklist=[];newCount=1;
    for ii=1:numel(blocklist)
        blk=get_param(blocklist(ii),'Object');
        typ=get_param(blocklist(ii),'BlockType');

        if strcmp(typ,'SubSystem')&&blk.isSynthesized&&...
            strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_FCNCALL_MODELREF')
            newblocklist(newCount)=blk.getOriginalBlock;%#ok<AGROW>
            newCount=newCount+1;
            continue;
        end


        if strcmp(typ,'SubSystem')&&blk.isSynthesized&&...
            strcmp(blk.getSyntReason,'SL_SYNT_BLK_REASON_BUSEXPANSION')
            orig_blkH=blk.getOriginalBlock;
            orig_blk=get_param(orig_blkH,'Object');
            orig_typ=get_param(orig_blkH,'BlockType');
            if strcmp(orig_typ,'SignalConversion')&&orig_blk.isSynthesized&&...
                strcmp(orig_blk.getSyntReason,'SL_SYNT_BLK_REASON_BUSCONVERSION')
                parentH=orig_blk.getOriginalBlock;
                parent_typ=get_param(parentH,'BlockType');
                if strcmp(parent_typ,'Inport')||strcmp(parent_typ,'Outport')
                    continue;
                end
            end
        end


        newblocklist(newCount)=blocklist(ii);%#ok<AGROW>
        newCount=newCount+1;
    end
end


