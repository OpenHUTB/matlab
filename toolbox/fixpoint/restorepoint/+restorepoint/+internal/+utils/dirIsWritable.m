function isWritable=dirIsWritable(fileFullPath)




    isWritable=true;
    [fileDir,~,~]=fileparts(fileFullPath);
    if exist(fileDir,'dir')

        [~,folderInfo]=fileattrib(fileparts(fileFullPath));
        isWritable=folderInfo.UserWrite;
        return
    end
end
