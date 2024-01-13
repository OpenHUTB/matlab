function fileName=makeFileNameUnique(fileName)

    if exist(fileName,'file')
        [fpath,fname,fext]=fileparts(fileName);
        allFiles=dir(fullfile(fpath,[fname,'*',fext]));
        allNames=cellfun(@nFilename,{allFiles(:).name},'UniformOutput',false);
        fname=matlab.lang.makeValidName(matlab.lang.makeUniqueStrings(fname,allNames));
        fileName=fullfile(fpath,[fname,fext]);
    end

    function fname=nFilename(fileName)
        [~,fname]=fileparts(fileName);
    end

end

