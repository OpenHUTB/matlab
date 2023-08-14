function openmlpkginstall(filename)









    try
        jArraybaseCodes=javaArray('java.lang.String',1);
        jArraybaseCodes(1)=java.lang.String(hwconnectinstaller.SignpostReader(filename).BaseCode);
        connector.ensureServiceOn;
        com.mathworks.supportsoftwarematlabmanagement.mlpkginstall.MlpkgInstallLauncher.launchSsiMlpkgDialog(jArraybaseCodes);
    catch ME
        errordlg(getReport(ME,'extended','hyperlinks','off'),'Support Software Client Error');
    end

end

