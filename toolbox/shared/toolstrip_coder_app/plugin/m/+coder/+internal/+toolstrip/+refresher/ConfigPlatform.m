function ConfigPlatform(cbinfo,action)




    mdl=cbinfo.editorModel.handle;
    cs=getActiveConfigSet(mdl);
    action.enabled=~isa(cs,'Simulink.ConfigSetRef');



