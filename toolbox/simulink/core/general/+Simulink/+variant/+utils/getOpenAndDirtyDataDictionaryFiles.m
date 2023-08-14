
function[openDataDictionaryFiles,dirtyDataDictionaryFiles]=getOpenAndDirtyDataDictionaryFiles()




    openDataDictionaryFiles=Simulink.data.dictionary.getOpenDictionaryPaths();

    if nargout==1
        return;
    end

    dirtyDataDictionaryFiles={};
    for i=1:numel(openDataDictionaryFiles)
        dataDictionary=openDataDictionaryFiles{i};
        try %#ok<TRYNC>


            ddObj=Simulink.data.dictionary.open(dataDictionary);
            if ddObj.HasUnsavedChanges
                dirtyDataDictionaryFiles=[dirtyDataDictionaryFiles;dataDictionary];%#ok<AGROW>
            end
            ddObj.close();
        end
    end
end
