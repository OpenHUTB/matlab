function timingPath=getPARReportPath(obj)


    toolName=obj.get('Tool');
    if strcmpi(toolName,'Xilinx ISE')
        timingPath=fullfile(obj.getProjectPath,[obj.hCodeGen.EntityTop,'.par']);
    else
        error(message('hdlcommon:workflow:UnsupportedTool',toolName));
    end
    if~exist(timingPath,'file')
        error(message('hdlcommon:workflow:NoPARReportFile',timingPath));
    end
end
