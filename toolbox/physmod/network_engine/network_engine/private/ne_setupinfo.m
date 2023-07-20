function ne_setupinfo(sourceFile,info)











    info.clear;




    info.SourceFile=sourceFile;




    info.Path=ne_filetopackagefunction(sourceFile);




    fileAttr=dir(info.SourceFile);
    info.SrcModTime=datestr(fileAttr.datenum,30);


    info.DlgFile=ne_dlgfile(sourceFile);
    info.GuiFile=lGuiFile(sourceFile);




    [fileDir,fileName]=fileparts(info.SourceFile);
    pFile=fullfile(fileDir,[fileName,'.p']);
    if exist(pFile,'file')
        info.SourceFile=pFile;
    else
        mFile=fullfile(fileDir,[fileName,'.m']);
        if exist(mFile,'file');
            info.SourceFile=mFile;
        end
    end

end

function guiFile=lGuiFile(srcFile)

    GUIDIR='gui';

    GUISUFFIX='';
    GUIEXT='.m';
    [fileDir,fileBase]=fileparts(srcFile);
    guiFile=fullfile(fileDir,GUIDIR,[fileBase,GUISUFFIX,GUIEXT]);
end

