function createReportFolder(aObj)




    reportFolder=aObj.getReportFolder();
    if~exist(reportFolder,'dir')
        aObj.checkReportFolder(reportFolder);
        rtwprivate('rtw_create_directory_path',reportFolder);
    end
end


