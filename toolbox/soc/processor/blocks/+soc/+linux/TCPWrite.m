classdef TCPWrite<ioplayback.base.TCPWrite...
    &coder.ExternalDependency






%#codegen

    methods
        function obj=TCPWrite(varargin)



            coder.allowpcode('plain');
            if~ioplayback.base.target
                coder.cinclude('MW_TCPSendReceive.h');
            end
            obj.Logo='';
            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Static)
        function name=getDescriptiveName(~)
            name='TCP Write';
        end

        function b=isSupportedContext(context)
            b=context.isCodeGenTarget('rtw')||context.isCodeGenTarget('sfun');
        end

        function updateBuildInfo(buildInfo,context)
            if context.isCodeGenTarget('rtw')||context.isCodeGenTarget('sfun')
                svdDir=ioplayback.base.getRootDir;
                addIncludePaths(buildInfo,fullfile(svdDir,'include'));
                addIncludeFiles(buildInfo,'mw_tcp.h');

                drvdir=soc.internal.getRootDir;

                addIncludePaths(buildInfo,fullfile(drvdir,'include'),'SkipForSil');
                addIncludeFiles(buildInfo,'MW_TCPSendReceive.h');

                addSourcePaths(buildInfo,fullfile(drvdir,'src'));
                addSourceFiles(buildInfo,'MW_TCPSendReceive.c',fullfile(drvdir,'src'),'BlockModules');
                addSourceFiles(buildInfo,'mw_linux_tcp.c',fullfile(drvdir,'src'),'BlockModules');
            end
        end
    end
end

