classdef RegistryUtils




    methods(Static)
        function appdataDir=getAppdataDirName()





            hashSeed=strcat(hwconnectinstaller.util.getCurrentRelease(),matlabroot);
            mlrootTest=getenv('SUPPORTPACKAGE_INSTALLER_TEST_MATLABROOT');
            if~isempty(mlrootTest)
                hashSeed=mlrootTest;
            end
            mlrootHash=lower(hwconnectinstaller.util.getTrimmedHash(hashSeed,16));
            appdataDir=['appdata_',mlrootHash];
        end

        function savePath
            hwconnectinstaller.internal.inform('RegistryUtils.savePath');
            status=hwconnectinstaller.internal.safeSavePath();



            if(status==1)
                pathdefLoc=which('pathdef.m');
                if ispc
                    warning(message('hwconnectinstaller:installapi:UnableToSavePathWindows',pathdefLoc));
                else
                    warning(message('hwconnectinstaller:installapi:UnableToSavePathNonWindows',pathdefLoc));
                end
            end
        end


        function removeDirsFromPath(spPkg)




            hwconnectinstaller.internal.inform(sprintf('RegistryUtils.removeDirsFromPath for "%s"',spPkg.Name));
            st=warning('off','MATLAB:ClassInstanceExists');
            cleanupObj=onCleanup(@()warning(st));
            modifyPath('remove',spPkg.Path);
        end


        function addDirsToPath(spPkg)



            hwconnectinstaller.internal.inform(sprintf('RegistryUtils.addDirsToPath for "%s"',spPkg.Name));
            ensurePlatformAppropriatePath(spPkg);
            modifyPath('add',spPkg.Path);
        end


        function supportPkg=getRegistrationInfo(pkgname)





            supportPkg=[];
            spec=hwconnectinstaller.RegistryUtils.getInfoFcnSpec(pkgname);
            if exist(spec.infoFcnFullPath)==2
                supportPkg=hwconnectinstaller.RegistryUtils.getDecodedInfoSpec(spec.infoFcnScopedName);
            end
        end

        function supportPkg=getDecodedInfoSpec(filename)







            validateattributes(filename,{'char'},{'nonempty'},'getDecodedInfoSpec','filename');
            supportPkg=[];
            try
                supportPkg=feval(filename);
                supportPkg.InfoText=urldecode(supportPkg.InfoText);
                supportPkg.PreUninstallCmd=urldecode(supportPkg.PreUninstallCmd);
                for i=1:numel(supportPkg.TpPkg)
                    supportPkg.TpPkg(i).RemoveCmd=urldecode(supportPkg.TpPkg(i).RemoveCmd);
                end
            catch


                return;
            end
        end

        function spec=getInfoFcnSpec(pkgname)












            spec.infoFcnBaseName=[hwconnectinstaller.SupportPackage.getPkgTag(pkgname),'_info'];
            spec.infoFcnScopedName=['matlabshared.supportpkg.internal.pkginfo.',spec.infoFcnBaseName];
            spec.infoFcnFullPath=which(spec.infoFcnScopedName);
        end


        function s=getRegistrationDirs(s)












            validateattributes(s,{'struct'},{'nonempty'},'getRegistrationDirs','s');

            trimFileSeps=@(str)regexprep(str,[regexptranslate('escape',filesep),'*$'],'');

            if isfield(s,'installDir')
                s.installDir=trimFileSeps(s.installDir);
                s.appdataDir=fullfile(s.installDir,hwconnectinstaller.RegistryUtils.getAppdataDirName());
                s.infoFileDir=fullfile(s.appdataDir,'+matlabshared','+supportpkg','+internal','+pkginfo');
            elseif isfield(s,'infoFileDir')
                s.infoFileDir=trimFileSeps(s.infoFileDir);
                s.appdataDir=fileparts(fileparts(fileparts(fileparts(s.infoFileDir))));
                s.installDir=fileparts(s.appdataDir);
            elseif isfield(s,'appdataDir')
                s.appdataDir=trimFileSeps(s.appdataDir);
                s.installDir=fileparts(s.appdataDir);
                s.infoFileDir=fullfile(s.appdataDir,'+matlabshared','+supportpkg','+internal','+pkginfo');
            else
                assert(false,'hwconnectinstaller:getRegistrationDirs:invalidStruct',...
                'installDir, infoFileDir or appDataDir must be specified');
            end
        end


        function deleteInfoFcn(spPkg)















            validateattributes(spPkg,{'hwconnectinstaller.SupportPackage'},{'scalar'},'deleteInfoFcn','spPkg');
            hwconnectinstaller.internal.inform(sprintf('RegistryUtils.deleteInfoFcn for "%s"',spPkg.Name));


            spec=hwconnectinstaller.RegistryUtils.getInfoFcnSpec(spPkg.Name);
            infoFcnFullPath=spec.infoFcnFullPath;

            if isempty(infoFcnFullPath)



                if isempty(spPkg.InstallDir)

                    warning(message('hwconnectinstaller:installapi:UnableToFindInfoFile',spPkg.Name));
                    return;
                end

                regDirs=hwconnectinstaller.RegistryUtils.getRegistrationDirs(struct('installDir',spPkg.InstallDir));
                infoFcnFullPath=fullfile(regDirs.infoFileDir,[spec.infoFcnBaseName,'.m']);
            else
                regDirs=hwconnectinstaller.RegistryUtils.getRegistrationDirs(struct('infoFileDir',fileparts(infoFcnFullPath)));
            end

            if exist(infoFcnFullPath,'file')

                try
                    delete(infoFcnFullPath);
                catch ME
                    warning(message('hwconnectinstaller:installapi:UnableToDeleteFile',infoFcnFullPath,ME.message));
                end
            end


            infofiles=dir(fullfile(regDirs.infoFileDir,'*.m'));
            if isempty(infofiles)
                hwconnectinstaller.internal.inform(sprintf('deleteInfoFcn: %s is empty, cleaning up',regDirs.appdataDir));



                dirsOnPath=strsplit(path,pathsep);
                if any(strcmpi(regDirs.appdataDir,dirsOnPath))
                    rmpath(regDirs.appdataDir);
                end




                [success,errormsg]=rmdir(regDirs.appdataDir,'s');
                if~success
                    warning(message('hwconnectinstaller:installapi:UnableToDeleteDir',regDirs.appdataDir,errormsg));
                end
            end

        end

        function updateInfoFcn(spPkg,proxyInstallDir)















            validateattributes(spPkg,{'hwconnectinstaller.SupportPackage'},{'scalar'},'updateInfoFcn','spPkg');
            hwconnectinstaller.internal.inform(sprintf('RegistryUtils.updateInfoFcn for "%s"',spPkg.Name));

            if~exist('proxyInstallDir','var')
                installDir=spPkg.InstallDir;
            else
                validateattributes(proxyInstallDir,{'char'},{'nonempty'},'updateInfoFcn','proxyInstallDir');
                installDir=proxyInstallDir;
            end

            regDirs=hwconnectinstaller.RegistryUtils.getRegistrationDirs(struct('installDir',installDir));
            if~isdir(regDirs.infoFileDir)

                [success,errormsg]=mkdir(regDirs.infoFileDir);
                if~success
                    error(message('hwconnectinstaller:installapi:UnableToCreateDir',regDirs.infoFileDir,errormsg));
                end
            end

            spec=hwconnectinstaller.RegistryUtils.getInfoFcnSpec(spPkg.Name);
            infoFcnBaseName=spec.infoFcnBaseName;



            clear(infoFcnBaseName);
            infoFileName=fullfile(regDirs.infoFileDir,[infoFcnBaseName,'.m']);
            fid=fopen(infoFileName,'w');
            if(fid<0)
                error(message('hwconnectinstaller:installapi:FileOpenError',infoFileName));
            end
            c=onCleanup(@()fclose(fid));


            fprintf(fid,'function supportpkg = %s()\n',infoFcnBaseName);
            fprintf(fid,'%%%s Return %s information.\n',upper(infoFcnBaseName),spPkg.FullName);
            fprintf(fid,'\n');
            fprintf(fid,'%%   Copyright %s The MathWorks, Inc.\n',datestr(now,'yyyy'));
            fprintf(fid,'\n');
            fprintf(fid,'supportpkg = hwconnectinstaller.SupportPackage();\n');
            fprintf(fid,'supportpkg.Name          = ''%s'';\n',spPkg.Name);
            fprintf(fid,'supportpkg.Version       = ''%s'';\n',spPkg.Version);
            fprintf(fid,'supportpkg.Platform      = ''%s'';\n',spPkg.PlatformStr);
            fprintf(fid,'supportpkg.Visible       = ''%d'';\n',spPkg.Visible);
            fprintf(fid,'supportpkg.FwUpdate      = ''%s'';\n',spPkg.FwUpdate);
            fprintf(fid,'supportpkg.Url           = ''%s'';\n',spPkg.Url);
            fprintf(fid,'supportpkg.DownloadUrl   = ''%s'';\n',spPkg.DownloadUrl);
            fprintf(fid,'supportpkg.LicenseUrl    = ''%s'';\n',spPkg.LicenseUrl);
            fprintf(fid,'supportpkg.BaseProduct   = ''%s'';\n',spPkg.BaseProduct);
            fprintf(fid,'supportpkg.FwUpdateDisplayName = ''%s'';\n',spPkg.FwUpdateDisplayName);
            if spPkg.AllowDownloadWithoutInstall
                fprintf(fid,'supportpkg.AllowDownloadWithoutInstall = true;\n');
            else
                fprintf(fid,'supportpkg.AllowDownloadWithoutInstall = false;\n');
            end
            fprintf(fid,'supportpkg.FullName      = ''%s'';\n',spPkg.FullName);
            fprintf(fid,'supportpkg.DisplayName      = ''%s'';\n',spPkg.DisplayName);
            fprintf(fid,'supportpkg.SupportCategory      = ''%s'';\n',spPkg.SupportCategory);
            fprintf(fid,'supportpkg.CustomLicense = ''%s'';\n',spPkg.CustomLicense);
            fprintf(fid,'supportpkg.CustomLicenseNotes = ''%s'';\n',spPkg.CustomLicenseNotes);
            if spPkg.ShowSPLicense
                fprintf(fid,'supportpkg.ShowSPLicense = true;\n');
            else
                fprintf(fid,'supportpkg.ShowSPLicense = false;\n');
            end
            fprintf(fid,'supportpkg.Folder        = ''%s'';\n',spPkg.Folder);
            fprintf(fid,'supportpkg.Release       = ''%s'';\n',spPkg.Release);
            fprintf(fid,'supportpkg.DownloadDir   = ''%s'';\n',spPkg.DownloadDir);
            fprintf(fid,'supportpkg.InstallDir    = ''%s'';\n',spPkg.InstallDir);
            fprintf(fid,'supportpkg.IsDownloaded  = %d;\n',spPkg.IsDownloaded);
            fprintf(fid,'supportpkg.IsInstalled   = %d;\n',spPkg.IsInstalled);
            fprintf(fid,'supportpkg.RootDir       = ''%s'';\n',spPkg.RootDir);
            fprintf(fid,'supportpkg.DemoXml       = ''%s'';\n',spPkg.DemoXml);
            fprintf(fid,'supportpkg.ExtraInfoCheckBoxDescription       = ''%s'';\n',spPkg.ExtraInfoCheckBoxDescription);
            fprintf(fid,'supportpkg.ExtraInfoCheckBoxCmd       = ''%s'';\n',spPkg.ExtraInfoCheckBoxCmd);
            fprintf(fid,'supportpkg.FwUpdate      = ''%s'';\n',spPkg.FwUpdate);
            fprintf(fid,'supportpkg.PreUninstallCmd      = ''%s'';\n',urlencode(spPkg.PreUninstallCmd));
            fprintf(fid,'supportpkg.InfoUrl      = ''%s'';\n',spPkg.InfoUrl);

            fprintf(fid,'supportpkg.BaseCode     = ''%s'';\n',spPkg.BaseCode);
            fprintf(fid,'supportpkg.SupportTypeQualifier      = ''%s'';\n',spPkg.SupportTypeQualifier);
            fprintf(fid,'supportpkg.CustomMWLicenseFiles      = ''%s'';\n',spPkg.CustomMWLicenseFiles);
            fprintf(fid,'supportpkg.InstalledDate      = ''%s'';\n',spPkg.InstalledDate);
            fprintf(fid,'supportpkg.InfoText      = ''%s'';\n',urlencode(spPkg.InfoText));

            for i=1:length(spPkg.Parent)
                fprintf(fid,'supportpkg.Parent(%d).Name    = ''%s'';\n',i,spPkg.Parent(i).Name);
                fprintf(fid,'supportpkg.Parent(%d).Version = ''%s'';\n',i,spPkg.Parent(i).Version);
            end
            for i=1:length(spPkg.Children)
                fprintf(fid,'supportpkg.Children(%d).Name    = ''%s'';\n',i,spPkg.Children(i).Name);
                fprintf(fid,'supportpkg.Children(%d).Version = ''%s'';\n',i,spPkg.Children(i).Version);
            end

            for i=1:numel(spPkg.Path)

                fprintf(fid,'supportpkg.Path{%d}      = ''%s'';\n',i,...
                spPkg.Path{i});
            end


            fprintf(fid,'\n%% Third party software information\n');
            for i=1:numel(spPkg.TpPkg)
                fprintf(fid,'supportpkg.TpPkg(%d) = hwconnectinstaller.ThirdPartyPackage(''%s'', ''%s'');\n',...
                i,spPkg.TpPkg(i).Name,spPkg.TpPkg(i).Url);
                fprintf(fid,'supportpkg.TpPkg(%d).Url        = ''%s'';\n',...
                i,spPkg.TpPkg(i).Url);
                fprintf(fid,'supportpkg.TpPkg(%d).DownloadUrl = ''%s'';\n',...
                i,spPkg.TpPkg(i).DownloadUrl);
                fprintf(fid,'supportpkg.TpPkg(%d).LicenseUrl = ''%s'';\n',...
                i,spPkg.TpPkg(i).LicenseUrl);
                fprintf(fid,'supportpkg.TpPkg(%d).FileName = ''%s'';\n',...
                i,spPkg.TpPkg(i).FileName);
                fprintf(fid,'supportpkg.TpPkg(%d).DestDir = ''%s'';\n',...
                i,spPkg.TpPkg(i).DestDir);
                fprintf(fid,'supportpkg.TpPkg(%d).Installer = ''%s'';\n',...
                i,spPkg.TpPkg(i).Installer);
                fprintf(fid,'supportpkg.TpPkg(%d).Archive = ''%s'';\n',...
                i,spPkg.TpPkg(i).Archive);
                fprintf(fid,'supportpkg.TpPkg(%d).DownloadDir = ''%s'';\n',...
                i,spPkg.TpPkg(i).DownloadDir);
                fprintf(fid,'supportpkg.TpPkg(%d).InstallDir = ''%s'';\n',...
                i,spPkg.TpPkg(i).InstallDir);
                fprintf(fid,'supportpkg.TpPkg(%d).IsDownloaded = %d;\n',...
                i,spPkg.TpPkg(i).IsDownloaded);
                fprintf(fid,'supportpkg.TpPkg(%d).IsInstalled = %d;\n',...
                i,spPkg.TpPkg(i).IsInstalled);
                fprintf(fid,'supportpkg.TpPkg(%d).InstallCmd = '''';\n',i);

                fprintf(fid,'supportpkg.TpPkg(%d).RemoveCmd = ''%s'';\n',...
                i,urlencode(spPkg.TpPkg(i).RemoveCmd));
                fprintf(fid,'supportpkg.TpPkg(%d).RootDir = ''%s'';\n',...
                i,spPkg.TpPkg(i).RootDir);
                fprintf(fid,'supportpkg.TpPkg(%d).PreviouslyInstalled = %d;\n',...
                i,double(spPkg.TpPkg(i).PreviouslyInstalled));
            end




            addpath(regDirs.appdataDir);

        end

    end


end


function ensurePlatformAppropriatePath(spPkg)
    for i=1:numel(spPkg.Path)
        spPkg.Path{i}=fullfile(spPkg.Path{i});
    end
end


function modifyPath(action,dirList)
    validDirs={};












    switch lower(action)
    case 'add'
        for i=1:numel(dirList)
            if isdir(dirList{i})
                validDirs{end+1}=dirList{i};%#ok<AGROW>
            end
        end
        if isempty(validDirs)
            return;
        end
        addpath(validDirs{:});
    case 'remove'



        if isempty(dirList)
            return;
        end
        st=warning('off','MATLAB:rmpath:DirNotFound');
        cleanup=onCleanup(@()warning(st));
        rmpath(dirList{:});
    otherwise
        assert(false,'modifyPath: Invalid action');
    end



    rehash pathreset;
end
