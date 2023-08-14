function isWritable=fileIsWritable(fileFullPath)




    isWritable=true;
    if exist(fileFullPath,'file')
        [~,fileInfo]=fileattrib(fileFullPath);
        isWritable=fileInfo.UserWrite;
        return
    end
end
