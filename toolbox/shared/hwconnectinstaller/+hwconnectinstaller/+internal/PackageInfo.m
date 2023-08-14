classdef PackageInfo<handle






    properties(GetAccess=protected,Constant,Hidden)
        LASTDOWNLOADFOLDER='lastdownloadfolder';
        LASTPKGINSTALLED='lastpkginstalled';
    end
    properties(Constant,Hidden)
        GROUP='Hardware_Connectivity_Installer';
    end

    properties(Constant)
        APIVERSION='1.0';
    end

    methods(Access=public)

        function h=PackageInfo
        end


        function spPkg=getInstalledPackages(obj,~)









            spPkg=obj.getAllPackagesOnPath();
        end


    end

    methods(Static,Access=public)
        function rootDir=getTpPkgRootDir(tpPkgName,spPkg)












            if isempty(spPkg)
                error(message('hwconnectinstaller:setup:EmptySupportPackage'));
            end
            rootDir='';
            for i=1:numel(spPkg.TpPkg)
                if strcmp(tpPkgName,spPkg.TpPkg(i).Name)
                    rootDir=spPkg.TpPkg(i).RootDir;
                    break;
                end
            end
        end


        function supportPkg=getSpPkgInfo(name,options)















            if~exist('options','var')
                options=struct();
            end
            validateattributes(name,{'char'},{'nonempty'},'getSpPkgInfo','name');
            validateattributes(options,{'struct'},{},'getSpPkgInfo','options');

            if~isfield(options,'missingInfoAction')
                options.missingInfoAction='none';
            end

            supportPkg=hwconnectinstaller.RegistryUtils.getRegistrationInfo(name);
            if isempty(supportPkg)
                switch options.missingInfoAction
                case 'error'
                    error(message('hwconnectinstaller:installapi:UnableToFindSupportPackageInfo',name));
                case 'warning'
                    warning(message('hwconnectinstaller:installapi:UnableToFindSupportPackageInfo',name));
                otherwise

                end
            end
        end

    end

    methods(Hidden,Access=public)


        function pkgList=getAllPackagesOnPath(~)
            pkgList=hwconnectinstaller.SupportPackage.empty;



            rehash pathreset;
            metaObj=meta.package.fromName('matlabshared.supportpkg.internal.pkginfo');
            for p=1:numel(metaObj)
                for i=1:numel(metaObj(p).FunctionList)
                    infoFcnScopedName=[metaObj(p).Name,'.',metaObj(p).FunctionList(i).Name];
                    try
                        pkgList(end+1)=hwconnectinstaller.RegistryUtils.getDecodedInfoSpec(infoFcnScopedName);%#ok<AGROW>
                    catch


                    end
                end
            end
        end


        function[status,pkgInfo]=getPackageRegistrationStatus(obj,pkgName)
            pkgInfo=obj.getSpPkgInfo(pkgName);
            status.PkgIsOnPath=~isempty(pkgInfo);
        end

    end



    methods(Access=protected)

    end


    methods(Static,Hidden)
        function TpPkg=readTpPkgRegistry(tppkgxml,options)
            TpPkg=hwconnectinstaller.ThirdPartyPackage.empty;
            if isempty(tppkgxml)||(ischar(tppkgxml)&&~exist(tppkgxml,'file'))
                return;
            end

            domNode=parseFile(matlab.io.xml.dom.Parser,tppkgxml);
            pkgrepository=domNode.getDocumentElement();
            packages=pkgrepository.getElementsByTagName('ThirdPartyPackage');
            thisPlatform=hwconnectinstaller.util.getCurrentPlatform();

            tpPkgCnt=0;
            for i=0:packages.getLength-1
                currpkg=packages.item(i);
                currPkgName=char(currpkg.getAttribute('name'));


























                platformNodes=currpkg.getElementsByTagName('Platform');
                if platformNodes.getLength==0
                    error(message('hwconnectinstaller:setup:NeedPlatformInThirdPartyRegistry',currPkgName,tppkgxml));
                end

                currplatform=[];
                supportedPlatforms={};
                for k=0:platformNodes.getLength-1

                    platformNames=char(platformNodes.item(k).getAttribute('name'));

                    matchStatus=hwconnectinstaller.util.matchPlatformStr(thisPlatform,platformNames);
                    if matchStatus<0


                        error(message('hwconnectinstaller:setup:InvalidPlatformInThirdPartyRegistry',...
                        currPkgName,tppkgxml));
                    end

                    supportedPlatforms=[supportedPlatforms,strsplit(platformNames,',')];%#ok<AGROW>

                    if options.currentPlatformOnly&&matchStatus>0
                        currplatform=platformNodes.item(k);
                        break;
                    end
                end

                if isempty(currplatform)
                    if options.currentPlatformOnly

                        continue;
                    else



                        assert(~isempty(supportedPlatforms));


                        currplatform=platformNodes.item(k);
                    end
                end


                if options.currentPlatformOnly&&isempty(currplatform)

                    continue;
                elseif~isempty(supportedPlatforms)&&isempty(currplatform)


                    currplatform=platformNodes.item(k);
                end

                tpPkgCnt=tpPkgCnt+1;
                TpPkg(tpPkgCnt)=hwconnectinstaller.ThirdPartyPackage(...
                char(currpkg.getAttribute('name')),...
                char(currpkg.getAttribute('url')));

                TpPkg(tpPkgCnt).DownloadUrl=char(currplatform.getAttribute('downloadurl'));
                TpPkg(tpPkgCnt).FileName=char(currplatform.getAttribute('filename'));
                TpPkg(tpPkgCnt).DestDir=char(currplatform.getAttribute('destdir'));
                TpPkg(tpPkgCnt).Installer=char(currplatform.getAttribute('installer'));
                TpPkg(tpPkgCnt).Archive=char(currplatform.getAttribute('archive'));
                TpPkg(tpPkgCnt).InstallCmd=char(currplatform.getAttribute('installcmd'));

                if(~isempty(char(currplatform.getAttribute('predownloadcmd'))))
                    TpPkg(tpPkgCnt).PreDownloadCmd=char(currplatform.getAttribute('predownloadcmd'));
                end

                if(~isempty(char(currplatform.getAttribute('instructionset'))))
                    TpPkg(tpPkgCnt).InstructionSet=char(currplatform.getAttribute('instructionset'));
                end

                if(~isempty(char(currplatform.getAttribute('downloadcmd'))))
                    TpPkg(tpPkgCnt).DownloadCmd=char(currplatform.getAttribute('downloadcmd'));
                    if~(isempty(TpPkg(tpPkgCnt).DownloadUrl))
                        error(message('hwconnectinstaller:setup:NoDownloadUrlforDownloadCmd',TpPkg(tpPkgCnt).FileName,rootDir));
                    end
                end
                TpPkg(tpPkgCnt).RemoveCmd=char(currplatform.getAttribute('removecmd'));
                TpPkg(tpPkgCnt).LicenseUrl=char(currplatform.getAttribute('licenseurl'));

                if options.currentPlatformOnly
                    TpPkg(tpPkgCnt).PlatformStr=upper(thisPlatform);
                else
                    TpPkg(tpPkgCnt).PlatformStr=strjoin(unique(upper(supportedPlatforms)),',');
                end

            end
        end


        function spPkg=readSpPkgRegistry(sppkgxml,options)

            if(ischar(sppkgxml)&&~exist(sppkgxml,'file'))
                error(message('hwconnectinstaller:setup:UnsupportedSupportPackageFormat'));
            end
            spPkg=hwconnectinstaller.SupportPackage;
            domNode=parseFile(matlab.io.xml.dom.Parser,sppkgxml);
            pkgrepository=domNode.getDocumentElement();
            currpkg=pkgrepository.getElementsByTagName('SupportPackage');
            spPkg.Name=char(currpkg.item(0).getAttribute('name'));
            spPkg.Version=char(currpkg.item(0).getAttribute('version'));
            spPkg.Platform=char(currpkg.item(0).getAttribute('platform'));
            spPkg.Visible=char(currpkg.item(0).getAttribute('visible'));
            spPkg.Enable=char(currpkg.item(0).getAttribute('enable'));
            spPkg.Url=char(currpkg.item(0).getAttribute('url'));
            spPkg.DownloadUrl=char(currpkg.item(0).getAttribute('downloadurl'));
            spPkg.LicenseUrl=char(currpkg.item(0).getAttribute('licenseurl'));
            spPkg.Folder=char(currpkg.item(0).getAttribute('folder'));
            spPkg.FwUpdate=char(currpkg.item(0).getAttribute('firmwareupdate'));
            spPkg.DemoXml=char(currpkg.item(0).getAttribute('demoxml'));
            spPkg.ExtraInfoCheckBoxDescription=char(currpkg.item(0).getAttribute('extrainfocheckboxdescription'));
            spPkg.ExtraInfoCheckBoxCmd=char(currpkg.item(0).getAttribute('extrainfocheckboxcmd'));
            spPkg.Platform=char(currpkg.item(0).getAttribute('platform'));
            spPkg.PostInstallCmd=char(currpkg.item(0).getAttribute('postinstallcmd'));
            spPkg.PreUninstallCmd=char(currpkg.item(0).getAttribute('preuninstallcmd'));
            spPkg.BaseProduct=char(currpkg.item(0).getAttribute('baseproduct'));
            spPkg.UrlCatalog=char(currpkg.item(0).getAttribute('urlcatalog'));
            spPkg.FwUpdateDisplayName=char(currpkg.item(0).getAttribute('fwupdatedisplayname'));
            isDownloadWithoutInstallAllowed=char(currpkg.item(0).getAttribute('allowdownloadwithoutinstall'));
            if~isempty(isDownloadWithoutInstallAllowed)
                spPkg.AllowDownloadWithoutInstall=~isequal(lower(isDownloadWithoutInstallAllowed),'no');
            end
            spPkg.FullName=char(currpkg.item(0).getAttribute('fullname'));
            displayName=char(currpkg.item(0).getAttribute('displayname'));
            if isempty(displayName)
                spPkg.DisplayName=spPkg.Name;
            else
                spPkg.DisplayName=displayName;
            end
            supportCategory=char(currpkg.item(0).getAttribute('supportcategory'));
            if isempty(supportCategory)
                spPkg.SupportCategory='hardware';
            else
                spPkg.SupportCategory=supportCategory;
            end


            baseCode=char(currpkg.item(0).getAttribute('basecode'));
            if isempty(baseCode)
                spPkg.BaseCode='';
            else
                spPkg.BaseCode=baseCode;
            end


            supportTypeQualifier=char(currpkg.item(0).getAttribute('supporttypequalifier'));
            if isempty(supportTypeQualifier)
                spPkg.SupportTypeQualifier=char(hwconnectinstaller.SupportTypeQualifierEnum.Standard);
            else
                spPkg.SupportTypeQualifier=supportTypeQualifier;
            end



            customMWLicenseFiles=char(currpkg.item(0).getAttribute('custommwlicensefiles'));
            if isempty(customMWLicenseFiles)
                spPkg.CustomMWLicenseFiles='';
            else
                spPkg.CustomMWLicenseFiles=customMWLicenseFiles;
            end
            spPkg.CustomLicense=char(currpkg.item(0).getAttribute('customlicense'));
            spPkg.CustomLicenseNotes=char(currpkg.item(0).getAttribute('customlicensenotes'));
            spPkg.ShowSPLicense=~isequal(lower(char(currpkg.item(0).getAttribute('showsplicense'))),'no');
            infoUrl=char(currpkg.item(0).getAttribute('infohyperlink'));
            if~isempty(infoUrl)
                spPkg.InfoUrl=infoUrl;
            end
            spPkg.InfoText=char(currpkg.item(0).getAttribute('infotext'));


            tmp=currpkg.item(0).getElementsByTagName('DependsOn');
            for i=0:tmp.getLength-1
                spPkg.Children(i+1).Name=char(tmp.item(i).getAttribute('name'));
                spPkg.Children(i+1).Version=char(tmp.item(i).getAttribute('version'));
            end


            addFile=currpkg.item(0).getElementsByTagName('FilesToPackage');
            for i=0:addFile.getLength-1
                currAddFile=addFile.item(i);
                fileList=currAddFile.getElementsByTagName('File');
                for j=0:fileList.getLength-1
                    spPkg.FilesToPackage{end+1}=char(fileList.item(j).getAttribute('name'));
                end
            end


            removeFile=currpkg.item(0).getElementsByTagName('FilesToExclude');
            for i=0:removeFile.getLength-1
                currRemoveFile=removeFile.item(i);
                fileList=currRemoveFile.getElementsByTagName('File');
                for j=0:fileList.getLength-1
                    spPkg.FilesToExclude{end+1}=char(fileList.item(j).getAttribute('name'));
                end
            end
            archiveHandler=hwconnectinstaller.ArchiveHandler.getInstance;
            spPkg.ToolboxPath=archiveHandler.getToolboxPath(options);

        end





        function domelement=getelement(domobj,attribute,attributename)
            domelement=[];
            for i=0:domobj.getLength-1
                currdomobj=domobj.item(i);
                if strcmp(char(attribute),...
                    char(currdomobj.getAttribute(attributename)))
                    domelement=currdomobj;
                    break;
                end
            end
        end




        function prefGroup=getPrefGroup(group)
            prefGroup=hwconnectinstaller.internal.PackageInfo.GROUP;
            prefGroup=strcat(prefGroup,'_',group);
        end


        function setPref(group,pref,value)
            prefGroup=hwconnectinstaller.internal.PackageInfo.getPrefGroup(group);
            setpref(prefGroup,pref,value);
        end


        function prefValue=getPref(group,pref)
            prefGroup=hwconnectinstaller.internal.PackageInfo.getPrefGroup(group);
            if ispref(prefGroup,pref)
                prefValue=getpref(prefGroup,pref);
            else
                prefValue=[];
            end
        end

        function removePref(group,pref)
            prefGroup=hwconnectinstaller.internal.PackageInfo.getPrefGroup(group);
            rmpref(prefGroup,pref);
        end



        function ret=isPathEqual(path1,path2)
            if ispc
                ret=strcmpi(path1,path2);
            else
                ret=isequal(path1,path2);
            end
        end
    end
end


