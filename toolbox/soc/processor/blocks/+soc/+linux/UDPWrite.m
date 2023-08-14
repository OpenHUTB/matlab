classdef UDPWrite<ioplayback.base.UDPWrite...
    &coder.ExternalDependency






%#codegen

    methods
        function obj=UDPWrite(varargin)



            coder.allowpcode('plain');
            if~ioplayback.base.target
                coder.cinclude('MW_linuxUDP.h');
            end
            obj.Logo='';
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Static)
        function name=getDescriptiveName(~)
            name='UDP Write';
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

