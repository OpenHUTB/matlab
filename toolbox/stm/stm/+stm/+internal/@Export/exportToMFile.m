

function[fileNameIsAvailable,invalidNameError,errorMessage]=exportToMFile(fileName,valuesStruct,forceOverwrite)

    [fileNameIsAvailable,invalidNameError,errorMessage]=...
    stm.internal.Export.exportToFileHelper(2,fileName,valuesStruct,forceOverwrite,[],[],[]);
end
