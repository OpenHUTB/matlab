function toolstripNewRecentFileCB(this,fileName,fileFullPath)









    cancelled=this.askToSaveSession();
    if cancelled,return;end




    this.newSession(fileFullPath);



    this.addToRecentMLDATXFiles(fileName,fileFullPath);
end
