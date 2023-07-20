classdef cmsisNNApi<coder.ExternalDependency&coder.internal.JITSupportedExternalDependency






%#codegen
    methods(Static)
        function bName=getDescriptiveName(~)
            bName='cmsisNNApi';
        end

        function tf=isSupportedContext(ctx)
            config=ctx.getConfigProp('DeepLearningConfig');
            if isa(config,'coder.CMSISNNConfig')
                tf=true;
                return;
            end
            tf=false;
        end


        function updateBuildInfo(buildInfo,ctx)

            dltargets.cmsis_nn.cmsisNNApi.setCMSISNNIncludeOption(buildInfo);

            dltargets.cmsis_nn.cmsisNNApi.setDefaultBuildOptions(buildInfo);
        end

        function setDefaultBuildOptions(buildInfo)
            CMSISNNLIB=dltargets.cmsis_nn.cmsisNNApi.getCMSISNNLIBPath();
            buildInfo.addLinkObjects('libcmsisnn.a',CMSISNNLIB,'',true,true);
        end

        function CMSISIncludeOption=setCMSISNNIncludeOption(buildinfo)
            CMSISInstallDir=fullfile(getenv('CMSISNN_PATH'));
            CMSISIncludeDir=fullfile(CMSISInstallDir,'Include');
            CMSISIncludeOption=strcat('-I',CMSISIncludeDir);
            buildinfo.addCompileFlags(CMSISIncludeOption);
        end
        function CMSISNNLIBPath=getCMSISNNLIBPath()
            CMSISInstallDir=fullfile(getenv('CMSISNN_PATH'));
            CMSISNNLIBPath=fullfile(CMSISInstallDir,'lib');
        end
        function simulinkContext=inSimulinkContext(ctx)
            simulinkContext=isa(ctx.ConfigData,'Simulink.ConfigSet');
        end

        function register()
            coder.inline('always');
            coder.allowpcode('plain');
        end

    end

end
