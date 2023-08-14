function aDir=getOrCreateDir(aDir)





    rtw_checkdir();

    if~polyspace.internal.isAbsolutePath(aDir)
        aDir=fullfile(pwd,aDir);
    end
    aDir=polyspace.internal.getAbsolutePath(aDir);



    aDir=rtwprivate('rtw_create_directory_path',aDir,'');
