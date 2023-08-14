function out=getContentsFileFullName(obj)
    out=fullfile(obj.getReportDir,coder.internal.slcoderReport('getContentsFileName',obj.ModelName,obj.CodeFormat));
end
