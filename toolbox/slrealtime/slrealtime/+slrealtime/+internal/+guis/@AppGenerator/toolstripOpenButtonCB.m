function toolstripOpenButtonCB(this)









    cancelled=this.askToSaveSession();
    if cancelled,return;end



    [filename,pathname]=uigetfile(...
    {'*.mat','MAT-files (*.mat)'},...
    this.SelectSavedSessionFile_msg);



    this.bringToFront();



    if~isequal(filename,0)&&~isequal(pathname,0)





        fullpath=fullfile(pathname,filename);
        this.openSession(fullpath);











        this.addToRecentSessionFiles(filename,fullpath);
    end
end
