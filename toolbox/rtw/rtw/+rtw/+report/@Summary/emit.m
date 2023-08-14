function emit(obj,rpt,type,template)
    part=coder.report.internal.slcoderPublishSummary(type,template,obj);
    part.fill();
    rpt.append(part);
end
