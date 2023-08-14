function generate(obj,reportInfo)
    if~isempty(obj.Data)
        generate@coder.report.CodeMetricsBase(obj);
    elseif rtw.report.ReportInfo.featureReportV2&&...
        reportInfo.IsERTTarget&&...
        ~Simulink.ModelReference.ProtectedModel.protectingModel(reportInfo.ModelName)&&...
        strcmp(get_param(reportInfo.ModelName,obj.getConfigOption),'on')






        subsys=reportInfo.SourceSubsystem;
        currModel=reportInfo.ModelName;
        buildDir=reportInfo.BuildDirectory;
        isSubsystemModelClosed=~isempty(reportInfo.SourceSubsystem)&&...
        ~isValidSlObject(slroot,currModel);
        isRegularModelNotInBuild=isValidSlObject(slroot,currModel)&&...
        isempty(coder.internal.ModelCodegenMgr.getInstance(currModel));
        if(isSubsystemModelClosed||isRegularModelNotInBuild)



            if~slfeature('DecoupleCodeMetrics')||reportInfo.isInstrBuild
                CMSaveDirectory=reportInfo.getReportDir;
            else
                CMSaveDirectory=fullfile(reportInfo.StartDir,reportInfo.ModelRefRelativeBuildDir,'tmwinternal');
            end
            rtw.report.CodeMetrics.generateStaticCodeMetrics(reportInfo,reportInfo.getBuildInfo(),...
            CMSaveDirectory,subsys,true);


            generate@coder.report.CodeMetricsBase(obj);
        else
            coder.internal.slcoderReport('genTempCodeMetricsReport',currModel,buildDir);
        end
    elseif rtw.report.ReportInfo.featureReportV2&&...
        Simulink.ModelReference.ProtectedModel.protectingModel(reportInfo.ModelName)
        currModel=reportInfo.ModelName;
        coder.internal.slcoderReport('generateEmptyMetricsReport',fullfile(obj.ReportFolder,obj.ReportFileName),currModel);
    else


        return
    end
end
