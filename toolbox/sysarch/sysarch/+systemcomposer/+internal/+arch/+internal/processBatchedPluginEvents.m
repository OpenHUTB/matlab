function processBatchedPluginEvents(mdlName)

    bdH=get_param(mdlName,'Handle');
    subdomain=get_param(mdlName,'SimulinkSubDomain');





    Simulink.SystemArchitecture.internal.ApplicationManager.processBatchedPluginEvents(bdH);

end