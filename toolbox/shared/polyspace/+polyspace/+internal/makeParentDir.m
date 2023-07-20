

function makeParentDir(filePath)
    if~isempty(filePath)
        fileDir=fileparts(filePath);
        if~isempty(fileDir)&&~exist(fileDir,'dir')
            mkdir(fileDir);
        end
    end
