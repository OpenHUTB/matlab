




function summary=genReport(aObj)

    if strcmpi(aObj.getDisplayResults,'Summary')
        slci.internal.outputMessage(...
        DAStudio.message('Slci:slci:ReportCmdStatus',...
        aObj.getModelName()),'info');
    end




    mgr=slci.internal.ModelStateMgr(aObj.getModelName());
    mgr.loadModel();


    aObj.ValidateProperties();

    try

        if~exist(aObj.getReportFolder(),'dir')
            DAStudio.error('Slci:slci:VerificationResultsError',...
            aObj.getReportFolder());
        end

        htmlReportFile=aObj.getReportFile();
        slci.Configuration.deleteReportFile(htmlReportFile);



        reportConfig=slci.internal.ReportConfig;

        [dm,status]=slci.report.generateReport(aObj,...
        reportConfig);


        aObj.SetupRefMdls();


        summary.ModelName=aObj.getModelName();


        if isempty(dm.getMetaData('ModelFileName'))
            summary.ModelFileName='';
        else
            summary.ModelFileName=dm.getMetaData('ModelFileName');
        end

        summary.Status=status;
        summary.ReportFile=aObj.getReportFile();

    catch ME
        aObj.HandleException(ME);
        summary=aObj.returnResultsOnError(false);
    end


    if(aObj.getFollowModelLinks())
        subModelSummary=aObj.genReportSubModels();
        summary=[summary,subModelSummary];
    end

end
