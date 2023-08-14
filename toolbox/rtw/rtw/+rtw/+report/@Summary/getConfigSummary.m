function out=getConfigSummary(obj)

    old=pwd;
    cd(obj.CodeGenFolder);
    mdlName=strtok(obj.SubsystemPathAndName,'/');
    out=coder.internal.genConfigCheckReportElements(obj.ModelName,obj.BInfoMat,mdlName,obj.SubsystemPathAndName,fullfile(obj.ReportFolder,obj.ReportFileName));
    cd(old);
end
