function[htmlCacheDir,resourceDir]=resourceCachePaths(label)











    htmlFileDir=fullfile(tempdir,'RMI',label);
    if exist(htmlFileDir,'dir')~=7
        mkdir(htmlFileDir);
    end

    htmlCacheDir=strrep(htmlFileDir,filesep,'/');

    if exist(htmlCacheDir,'dir')~=7
        mkdir(htmlCacheDir);
    end

    usrTempDir=slreq.opc.getUsrTempDir();

    resourcePart='SLREQ_RESOURCE';

    resourceDir=strrep(htmlCacheDir,usrTempDir,resourcePart);

end
