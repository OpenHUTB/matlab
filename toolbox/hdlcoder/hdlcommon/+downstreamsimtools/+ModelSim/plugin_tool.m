function hP=plugin_tool()





    hP=downstream.plugin.PluginSimulationTool;


    hP.ToolName='ModelSim';
    hP.ToolVersion='';
    hP.ToolPath='';

    hP.cmd_openTargetTool='vsim';
    hP.cmd_runTclScript='vsim';
    hP.cmd_checkToolVersion='';
    hP.cmd_regexpToolVersion='';

    hP.ProjectDir=fullfile('hdlsrc');

    hP.isSupported=true;
