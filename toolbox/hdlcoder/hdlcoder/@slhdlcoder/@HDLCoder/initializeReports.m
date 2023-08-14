function reportInfo=initializeReports(this,p)
    if this.mdlIdx==numel(this.AllModels)&&this.DutMdlRefHandle>0
        mdlName=this.OrigModelName;
    else
        mdlName=p.ModelName;
    end
    traceabilityDriver=this.getTraceabilityDriver(mdlName);
    this.hdlMakeCodegendir;
    reportInfo=hdlcoder.report.ReportInfo(traceabilityDriver.TopModel);
    reportInfo.init(this,p);
end

