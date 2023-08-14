



function[nameIsAvailable,invalidNameError]=export(filenames,...
    exportName,exportType,forceOverwrite)
    import stm.internal.Coverage;
    import stm.internal.Export;

    nameIsAvailable=true;
    invalidNameError=false;
    if exportType==Coverage.EXPORT_BASE_WORKSPACE
        [nameIsAvailable,invalidNameError]=Export.isVarNameAvailable(exportName,forceOverwrite);
        if nameIsAvailable
            cvResults=Coverage.filenamesToCvDataArray(filenames,[]);
            assignin('base',exportName,cvResults);
        end
    elseif exportType==Coverage.EXPORT_FILE
        if~forceOverwrite
            fullFilePath=Export.getFullFilePath(exportName,'.cvt');
            nameIsAvailable=~isfile(fullFilePath);
        end

        if nameIsAvailable
            cvResults=Coverage.filenamesToCvDataArray(filenames,[]);
            cvGroup=cv.cvdatagroup(cvResults);
            try
                cvsave(exportName,cvGroup);
            catch
                invalidNameError=true;
                nameIsAvailable=false;
            end
        end
    end
end
