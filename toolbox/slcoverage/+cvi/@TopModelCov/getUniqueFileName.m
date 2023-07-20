function fileName=getUniqueFileName(dirName,fileName)



    [~,fileName]=fileparts(fileName);
    allFiles=dir(fullfile(dirName,append(fileName,'*')));
    allNames={};
    for idx=1:numel(allFiles)
        [~,fN,~]=fileparts(allFiles(idx).name);
        allNames=[allNames,{fN}];%#ok<AGROW> 
    end

    fileName=matlab.lang.makeUniqueStrings(fileName,allNames);
