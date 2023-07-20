function toolstripNewButtonCB(this)







    cancelled=this.askToSaveSession();
    if cancelled,return;end




    [filename,pathname]=uigetfile(...
    {'*.mldatx','SLRT Application files';...
    '*.mdl;*.slx',getString(message('MATLAB:uistring:uiopen:ModelFiles'))},...
    this.SelectAppFile_msg);



    this.bringToFront();



    if~isequal(filename,0)&&~isequal(pathname,0)





        fullpath=fullfile(pathname,filename);
        this.newSession(fullpath);











        this.addToRecentMLDATXFiles(filename,fullpath);
    end
end
