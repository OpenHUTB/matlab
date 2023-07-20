classdef SoftwarePackage<handle




    properties
        Name='';
        Version='1.0';
        Url='';
        DownloadUrl='';
        LicenseUrl='';
        DownloadDir='';
        InstallDir='';
        IsInstalled=false;
        IsDownloaded=false;
        RootDir='';
    end

    properties(Dependent,Hidden)
        Alias;
        NumericVersion;
    end

    methods

        function Alias=get.Alias(obj)
            Alias=obj.getAlias(obj.Name);
        end
    end


    methods

        function set.Name(obj,name)
            if~isa(name,'char')
                error(message('hwconnectinstaller:setup:InvalidArgument','Name'));
            end
            obj.Name=name;
        end


        function set.Version(obj,version)
            if~isa(version,'char')
                error(message('hwconnectinstaller:setup:InvalidArgument','version'));
            end
            obj.Version=version;
        end


        function set.Url(obj,url)
            if~isa(url,'char')
                error(message('hwconnectinstaller:setup:InvalidArgument','url'));
            end
            obj.Url=url;
        end


        function NumericVersion=get.NumericVersion(obj)
            versiondigits=str2double(regexp(obj.Version,'[._]','split'));
            N=length(versiondigits);
            powThousand=(1000*ones(1,N)).^(N:-1:1);
            NumericVersion=sum(powThousand.*versiondigits);
        end
    end

    methods(Static,Hidden)





        function alias=getAlias(name)
            name=lower(strtrim(name));
            alias=regexprep(name,'\s+','_');
            alias=regexprep(alias,'\W','');


            alias=regexprep(alias,'(\<\d|\<_)','x$1');
        end
    end

    methods
        function h=SoftwarePackage
        end
    end
end

