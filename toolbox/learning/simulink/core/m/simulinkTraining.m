

function simulinkTraining(courseCode,chapter,lesson,section)


    fileGenConfig=Simulink.fileGenControl('getConfig');
    if contains(tempdir,fileGenConfig.CacheFolder)
        error(message('learning:simulink:resources:InvalidCacheDir',tempdir,fileGenConfig.CacheFolder));
    end

    slTrainingInstallHelper.startInstallation();

    setupSlTraining;
    selfPacedTrainingStartup;
    slTrainingLauncher(courseCode,chapter,lesson,section);
    slTrainingInstallHelper.endInstallation();

start_simulink

end