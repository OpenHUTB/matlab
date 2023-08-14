function attachSystemComposerPlugin(mdlName)



    pluginMgr=Simulink.PluginMgr;
    pluginName='sysarch_app_plugin';
    bdHandle=get_param(mdlName,'handle');
    pluginMgr.attach(bdHandle,pluginName);
end
