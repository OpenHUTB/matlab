function fileName=makeFileNameUnique(fileName,reservedNames)





    if nargin<2
        reservedNames={};
    end

    if exist(fileName,'file')||~isempty(reservedNames)
        [fpath,fname,fext]=fileparts(fileName);
        allFiles=dir(fullfile(fpath,[fname,'*',fext]));
        allNames=[reservedNames,cellfun(@i_getFilename,{allFiles(:).name},'UniformOutput',false)];
        fname=matlab.lang.makeValidName(matlab.lang.makeUniqueStrings(fname,allNames));
        fileName=fullfile(fpath,[fname,fext]);
    end

    function fname=i_getFilename(fileName)

        [~,fname]=fileparts(fileName);
