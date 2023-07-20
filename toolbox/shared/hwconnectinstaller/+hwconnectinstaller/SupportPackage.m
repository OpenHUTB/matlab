classdef SupportPackage<hwconnectinstaller.SoftwarePackage














    properties(Access=public)
        Release='';
        Folder='';
        Path={};
TpPkg
        FwUpdate='';
        DemoXml='';
        ExtraInfoCheckBoxDescription='';
        ExtraInfoCheckBoxCmd='';
        Platform={};
FilesToPackage
FilesToExclude
        Visible=true;
        Enable=true;
        BaseProduct='';
        FwUpdateDisplayName='';
        AllowDownloadWithoutInstall=true;
        CustomLicense='No';
        CustomLicenseNotes='';
        ShowSPLicense=true;
        FullName='';
        DisplayName='';
        InfoText='';
        InfoUrl='';
        SupportCategory='hardware';
        PostInstallCmd='';
        PreUninstallCmd='';
Parent
Children
ArchiveSuffix

        UrlCatalog='';
        UrlCatalogHandle=hwconnectinstaller.util.UrlCatalog.empty;
        ToolboxPath=''


        SupportTypeQualifier='';



        BaseCode='';















        CustomMWLicenseFiles='';


        InstalledDate='';
    end

    properties(Dependent)
Envvar
XmlFile
PlatformStr
ArchiveName
    end
    properties(Constant)
        DefaultInfoText='Click for more info';
    end


    methods
        function obj=SupportPackage(name,url,version,release,folder)

            if(nargin>0)
                obj.Name=name;
            end
            if(nargin>1)
                obj.Url=url;
            end
            if(nargin>2)
                obj.Version=version;
            end
            if(nargin>3)
                obj.Release=release;
            else
                obj.Release=hwconnectinstaller.util.getCurrentRelease();
            end
            if(nargin>4)
                obj.Folder=folder;
            end
            obj.TpPkg=hwconnectinstaller.ThirdPartyPackage();
            obj.TpPkg(1)=[];
        end
    end
    methods(Hidden)

        function installLoc=getSpPkgInstallLoc(obj)
            installLoc=fullfile(obj.InstallDir,hwconnectinstaller.SupportPackage.getPkgTag(obj.Name));
        end
    end




    methods

        function set.Release(obj,release)
            if~isa(release,'char')
                error(message('hwconnectinstaller:setup:InvalidArgument','release'));
            end
            obj.Release=release;
        end


        function set.Folder(obj,folder)
            if~isa(folder,'char')
                error(message('hwconnectinstaller:setup:InvalidArgument','folder'));
            end
            obj.Folder=folder;
        end


        function set.Platform(obj,platform)
            if~(isa(platform,'char')||iscell(platform))
                error(message('hwconnectinstaller:setup:InvalidArgument','platform'));
            end
            if iscell(platform)
                obj.Platform=platform;
            else
                obj.Platform=regexp(platform,',','split');
            end
        end


        function ArchiveName=get.ArchiveName(obj)


            reltag=obj.getReleaseTag(obj.Release);
            pkgtag=obj.getPkgTag(obj.Name);
            vertag=obj.getVerTag(obj.Version);
            ArchiveName=[pkgtag,'_',reltag,'_',vertag];
            if~isempty(obj.ArchiveSuffix)
                ArchiveName=[ArchiveName,'_',lower(obj.ArchiveSuffix)];
            end
            ArchiveName=[ArchiveName,'.zip'];
            ArchiveName=strrep(ArchiveName,'-','');
        end


        function XmlFile=get.XmlFile(obj)
            XmlFile=[obj.Alias,'_registry.xml'];
        end

        function PlatformStr=get.PlatformStr(obj)
            PlatformStr='';
            for i=1:numel(obj.Platform)
                PlatformStr=[PlatformStr,obj.Platform{i}];%#ok<AGROW>
                if(i~=numel(obj.Platform))
                    PlatformStr=[PlatformStr,','];%#ok<AGROW>
                end
            end
        end



        function ret=eq(obj,obj1)
            if(strcmp(obj.Name,obj1.Name)&&...
                strcmp(obj.Release,obj1.Release))
                ret=true;
            else
                ret=false;
            end
        end



        function ret=ne(obj,obj1)
            if(strcmp(obj.Name,obj1.Name)&&...
                strcmp(obj.Release,obj1.Release))
                ret=false;
            else
                ret=true;
            end
        end

        function ret=gt(obj,obj1)
            ret=strcmp(obj.Name,obj1.Name)&&(obj.compareVersionTo(obj1)>0);
        end

        function ret=ge(obj,obj1)
            ret=strcmp(obj.Name,obj1.Name)&&(obj.compareVersionTo(obj1)>=0);
        end

        function ret=le(obj,obj1)
            ret=strcmp(obj.Name,obj1.Name)&&(obj.compareVersionTo(obj1)<=0);
        end

        function ret=lt(obj,obj1)
            ret=strcmp(obj.Name,obj1.Name)&&(obj.compareVersionTo(obj1)<0);
        end

        function Envvar=get.Envvar(obj)

            Envvar=upper([obj.Alias,'_ROOT_',...
            regexprep(obj.Release,'[\s+._\(\)]','')]);
        end

        function set.Visible(obj,visible)
            if isa(visible,'char')
                switch visible
                case{'true','1',''}


                    obj.Visible=true;
                case{'false','0'}
                    obj.Visible=false;
                otherwise
                    error(message('hwconnectinstaller:setup:InvalidArgument','visible'));
                end
            else
                obj.Visible=logical(visible);
            end
        end

        function set.Enable(obj,enable)
            if isa(enable,'char')
                switch enable


                case{'true','1',''}
                    obj.Enable=true;
                case{'false','0'}
                    obj.Enable=false;
                otherwise
                    error(message('hwconnectinstaller:setup:InvalidArgument','enable'));
                end
            else
                obj.Enable=logical(enable);
            end
        end
















        function ret=compareVersionTo(obj,obj1)
            ret=obj.compareVersion(obj.Version,obj1.Version);
        end
    end

    methods(Static,Hidden)






        function relTag=getReleaseTag(release,opts)



            relTag=regexprep(release,'[\s|(|)]','');
            if~exist('opts','var')||~strcmpi(opts,'matchcase')
                relTag=lower(relTag);
            end
        end






        function pkgTag=getPkgTag(name,opts)

            pkgTag=regexprep(name,'\(R\)','');
            pkgTag=regexprep(pkgTag,'\W','');
            if~exist('opts','var')||~strcmpi(opts,'matchcase')
                pkgTag=lower(pkgTag);
            end
        end



        function verTag=getVerTag(version)
            version=strtrim(version);
            version=strrep(version,'.','_');
            verTag=lower(regexprep(version,'\W',''));
        end





        function ret=compareVersion(v1,v2)
            va=str2double(strsplit(v1,'.'));
            vb=str2double(strsplit(v2,'.'));
            maxlen=max(length(va),length(vb));
            va(end+1:maxlen)=0;
            vb(end+1:maxlen)=0;
            index=find(va~=vb,1,'first');
            if isempty(index)
                ret=0;
            elseif va(index)>vb(index)
                ret=+1;
            else
                ret=-1;
            end
        end

    end
end
