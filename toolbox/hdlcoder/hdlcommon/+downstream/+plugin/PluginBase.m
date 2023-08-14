


classdef(Abstract)PluginBase<handle



    properties

    end

    methods(Static,Hidden=true)

        function plugin=loadPluginFile(pluginPackage,pluginName)


            cmdStr=sprintf('%s.%s',pluginPackage,pluginName);
            try
                plugin=eval(cmdStr);
            catch me
                error(message('hdlcommon:workflow:InvalidPluginFile',cmdStr));
            end

        end

        function isExist=existPluginFile(pluginPath,pluginName)


            mfilePath=fullfile(pluginPath,sprintf('%s.m',pluginName));
            pfilePath=fullfile(pluginPath,sprintf('%s.p',pluginName));
            isExist=exist(mfilePath,'file')||exist(pfilePath,'file');

        end


    end
end
