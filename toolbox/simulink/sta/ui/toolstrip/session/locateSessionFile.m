function fileNameToUse=locateSessionFile(fileName,fullFileName)


    if exist(fullFileName,'file')


        fileNameToUse=fullFileName;


    elseif exist(fileName,'file')


        fileNameToUse=fileName;

    else


        throw(...
        MException(message('sl_sta_repository:sta_repository:scenarioDataFileNotFound',...
        fileName,fileName,fullFileName))...
        );
    end