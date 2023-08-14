function hP=plugin_tool()





    hP=downstream.plugin.PluginSimulationTool;


    hP.ToolName='ISIM';
    hP.ToolVersion='';
    hP.ToolPath='';

    hP.cmd_openTargetTool='ise';
    hP.cmd_runTclScript='ise';
    hP.cmd_checkToolVersion='';
    hP.cmd_regexpToolVersion='';

    hP.ProjectDir=fullfile('hdlsrc');

    hP.isSupported=true;
