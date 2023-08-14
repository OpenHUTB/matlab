function csHdl=getActiveConfigSet(model)



    load_system(model)
    bdHdl=get_param(model,'Object');
    csHdl=bdHdl.getActiveConfigSet();
