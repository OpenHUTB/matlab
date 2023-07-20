function cloneResults=detectClonesAcrossMultipleModels()











    project=currentProject;

    cloneDetectionSettings=Simulink.CloneDetection.Settings();
    cloneDetectionSettings.Folders=project.RootFolder;

    cd("work");
    cloneDetectionDir='Clone_Detection_Temp';
    if~exist(fullfile(pwd,cloneDetectionDir),'dir')
        mkdir(cloneDetectionDir);
    end

    cd(cloneDetectionDir);

    cloneResults=Simulink.CloneDetection.findClones(cloneDetectionSettings);
    Simulink.CloneDetection.highlightClone(cloneResults,'AnalogControl/Saturation Detection');
end
