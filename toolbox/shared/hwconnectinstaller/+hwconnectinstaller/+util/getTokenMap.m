function tokenMap=getTokenMap(pkg)


    tokenMap=containers.Map();
    tokenMap('&quot;')='"';
    tokenMap('\$\(INSTALLDIR\)')=i_decoratePath(pkg.InstallDir);
    tokenMap('\$\(DOWNLOADDIR\)')=i_decoratePath(pkg.DownloadDir);
    tokenMap('\$\(ROOTDIR\)')=i_decoratePath(pkg.RootDir);
    tokenMap('\$\(FILESEP\)')=filesep;
    if(isa(pkg,'hwconnectinstaller.ThirdPartyPackage'))
        tokenMap('\$\(INSTALLER\)')=i_decoratePath(pkg.Installer);
        tokenMap('\$\(ARCHIVE\)')=i_decoratePath(pkg.Archive);
        tokenMap('\$\(DESTDIR\)')=i_decoratePath(pkg.DestDir);
    end
end



function pathstr=i_decoratePath(pathstr,doubleQuotes)


    if(nargin<2)
        doubleQuotes=false;
    end
    pathstr=strrep(pathstr,'\','\\');

    if(doubleQuotes)
        pathstr=hwconnectinstaller.PackageInstaller.doubleQuotes(pathstr);
    end
end
