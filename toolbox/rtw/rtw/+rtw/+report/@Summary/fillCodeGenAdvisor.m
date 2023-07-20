function fillCodeGenAdvisor(obj,chapter)
    import mlreportgen.dom.*;
    mdlName=strtok(obj.SubsystemPathAndName,'/');
    aTable=rtw.report.Summary.genConfigCheckReportTable(obj.ModelName,mdlName,obj.SubsystemPathAndName);
    chapter.append(aTable);
end
