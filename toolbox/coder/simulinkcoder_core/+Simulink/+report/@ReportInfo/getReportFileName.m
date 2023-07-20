function out=getReportFileName(obj)
    if Simulink.report.ReportInfo.featureReportV2&&isa(obj,'rtw.report.ReportInfo')...
        &&~isa(obj,'Simulink.ModelReference.ProtectedModel.Report')
        out='index.html';
    else
        out=[obj.ModelName,obj.getModelNameSuffix(),'_codegen_rpt.html'];
    end
end
