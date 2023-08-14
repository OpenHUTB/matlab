function runRDProcessPostTargetInterface(hRD,hDI)





    if downstream.plugin.PluginBase.existPluginFile(...
        hRD.PluginPath,'process_postTargetInterface')
        cmdStr=sprintf('%s.%s',hRD.PluginPackage,'process_postTargetInterface(hRD, hDI)');
        try
            eval(cmdStr);
        catch me
            rethrow(me);
        end
    end

end