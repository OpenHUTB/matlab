function pluginPath=getPluginPath(obj)


    if(strcmpi(obj.get('Tool'),'No synthesis tool specified'))
        pluginPath='';
        return
    end
    pluginPath=obj.hToolDriver.hTool.PluginPath;
end
