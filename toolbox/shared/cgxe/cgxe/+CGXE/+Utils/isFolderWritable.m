function isWritable=isFolderWritable(dirPath)






    tempDirName=fullfile(dirPath,['slccTempDir_',datestr(datetime('now'),'yymmddHHMMSS')]);
    if~mkdir(tempDirName)
        isWritable=false;
    else
        rmdir(tempDirName);
        isWritable=true;
    end
end