function fileList=updateDataDictionaryLoadedFileList()


    openDictionaries=Simulink.data.dictionary.getOpenDictionaryPaths();
    [fileNames,connections]=cellfun(@(x)isAccessible(x),openDictionaries,'UniformOutput',false);
    inaccessibleIndex=cellfun(@isempty,connections);
    dirtyFlags=cellfun(@(x)x.HasUnsavedChanges,connections(~inaccessibleIndex),'UniformOutput',false);
    fileList=horzcat(fileNames(~inaccessibleIndex),openDictionaries(~inaccessibleIndex),dirtyFlags);

    if isempty(fileList)
        fileList=cell(0,3);
    end
end

function[fileName,connection]=isAccessible(path)
    [~,fileName,~]=fileparts(path);
    try
        connection=Simulink.data.dictionary.open(path);
    catch
        connection=[];
    end
end
