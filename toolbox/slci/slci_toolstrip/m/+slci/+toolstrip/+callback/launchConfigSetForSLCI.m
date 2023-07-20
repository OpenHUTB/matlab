


function launchConfigSetForSLCI(cbinfo)

    mdl=cbinfo.model.Handle;
    cs=getActiveConfigSet(mdl);

    slciOption='AdvancedOptControl';
    adp=configset.internal.data.ConfigSetAdapter(cs);





    status=adp.getParamStatus(slciOption);
    isAvailableInGUI=(status<2);

    if isAvailableInGUI
        configset.highlightParameter(cs,slciOption)
    else
        configset.showParameterGroup(cs,{'Optimization'});
    end
end