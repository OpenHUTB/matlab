function dataCleaner























    persistent dataCleanerInstance;
    if isempty(dataCleanerInstance)||~isvalid(dataCleanerInstance)
        [dataCleanerInstance]=matlab.internal.preprocessingApp.PreprocessingApp;
    else
        dataCleanerInstance.AppContainer.bringToFront;
    end

    mlock;
end
