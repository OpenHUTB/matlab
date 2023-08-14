function supportPkg=getRegistrationInfo(targetsDir,folder,thirdPartyInstallDir)














    hPkgInfo=hwconnectinstaller.ArchiveHandler.getInstance();


    xmlFilesLoc=fullfile(targetsDir,folder,'registry');
    opts.populateRootDir=false;
    supportPkg=hPkgInfo.loadSpPkgInfo(fullfile(xmlFilesLoc,'support_package_registry.xml'),opts);

    supportPkg.Release=hwconnectinstaller.util.getCurrentRelease();
    supportPkg.DownloadDir='';
    supportPkg.InstallDir=targetsDir;
    supportPkg.Folder=folder;
    supportPkg.RootDir=fullfile(targetsDir,folder);
    supportPkg.IsDownloaded=false;
    supportPkg.IsInstalled=false;
    supportPkg.Path=getFullPaths(supportPkg,fullfile(xmlFilesLoc,'support_package_registry.xml'));


    if nargin>2

        if~isempty(thirdPartyInstallDir)
            validateattributes(thirdPartyInstallDir,{'char','cell'},{'nonempty'},'getRegistrationInfo','thirdPartyInstallDir')
            supportPkg.TpPkg=hPkgInfo.loadTpPkgInfo(fullfile(xmlFilesLoc,'thirdparty_package_registry.xml'));
            thirdPartyInstallDir=cellstr(thirdPartyInstallDir);
            if numel(thirdPartyInstallDir)>1||(numel(thirdPartyInstallDir)==numel(supportPkg.TpPkg))
                assert(numel(thirdPartyInstallDir)==numel(supportPkg.TpPkg));

                for i=1:numel(supportPkg.TpPkg)
                    supportPkg.TpPkg(i).DownloadDir=thirdPartyInstallDir{i};
                    supportPkg.TpPkg(i).InstallDir=thirdPartyInstallDir{i};
                    supportPkg.TpPkg(i).IsDownloaded=false;
                    supportPkg.TpPkg(i).IsInstalled=false;
                    supportPkg.TpPkg(i).RootDir=thirdPartyInstallDir{i};
                end
            elseif numel(thirdPartyInstallDir)==1

                for i=1:numel(supportPkg.TpPkg)
                    supportPkg.TpPkg(i).DownloadDir=thirdPartyInstallDir{1};
                    supportPkg.TpPkg(i).InstallDir=thirdPartyInstallDir{1};
                    supportPkg.TpPkg(i).IsDownloaded=false;
                    supportPkg.TpPkg(i).IsInstalled=false;
                    supportPkg.TpPkg(i).RootDir=fullfile(thirdPartyInstallDir{1},supportPkg.TpPkg(i).DestDir);
                end
            end
        end
    end

end



function SupportPkgPath=getFullPaths(spPkg,sppkgxml)
    domNode=parseFile(matlab.io.xml.dom.Parser,sppkgxml);
    pkgrepository=domNode.getDocumentElement();
    currpkg=pkgrepository.getElementsByTagName('SupportPackage');

    tmp=currpkg.item(0).getElementsByTagName('Path');
    SupportPkgPath={};
    for i=0:tmp.getLength-1
        SupportPkgPath{i+1}=char(tmp.item(i).getAttribute('name'));
    end

    for i=1:numel(SupportPkgPath)
        SupportPkgPath{i}=regexprep(SupportPkgPath{i},'\$\(INSTALLDIR\)',...
        hwconnectinstaller.PackageInstaller.decoratePath(spPkg.InstallDir));
        SupportPkgPath{i}=regexprep(SupportPkgPath{i},'\$\(FOLDER\)',...
        spPkg.Folder);
        SupportPkgPath{i}=regexprep(SupportPkgPath{i},'\$\(FILESEP\)',...
        filesep);
        SupportPkgPath{i}=regexprep(SupportPkgPath{i},'\$\(ARCH\)',...
        computer('arch'));
        hdir=hwconnectinstaller.util.Location(SupportPkgPath{i});
        if(hdir.exists)
            SupportPkgPath{i}=fullfile(SupportPkgPath{i});%#ok<*AGROW>
        end
    end
end