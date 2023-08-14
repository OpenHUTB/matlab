function WorkDir=getWorkDir(mdlName,action)





    WorkDir='';

    fileGenCfg=Simulink.fileGenControl('getConfig');
    rootBDir=fileGenCfg.CodeGenFolder;




    coder.internal.folders.MarkerFile.checkSlprjDirectory(rootBDir,true);




    switch action
    case 'check'
        WorkDir=fullfile(rootBDir,'slprj','slci',mdlName);
    case 'create'
        WorkDir=rtwprivate('rtw_create_directory_path',rootBDir,'slprj','slci',mdlName);
    otherwise
        assert(false,'should not be here')
    end
end


