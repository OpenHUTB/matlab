classdef UDPRead<ioplayback.base.UDPRead...
    &coder.ExternalDependency





%#codegen

    properties(Nontunable,Dependent)

        LocalIPPort=25000

        DataSize=1
    end

    methods
        function obj=UDPRead(varargin)
            coder.allowpcode('plain');
            if~ioplayback.base.target
                coder.cinclude('MW_linuxUDP.h');
            end
            obj.Logo='';
            setProperties(obj,nargin,varargin{:});
            obj.DataFileFormat='Raw-TimeStamp';
        end
        function set.DataSize(obj,value)
            validateattributes(value,{'numeric'},...
            {'scalar','integer','>',0,'<',65536},'','DataSize');
            obj.DataLength=value;
        end

        function ret=get.DataSize(obj)
            ret=obj.DataLength;
        end

        function set.LocalIPPort(obj,value)
            validateattributes(value,{'numeric'},...
            {'scalar','integer','>',0,'<',65536},'','LocalIPPort');
            obj.LocalPort=value;
        end

        function ret=get.LocalIPPort(obj)
            ret=obj.LocalPort;
        end
    end

    methods(Static)
        function name=getDescriptiveName(~)
            name='UDP Read';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw')||context.isCodeGenTarget('sfun');
        end

        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')||context.isCodeGenTarget('sfun')
                svdDir=ioplayback.base.getRootDir;
                addIncludePaths(buildInfo,fullfile(svdDir,'include'));
                addIncludeFiles(buildInfo,'mw_udp.h');

                drvdir=soc.internal.getRootDir;

                addIncludePaths(buildInfo,fullfile(drvdir,'include'));
                addIncludeFiles(buildInfo,'MW_linuxUDP.h');

                addSourcePaths(buildInfo,fullfile(drvdir,'src'));
                addSourceFiles(buildInfo,'mw_linux_udp.c',fullfile(drvdir,'src'),'BlockModules');
                addSourceFiles(buildInfo,'MW_linuxUDP.c',fullfile(drvdir,'src'),'BlockModules');
            end
        end
    end
end

