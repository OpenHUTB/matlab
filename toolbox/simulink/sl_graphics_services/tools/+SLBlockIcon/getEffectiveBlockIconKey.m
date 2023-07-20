function iconKey=getEffectiveBlockIconKey(blk)
    handle=get_param(blk,'handle');
    iconKey=SLBlockIcon.getEffectiveBlockIconKeyFromHandle(handle);
end