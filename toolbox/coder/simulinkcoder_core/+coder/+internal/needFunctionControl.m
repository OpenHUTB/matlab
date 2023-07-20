function flag=needFunctionControl(blk_hdl,mdl_hdl)






    cs=getActiveConfigSet(mdl_hdl);
    isERT=get_param(cs,'IsERTTarget');
    isMdlStepFcnProtoCompliant=get_param(cs,'ModelStepFunctionPrototypeControlCompliant');
    isAutosarCompliant=get_param(cs,'AutosarCompliant');
    ssType=Simulink.SubsystemType(blk_hdl);
    flag=strcmp(isERT,'on')&&...
    (strcmp(isMdlStepFcnProtoCompliant,'on')||strcmp(isAutosarCompliant,'on'))&&...
    ~ssType.isVirtualSubsystem();
