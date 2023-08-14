function configParam(param,cbInfo,action)















    cs=getActiveConfigSet(cbInfo.model.handle);
    if isa(cs,'Simulink.ConfigSetRef')
        try
            value=get_param(cs,param);
        catch

            value='';
        end
    else
        value=get_param(cs,param);
    end
    action.text=value;
    coder.internal.toolstrip.refresher.configParamStatus(param,cbInfo,action);
