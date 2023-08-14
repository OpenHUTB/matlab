function configParamStatus(~,cbInfo,action)











    cs=getActiveConfigSet(cbInfo.model.handle);
    action.enabled=~isa(cs,'Simulink.ConfigSetRef');
