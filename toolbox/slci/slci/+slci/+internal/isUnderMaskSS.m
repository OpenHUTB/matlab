







function out=isUnderMaskSS(blkHandle)
    BlockObject=get_param(blkHandle,'Object');
    try
        out=~isempty(slci.internal.getMaskBlock(BlockObject.Parent));
    catch





        out=false;
    end
end
