


classdef PluginSimulationTool<downstream.plugin.PluginBase



    properties

        ToolName='';
        ToolVersion='';
        ToolPath='';

        cmd_openTargetTool='';
        cmd_runTclScript='';
        cmd_checkToolVersion='';
        cmd_regexpToolVersion='';

        ProjectDir='';


        PluginPath='';
        PluginPackage='';
        isSupported=false;
        publishTool=true;


        UnSupportedVersion=false;
        VersionWarningMsg='';

    end

    methods

        function parsePluginFile(obj,hToolDriver)

            hToolDriver.hTool.ToolName=obj.ToolName;
            hToolDriver.hTool.ToolVersion=obj.ToolVersion;
            hToolDriver.hTool.ToolPath=obj.ToolPath;

            hToolDriver.hTool.cmd_openTargetTool=obj.cmd_openTargetTool;
            hToolDriver.hTool.cmd_runTclScript=obj.cmd_runTclScript;

            hToolDriver.hTool.ProjectDir=obj.ProjectDir;

            hToolDriver.hTool.PluginPath=obj.PluginPath;
            hToolDriver.hTool.PluginPackage=obj.PluginPackage;
            hToolDriver.hDevice.PluginPath=obj.PluginPath;

            hToolDriver.hTool.UnSupportedVersion=obj.UnSupportedVersion;
            hToolDriver.hTool.VersionWarningMsg=obj.VersionWarningMsg;

        end

    end

end