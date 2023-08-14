




function createDefaultScriptedTestFile(path)

    defaultScriptedFile=fullfile(matlabroot,'toolbox','stm','stm','+sltest',...
    '+internal','DefaultScriptedTestFile.m');

    copyfile(defaultScriptedFile,path);

    [~,fileName,~]=fileparts(path);

    defaultContent=fileread(path);
    newContent=replace(defaultContent,'DefaultScriptedTestFile',fileName);
    newContent=extractBetween(newContent,'classdef',length(newContent),'Boundaries','inclusive');
    newContent=[newContent{:}];

    fileattrib(path,'+w');
    fid=fopen(path,'w');
    fwrite(fid,newContent);
    fclose(fid);


    matlab.desktop.editor.openDocument(path);
end

