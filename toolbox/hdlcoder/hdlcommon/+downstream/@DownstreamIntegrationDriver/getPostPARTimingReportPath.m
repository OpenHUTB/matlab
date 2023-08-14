function timingPath=getPostPARTimingReportPath(obj)


    toolName=obj.get('Tool');
    if strcmpi(toolName,'Xilinx ISE')
        timingPath=fullfile(obj.getProjectPath,[obj.hCodeGen.EntityTop,'.twr']);
    elseif strcmpi(toolName,'Xilinx Vivado')
        timingPath=fullfile(obj.getProjectPath,[obj.hCodeGen.EntityTop,'_postroute.tvr']);
    elseif strcmpi(toolName,'Altera QUARTUS II')
        timingPath=fullfile(obj.getProjectPath,[obj.hCodeGen.EntityTop,'_postroute.tqr']);
    else
        error(message('hdlcommon:workflow:UnsupportedTool',toolName));
    end
    if~exist(timingPath,'file')
        error(message('hdlcommon:workflow:NoTimingReportFile',timingPath));
    end
end
