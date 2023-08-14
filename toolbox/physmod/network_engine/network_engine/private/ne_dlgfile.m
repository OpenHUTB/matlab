function dlgFile=ne_dlgfile(sourceFile)




    DLGEXT='.pmdlg';
    [fileDir,fileBase]=ne_gendir(sourceFile);
    dlgFile=fullfile(fileDir,[fileBase,DLGEXT]);

end

