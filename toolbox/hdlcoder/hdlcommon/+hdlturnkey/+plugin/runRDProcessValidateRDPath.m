function runRDProcessValidateRDPath(hRD,rdPath)




    if downstream.plugin.PluginBase.existPluginFile(...
        hRD.PluginPath,'process_validateRDPath')
        cmdStr=sprintf('%s.%s',hRD.PluginPackage,'process_validateRDPath(hRD, rdPath)');
        try
            eval(cmdStr);
        catch me
            rethrow(me);
        end
    end

end