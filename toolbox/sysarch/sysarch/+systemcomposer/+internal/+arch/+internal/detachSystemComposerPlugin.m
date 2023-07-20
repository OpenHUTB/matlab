function detachSystemComposerPlugin(mdlName)



    pluginMgr=Simulink.PluginMgr;
    pluginName='sysarch_app_plugin';
    bdHandle=get_param(mdlName,'handle');
    pluginMgr.detach(bdHandle,pluginName);
end
