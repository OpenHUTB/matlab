




function codeVerificationData=getCodeVerification(fnKeys,datamgr,reportConfig)








    pCodeVerReportStage1=slci.internal.Profiler('SLCI','CodeVerificationStage1','','');

    if numel(fnKeys)>0
        codeDetailList=slci.report.getCodeDetail(fnKeys,datamgr,reportConfig);
    else
        codeDetailList=[];
    end

    pCodeVerReportStage1.stop();








    pCodeVerReportStage2=slci.internal.Profiler('SLCI','CodeVerificationStage2','','');

    if numel(fnKeys)>0
        codeSummaryList=slci.report.getCodeSummary(fnKeys,datamgr,reportConfig);
    else
        codeSummaryList=[];
    end

    pCodeVerReportStage2.stop();


    pCodeVerReportStage3=slci.internal.Profiler('SLCI','CodeVerificationStage1','','');
    resultsReader=datamgr.getReader('RESULTS');
    codeStatus=resultsReader.getObject('CodeInspectionStatus');
    pCodeVerReportStage3.stop();

    pCodeVerReportStage4=slci.internal.Profiler('SLCI','CodeVerificationStage1','','');
    codeVerificationData.SUMMARY.STATUS.ATTRIBUTES=codeStatus;
    codeVerificationData.SUMMARY.STATUS.CONTENT=...
    reportConfig.getStatusMessage(codeStatus);



    codeVerificationData.SUMMARY.TABLEDATA=codeSummaryList;
    codeVerificationData.DETAIL.SECTIONLIST=codeDetailList;

    pCodeVerReportStage4.stop();

end

