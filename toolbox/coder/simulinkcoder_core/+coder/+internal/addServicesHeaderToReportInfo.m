function addServicesHeaderToReportInfo(reportInfo,servicesHeaderName,...
    servicesHeaderPath,calledShowReport)





    groupName='interface';
    fileType='header';
    fileTag='';




    removeFileInfo(reportInfo,servicesHeaderName,servicesHeaderPath);


    addFileInfo(reportInfo,servicesHeaderName,groupName,fileType,...
    servicesHeaderPath,fileTag);
    update(reportInfo);



    if calledShowReport
        rtw.report.close;
        show(reportInfo);
    end
end
