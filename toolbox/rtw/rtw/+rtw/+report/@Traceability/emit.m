function emit(obj,rpt,type,template,reportInfo)
    part=coder.report.internal.slcoderPublishTraceability(type,template,obj,reportInfo);
    part.fill();
    rpt.append(part);
end
