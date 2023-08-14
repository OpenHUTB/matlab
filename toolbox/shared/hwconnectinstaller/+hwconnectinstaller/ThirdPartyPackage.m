classdef ThirdPartyPackage<hwconnectinstaller.SoftwarePackage




    properties
        FileName='';
        DestDir='';
        Installer='';
        Archive='';
    end

    properties(Hidden)
        PreDownloadCmd='';
        InstallCmd='';
        DownloadCmd='';
        RemoveCmd='';
        PreviouslyInstalled=false;
        PlatformStr='';
        InstructionSet='';
    end


    methods
        function obj=ThirdPartyPackage(name,url)
            if(nargin>0)
                obj.Name=name;
            end
            if(nargin>1)
                obj.Url=url;
            end
        end
    end

end

