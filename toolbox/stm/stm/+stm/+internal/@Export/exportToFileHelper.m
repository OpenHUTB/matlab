

function[fileNameIsAvailable,invalidNameError,errorMessage]=...
    exportToFileHelper(fileType,fileName,valuesStruct,forceOverwrite,activeApp,runIDs,signalIDs)

    import stm.internal.Export;
    fileNameIsAvailable=true;
    invalidNameError=false;
    errorMessage='';

    if~forceOverwrite
        fullFilePath=Export.getFullFilePath(fileName,'.mat');
        if isfile(fullFilePath)
            fileNameIsAvailable=false;
            return;
        end
    end

    try
        if isempty(runIDs)&&isempty(signalIDs)
            if fileType==1

                data=stm.internal.Export.convertStructToVariableArray(valuesStruct);
                save(fileName,'data');
            elseif fileType==2

                helperSaveToMFile(fileName,valuesStruct);
            end
        else
            engine=Simulink.sdi.Instance.engine;
            engine.exportToMatFile(runIDs,signalIDs,activeApp,'data',fileName);
        end
    catch me
        fileNameIsAvailable=false;
        invalidNameError=true;
        errorMessage=me.message;
    end
end

function helperSaveToMFile(fileName,valuesStruct)
    for i=1:length(valuesStruct)
        eval([valuesStruct(i).Variable,'= valuesStruct(i).RuntimeValue;']);
    end
    matlab.io.saveVariablesToScript(fileName,{valuesStruct.Variable});
end
