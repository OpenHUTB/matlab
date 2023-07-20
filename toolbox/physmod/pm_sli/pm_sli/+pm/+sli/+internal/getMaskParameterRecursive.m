function p=getMaskParameterRecursive(blk,name)









    mo=get_param(blk,'MaskObject');
    p=[];


    while~isempty(mo)
        p=mo.getParameter(name);
        if~isempty(p)
            return;
        end
        mo=mo.BaseMask;
    end

end
