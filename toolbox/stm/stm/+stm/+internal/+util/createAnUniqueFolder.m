function[bSuccess,returnPath]=createAnUniqueFolder(parentPath,folderName)









    tmpFolderName=folderName;
    idx=1;
    while(1)
        returnPath=fullfile(parentPath,tmpFolderName);
        if(exist(returnPath,'dir')>0)
            tmpFolderName=[folderName,num2str(idx)];
            idx=idx+1;
        else
            break;
        end
    end
    bSuccess=stm.internal.report.createPath(returnPath);
end
