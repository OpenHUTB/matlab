function tempfile=resaveOldVersionTestFileToCurrentVersion(oldFilePath,tempfolder)



    [~,filename,ext]=fileparts(oldFilePath);
    tempfolder=tempname(tempfolder);
    mkdir(tempfolder)
    file_copy=fullfile(tempfolder,['copy_',filename,ext]);
    tempfile=fullfile(tempfolder,[filename,ext]);
    copyfile(oldFilePath,file_copy);

    tf=sltest.testmanager.load(file_copy);
    tf.saveToFile(tempfile);
    tf.close;
    stm.internal.removeTestFileFromRecentHistory(tempfile);
    stm.internal.removeTestFileFromRecentHistory(file_copy);
end
