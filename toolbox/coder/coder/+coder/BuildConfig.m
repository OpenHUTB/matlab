

























































classdef BuildConfig
    properties(SetAccess=immutable)

        CodeGenTarget;

        HardwareImplementation;

        TargetLang;

        ToolchainInfo;

        ConfigData;

        BuildDir;
    end

    properties(SetAccess=immutable,Hidden)
        CanCopyToBuildDir;
    end

    methods
        function aHI=get.HardwareImplementation(obj)
            if ismethod(obj.HardwareImplementation,'copy')
                aHI=obj.HardwareImplementation.copy();
            else
                aHI=obj.HardwareImplementation;
            end
        end

        function aTCI=get.ToolchainInfo(obj)
            if isempty(obj.ToolchainInfo)

                aTCI=coder.make.internal.createEmptyToolchain('');
            else
                aTCI=coder.make.internal.copyToolchain(obj.ToolchainInfo);
            end
        end

        function aCFG=get.ConfigData(obj)
            aCFG=obj.ConfigData.copy();
        end
    end

    methods(Access=public)


        function this=BuildConfig(aCGT,aHWI,aTL,aTCI,aCFG,aBD,aCPy)
            this.CodeGenTarget=coder.internal.toCharIfString(aCGT);
            this.HardwareImplementation=aHWI;
            this.TargetLang=coder.internal.toCharIfString(aTL);
            this.ToolchainInfo=aTCI;
            this.ConfigData=aCFG;
            this.BuildDir=aBD;
            if nargin<7
                aCPy=false;
            end
            this.CanCopyToBuildDir=aCPy;
        end



        function r=getConfigProp(this,aProp)
            if isa(this.ConfigData,'Simulink.ConfigSet')
                try
                    r=get_param(this.ConfigData,aProp);
                catch
                    r=[];
                end
            else
                if coder.internal.isCharOrScalarString(aProp)&&isprop(this.ConfigData,aProp)
                    r=this.ConfigData.(aProp);
                else
                    r=[];
                end
            end
        end



        function h=getHardwareImplementation(this)
            h=this.HardwareImplementation;
        end



        function t=getToolchainInfo(this)
            t=this.ToolchainInfo;
        end



        function t=getTargetLang(this)
            t=this.TargetLang;
        end




        function t=isCodeGenTarget(this,targets)
            t=false;
            if~iscell(targets)
                targets={targets};
            end
            for i=1:numel(targets)
                target=targets{i};
                if coder.internal.isCharOrScalarString(target)
                    t=t||strcmp(this.CodeGenTarget,target);
                end
            end
        end



        function b=isMatlabHostTarget(this)
            b=true;
            matlabHostHw='Generic->MATLAB Host Computer';
            actualProdHw=this.HardwareImplementation.ProdHWDeviceType;
            if~strcmp(actualProdHw,matlabHostHw)&&~isIntelPlatform(actualProdHw)
                b=false;
            end
            if~this.HardwareImplementation.ProdEqTarget
                actualTargetHw=this.HardwareImplementation.TargetHWDeviceType;
                if~strcmp(actualTargetHw,matlabHostHw)&&~isIntelPlatform(actualTargetHw)
                    b=false;
                end
            end
        end



        function b=isTargetLanguageC(this)
            b=strcmp(this.getTargetLang,'C');
        end



        function b=isTargetLanguageCPP(this)
            b=strcmp(this.getTargetLang,'C++');
        end



        function d=getBuildDir(this)
            d=this.BuildDir;
        end
    end
    methods(Access=public,Static)







        function[linkLibPath,linkLibExt,execLibExt,libPrefix]=getStdLibInfo()
            if ispc()
                linkLibPath=fullfile(matlabroot,'lib',computer('arch'));
                linkLibExt='.lib';
                execLibExt='.dll';
                libPrefix='';
            else
                linkLibPath=fullfile(matlabroot,'bin',computer('arch'));
                libPrefix='libmw';
                if ismac()
                    linkLibExt='.dylib';
                    execLibExt='.dylib';
                else
                    linkLibExt='.so';
                    execLibExt='.so';
                end
            end
        end
    end
end

function b=isIntelPlatform(target)
    switch(coder.const(computer('arch')))
    case 'win64'
        b=strcmp(target,'Intel->x86-64 (Windows64)');
    case 'glnxa64'
        b=strcmp(target,'Intel->x86-64 (Linux 64)');
    case 'maci64'
        b=strcmp(target,'Intel->x86-64 (Mac OS X)');
    otherwise
        coder.internal.assert(false,'Coder:builtins:Explicit','Internal error: Unsupported platform');
    end
end



