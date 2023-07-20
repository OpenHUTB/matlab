function fileInfo=getFileInfo(fileName)





    fileInfo.fullFilePath=fileName;
    fileInfo.shortFilePath=fileName;
    resolvedFilePath=which(fileName);
    if(~isempty(resolvedFilePath))
        fileInfo.fullFilePath=resolvedFilePath;
    end
    fparts=strfind(fileName,filesep);
    if(~isempty(fparts))
        pathnameCmp=extractBefore(fileName,fparts(end));
        shortFileName=extractAfter(fileInfo.fullFilePath,fparts(end));
        currentdir=pwd;
        if strcmp(pathnameCmp,currentdir)||~isempty(strfind(path,pathnameCmp))
            fileInfo.shortFilePath=shortFileName;
        end
    end
end