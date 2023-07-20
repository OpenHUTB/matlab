function resultJSON=generateReportMultiFile(appID)
    am=Advisor.Manager.getInstance;
    appObj=am.getApplication('ID',appID);
    reportname=appObj.generateReport;

    jsonData=jsonencode(reportname);
    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',jsonData);
    resultJSON=jsonencode(result);

end