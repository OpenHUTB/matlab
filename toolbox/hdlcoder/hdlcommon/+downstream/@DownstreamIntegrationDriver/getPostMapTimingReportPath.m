function timingPath=getPostMapTimingReportPath(obj)


    toolName=obj.get('Tool');
    if strcmpi(toolName,'Xilinx ISE')
        timingPath=fullfile(obj.getProjectPath,[obj.hCodeGen.EntityTop,'_preroute.twr']);
    elseif strcmpi(toolName,'Xilinx Vivado')
        timingPath=fullfile(obj.getProjectPath,[obj.hCodeGen.EntityTop,'_preroute.tvr']);
    elseif strcmpi(toolName,'Altera QUARTUS II')
        timingPath=fullfile(obj.getProjectPath,[obj.hCodeGen.EntityTop,'_preroute.tqr']);
    else
        error(message('hdlcommon:workflow:UnsupportedTool',toolName));
    end
    if~exist(timingPath,'file')
        error(message('hdlcommon:workflow:NoTimingReportFile',timingPath));
    end
end
