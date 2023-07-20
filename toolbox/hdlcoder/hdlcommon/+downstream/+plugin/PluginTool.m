


classdef PluginTool<downstream.plugin.PluginBase



    properties

        ToolName='';
        ToolVersion='';
        ToolPath='';

        cmd_openTargetTool='';
        cmd_runTclScript='';
        cmd_checkToolVersion='';
        cmd_regexpToolVersion='';
        cmd_logRegExp='';

        ProjectDir='';


        PluginPath='';
        PluginPackage='';
        isSupported=false;
        publishTool=true;


        IPLatencyTables={targetcodegen.targetCodeGenerationUtils.latencyTableForALTERFPFUNCTION(),...
        targetcodegen.targetCodeGenerationUtils.latencyTableForALTFP(),...
        targetcodegen.targetCodeGenerationUtils.latencyTableForXILINXLOGICORE()};


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
            hToolDriver.hTool.cmd_logRegExp=obj.cmd_logRegExp;

            hToolDriver.hTool.ProjectDir=obj.ProjectDir;

            hToolDriver.hTool.PluginPath=obj.PluginPath;
            hToolDriver.hTool.PluginPackage=obj.PluginPackage;
            hToolDriver.hDevice.PluginPath=obj.PluginPath;

            hToolDriver.hTool.UnSupportedVersion=obj.UnSupportedVersion;
            hToolDriver.hTool.VersionWarningMsg=obj.VersionWarningMsg;

        end

    end

end