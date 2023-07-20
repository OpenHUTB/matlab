function ret=plc_skip_ladder(blkH)


    import plccore.common.*;
    ret=false;
    try
        ret=strcmp(get_param(bdroot(blkH),PLCLadderMgr.SkipLadderParam),'on');
    catch
    end
end
