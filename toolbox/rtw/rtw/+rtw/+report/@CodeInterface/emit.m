function emit(obj,rpt,type,template)
    part=coder.report.internal.slcoderPublishInterface(type,template,obj);
    codeInfo=coder.internal.codeinfo('getCodeInfo',obj.BuildDir,obj.ModelName);
    if~isempty(codeInfo)
        obj.CodeInfo=codeInfo.codeInfo;
        part.fill();
        rpt.append(part);
    end
end
