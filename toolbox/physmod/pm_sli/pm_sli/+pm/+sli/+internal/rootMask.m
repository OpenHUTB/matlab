function mo=rootMask(blk)







    mo=get_param(blk,'MaskObject');
    if isempty(mo)
        return;
    end

    while~isempty(mo.BaseMask)
        mo=mo.BaseMask;
    end

end