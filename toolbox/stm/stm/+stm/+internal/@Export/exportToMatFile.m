

function[fileNameIsAvailable,invalidNameError,errorMessage]=...
    exportToMatFile(fileName,valuesStruct,forceOverwrite,activeApp,runIDs,signalIDs)


    [fileNameIsAvailable,invalidNameError,errorMessage]=...
    stm.internal.Export.exportToFileHelper(1,fileName,valuesStruct,forceOverwrite,activeApp,runIDs,signalIDs);
end
