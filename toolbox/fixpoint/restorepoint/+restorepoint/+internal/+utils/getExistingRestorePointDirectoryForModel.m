function restorePath=getExistingRestorePointDirectoryForModel(model)




    restorePath='';

    fullRestoreDir=restorepoint.internal.utils.getCurrentRestoreDir;

    filelist=dir(fullRestoreDir);
    filelist=struct2cell(filelist);
    folders=filelist(1,:);
    currentSessionId=restorepoint.internal.utils.SessionInformationManager.getSessionIdentifier;
    currentNodeName=currentSessionId.NodeName;
    [currentFileName,currentDir]=restorepoint.internal.utils.getFilePathForModel(model);

    for folderIdx=1:length(folders)
        restoreDataFile=fullfile(fullRestoreDir,folders{folderIdx},'restoreData.mat');
        if exist(restoreDataFile,'file')==2
            restoreData=importdata(restoreDataFile);

            if(eq(restoreData.SessionID,currentSessionId))&&...
                (isequal(restoreData.ModelDir,currentDir))&&...
                (isequal(restoreData.FileName,currentFileName)&&...
                isequal(restoreData.NodeName,currentNodeName))
                restorePath=fullfile(fullRestoreDir,folders{folderIdx});
            end
        end
    end
end


