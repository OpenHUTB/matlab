function emit(obj,rpt,type,template,aReportInfo)
    part=coder.report.internal.slcoderPublishCodeMetrics(type,template,obj,aReportInfo);
    part.fill();
    rpt.append(part);
end
