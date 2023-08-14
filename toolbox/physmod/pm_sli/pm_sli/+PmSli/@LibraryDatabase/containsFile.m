function[contains,libEntry]=containsFile(hObj,fileName)





    if~iscell(fileName)
        fileName={fileName};
    end


    fileDirs=fileparts(regexp(fileName,'[^\+]+','match','once'));
    if~iscell(fileDirs)
        fileDirs={fileDirs};
    end


    [contains,iEntry]=ismember(fileDirs,hObj.Directories);


    libEntry=cell(1,numel(fileName));
    libEntry(contains)=num2cell(hObj.Array(iEntry(contains)));

end
