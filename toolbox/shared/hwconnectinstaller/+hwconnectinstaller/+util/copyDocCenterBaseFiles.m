function copyDocCenterBaseFiles(pkgName,installDir)





    try
        pkgTag=hwconnectinstaller.SupportPackage.getPkgTag(pkgName);
        installRoot=fullfile(installDir,pkgTag);
        sppkgHasDoc=exist(fullfile(installRoot,'help'),'dir')==7;
        if sppkgHasDoc
            copyIfDestDoesNotExist(installRoot,fullfile('help','includes'));
            copyIfDestDoesNotExist(installRoot,fullfile('help','templates'));
        end;
    catch ex
        throwAsCaller(ex);
    end
end


function copyIfDestDoesNotExist(installRoot,pathToCopy)


    if exist(fullfile(installRoot,pathToCopy),'dir')~=7
        [succ,msg,msgid]=copyfile(fullfile(matlabroot,pathToCopy),fullfile(installRoot,pathToCopy),'f');
        if~succ
            error(msgid,msg);
        end
    end
end
