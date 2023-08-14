function out=getReferencingDDFile(ddFile)





    out='';
    allFilePaths=Simulink.data.dictionary.getOpenDictionaryPaths;
    ddFileObj=slreq.uri.FilePathHelper(ddFile);
    targetFilePath=ddFileObj.getShortName();
    for index=1:length(allFilePaths)
        cFilePath=allFilePaths{index};
        dictObj=Simulink.data.dictionary.open(cFilePath);
        allDataSources=dictObj.DataSources();
        if ismember(targetFilePath,allDataSources)
            out=cFilePath;
            return;
        end

    end

end
