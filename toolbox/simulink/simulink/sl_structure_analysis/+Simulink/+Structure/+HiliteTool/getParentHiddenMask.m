function maskBlk=getParentHiddenMask(blockHandle)


    maskBlk=[];
    try
        blk=get_param(blockHandle,'parent');
        while(isempty(maskBlk)&&~isempty(blk))

            if strcmp(get_param(blk,'MaskHideContents'),'on')
                maskBlk=blk;
                break;
            end
            blk=get_param(blk,'parent');
        end
    catch
        maskBlk=[];
    end


end