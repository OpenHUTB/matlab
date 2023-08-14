function createReportDir(obj)
    reportDir=obj.getReportDir;
    if exist(reportDir,'dir')
        slprivate('removeDir',reportDir);
    end
    rtwprivate('rtw_create_directory_path',reportDir);

    sharedDir=obj.getSharedUtilsReportDir;
    if~isempty(sharedDir)&&~exist(sharedDir,'dir')
        rtwprivate('rtw_create_directory_path',sharedDir);
    end
end
