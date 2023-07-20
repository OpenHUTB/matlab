function ctx=getPlatformContext(mdl)





    ctx='';
    type=coder.internal.toolstrip.util.getPlatformType(mdl);
    if type==1
        ctx='Platform_FC';
    else
        ctx='Platform_DF';
    end
