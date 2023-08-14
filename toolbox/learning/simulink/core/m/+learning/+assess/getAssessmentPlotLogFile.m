function logFile=getAssessmentPlotLogFile()



    folderPath=fullfile(tempdir,'SimulinkTraining');
    if~exist(folderPath,'dir')
        mkdir(folderPath);
    end
    logFile=fullfile(folderPath,'userLog.mat');
end

