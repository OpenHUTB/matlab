function val=hdlslResolve(this,prop,block)












    prop_val=get_param(block,prop);
    val=slResolve(prop_val,block,'expression','startAboveMask');


