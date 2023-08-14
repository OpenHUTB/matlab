function toolstripOpenRecentFileCB(this,fileName,fileFullPath)









    cancelled=this.askToSaveSession();
    if cancelled,return;end





    this.openSession(fileFullPath);



    this.addToRecentSessionFiles(fileName,fileFullPath);
end

