classdef(Hidden)OperatingSystemDistribution<matlab.mixin.SetGet


























    properties(Access=public,Dependent)
        Name=[];
        URL=[];
        PrebuildFcn=[];
        GetMissingPackagesFcn=[];
        BuildCmdFormat=[];
        BuildArgs=[];
        BuildCmd=[];
        PostbuildFcn=[];
        ImageFiles=[];
        RemovePackagesFcn=[];
        InstallCmd=[];
        InstallCmdArgs=[];
        InstallCmdType=[];
    end

    properties(Access=private,Hidden)
OSInfoObj
    end

    properties(Hidden,GetAccess=public,SetAccess=private)
pBuildHostSysInterface
pHardwareSysInterface
    end

    properties








SourceFolder








OutputFolder
    end

    properties(Dependent)



        BuildHostDeviceAddress='localhost';



        BuildHostUsername='';
    end
    properties(Dependent,Hidden)


        BuildHostPassword='';
    end

    properties(Constant,Hidden)
        DEVICEPREF='RemoteDevice';
    end

    properties(Access=private)
pBoardPrefs
    end

    properties(Dependent,Hidden)
InTestEnvironment
    end

    methods(Static)

    end

    methods(Static,Hidden)
        function xret=formatPackageNames(pkgCell)
            xret={};
            for ii=1:numel(pkgCell)
                if strcmpi(pkgCell{ii},'NA')
                    continue;
                end
                thePkgs=regexp(pkgCell{ii},';','split');
                xret=[xret,thePkgs];%#ok<AGROW>
            end
        end
    end

    methods
        function ret=get.Name(obj)
            ret=getName(obj.OSInfoObj);
        end
        function set.Name(obj,val)
            setName(obj.OSInfoObj,val);
        end

        function ret=get.PrebuildFcn(obj)
            ret=getPrebuildFcn(obj.OSInfoObj);
        end
        function set.PrebuildFcn(obj,val)
            setPrebuildFcn(obj.OSInfoObj,val);
        end

        function ret=get.GetMissingPackagesFcn(obj)
            ret=obj.OSInfoObj.GetMissingPackagesFcn;
        end
        function set.GetMissingPackagesFcn(obj,val)
            obj.OSInfoObj.RemovePackagesFcn=val;
        end

        function ret=get.RemovePackagesFcn(obj)
            ret=obj.OSInfoObj.RemovePackagesFcn;
        end
        function set.RemovePackagesFcn(obj,val)
            obj.OSInfoObj.RemovePackagesFcn=val;
        end

        function ret=get.BuildCmdFormat(obj)
            ret=getBuildCmdFormat(obj.OSInfoObj);
        end
        function set.BuildCmdFormat(obj,val)
            setBuildCmdFormat(obj.OSInfoObj,val);
        end

        function ret=get.BuildArgs(obj)
            ret=getBuildArgs(obj.OSInfoObj);
        end
        function set.BuildArgs(obj,val)
            setBuildArgs(obj.OSInfoObj,val);
        end
        function ret=get.BuildCmd(obj)
            ret=getBuildCmd(obj.OSInfoObj);
        end
        function set.BuildCmd(obj,cmd)
            setBuildCmd(obj.OSInfoObj,cmd);
        end
        function ret=get.PostbuildFcn(obj)
            ret=getPostbuildFcn(obj.OSInfoObj);
        end
        function set.PostbuildFcn(obj,fcn)
            setPostbuildFcn(obj.OSInfoObj,fcn);
        end
        function ret=get.ImageFiles(obj)
            ret=getImageFiles(obj.OSInfoObj);
        end
        function set.ImageFiles(obj,val)
            setImageFiles(obj.OSInfoObj,val);
        end
        function ret=get.InstallCmd(obj)
            ret=getInstallCmd(obj.OSInfoObj);
        end
        function set.InstallCmd(obj,val)
            setInstallCmd(obj.OSInfoObj,val);
        end
        function ret=get.InstallCmdArgs(obj)
            ret=getInstallCmdArgs(obj.OSInfoObj);
        end
        function set.InstallCmdArgs(obj,args)
            setInstallCmdArgs(obj.OSInfoObj,args);
        end
        function ret=get.InstallCmdType(obj)
            ret=getInstallCmdType(obj.OSInfoObj);
        end
        function set.InstallCmdType(obj,type)
            setInstallCmdType(obj.OSInfoObj,type);
        end
        function ret=get.BuildHostDeviceAddress(obj)
            ret=getBuildHostDeviceAddress(obj.OSInfoObj);
        end
        function ret=get.BuildHostUsername(obj)
            ret=getBuildHostUsername(obj.OSInfoObj);
        end
        function ret=get.BuildHostPassword(obj)
            ret=getBuildHostPassword(obj.OSInfoObj);
        end
        function set.BuildHostDeviceAddress(obj,val)
            setBuildHostDeviceAddress(obj.OSInfoObj,val);
        end
        function set.BuildHostUsername(obj,val)
            setBuildHostUsername(obj.OSInfoObj,val);
        end
        function set.BuildHostPassword(obj,val)
            setBuildHostPassword(obj.OSInfoObj,val);
        end

        function ret=get.InTestEnvironment(obj)%#ok<MANU>
            ret=false;
            testEnv='';
            if ispref(soc.internal.getPrefName)&&ispref(soc.internal.getPrefName,'TestEnvironment')
                testEnv=getpref(soc.internal.getPrefName,'TestEnvironment');
            end
            if~isempty(testEnv)&&testEnv
                if exist('matlabshared.internal.testssh2','class')
                    ret=true;
                end
            end
        end
    end

    methods(Access=public)
        function obj=OperatingSystemDistribution(name)
            infoFile=fullfile(soc.internal.getRootDir,'registry',[name,'.xml']);
            if~exist(infoFile,'file')
                if exist(fullfile(pwd,'registry',[name,'.xml']),'file')
                    obj.OSInfoObj=soc.internal.OperatingSystemDistributionInfo(fullfile(pwd,'registry',[name,'.xml']));
                else
                    obj.OSInfoObj=soc.internal.OperatingSystemDistributionInfo();
                end
            else
                obj.OSInfoObj=soc.internal.OperatingSystemDistributionInfo(infoFile);
            end
            obj.Name=name;
        end

        function addRequiredPackages(osDistObj,fName,pkgs,linkFlags,compFlags)
            addFeaturePackageInfo(osDistObj.OSInfoObj,fName,pkgs,linkFlags,compFlags)
        end

        function ret=getRequiredPackages(osDistObj)
            featurePkgInfoStruct=osDistObj.OSInfoObj.FeaturePackageInfo;
            ret=[featurePkgInfoStruct.Packages];
        end

        function saveInfo(osDistObj,fileName)
            setDefinitionFileName(osDistObj.OSInfoObj,fileName);
            register(osDistObj.OSInfoObj);
        end
    end

end


