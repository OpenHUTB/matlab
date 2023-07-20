classdef onednnApi<coder.ExternalDependency&coder.internal.JITSupportedExternalDependency






%#codegen
    methods(Static)
        function bName=getDescriptiveName(~)
            bName='onednnApi';
        end

        function tf=isSupportedContext(ctx)
            config=ctx.getConfigProp('DeepLearningConfig');
            enableGpuAccel=ctx.getConfigProp('GPUAcceleration');
            if isa(config,'coder.MklDNNConfig')||isa(config,'coder.OneDNNConfig')||strcmpi(enableGpuAccel,'off')
                tf=true;
                return;
            end
            tf=false;
        end

        function mkldnnIncludeDir=updateWindowsBuildOptions(buildInfo,ctx,linkLibExt)

            mkldnnLibDir=fullfile(getenv('INTEL_MKLDNN'),'lib');

            if dltargets.onednn.onednnApi.inSimulinkContext(ctx)
                if dltargets.onednn.onednnApi.isSimulinkSimulationTarget(ctx)


                    matlabmkldnnLibDir=fullfile(matlabroot,'lib','win64');
                    buildInfo.addLinkObjects(strcat('mwdnnl',linkLibExt),matlabmkldnnLibDir,'',true,true);
                    mkldnnIncludeDir=fullfile(matlabroot,'extern','include','mkldnn');


                    buildInfo.addLinkObjects(strcat('shared_layers',linkLibExt),matlabmkldnnLibDir,'',true,true);
                    buildInfo.addLinkObjects(strcat('onednn_layers',linkLibExt),matlabmkldnnLibDir,'',true,true);
                else
                    buildInfo.addLinkObjects(strcat('dnnl',linkLibExt),mkldnnLibDir,'',true,true);
                    mkldnnIncludeDir=fullfile(getenv('INTEL_MKLDNN'),'include');
                end
            else
                deepLearningConfig=ctx.getConfigProp('DeepLearningConfig');
                if ctx.isCodeGenTarget('mex')





                    matlabmkldnnLibDir=fullfile(matlabroot,'lib','win64');
                    if(deepLearningConfig.UseShippingLibs==1)
                        buildInfo.addLinkObjects(strcat('mwdnnl',linkLibExt),matlabmkldnnLibDir,'',true,true);
                    else
                        buildInfo.addLinkObjects(strcat('dnnl',linkLibExt),mkldnnLibDir,'',true,true);
                    end


                    buildInfo.addLinkObjects(strcat('shared_layers',linkLibExt),matlabmkldnnLibDir,'',true,true);
                    buildInfo.addLinkObjects(strcat('onednn_layers',linkLibExt),matlabmkldnnLibDir,'',true,true);

                    mkldnnIncludeDir=fullfile(matlabroot,'extern','include','mkldnn');
                else



                    assert(deepLearningConfig.UseShippingLibs==0,'UseShippingLibs is only supported for MEX target');
                    buildInfo.addLinkObjects(strcat('dnnl',linkLibExt),mkldnnLibDir,'',true,true);
                    mkldnnIncludeDir=fullfile(getenv('INTEL_MKLDNN'),'include');
                end
            end
        end

        function mkldnnIncludeDir=updateMacBuildOptions(buildInfo,ctx)
            matlabLibDir=fullfile(matlabroot,'bin','maci64');
            mkldnnLibDir=fullfile(getenv('INTEL_MKLDNN'),'lib');
            sysLibDir=fullfile(matlabroot,'sys','os','maci64');

            if dltargets.onednn.onednnApi.inSimulinkContext(ctx)
                if dltargets.onednn.onednnApi.isSimulinkSimulationTarget(ctx)

                    buildInfo.addSysLibs('mwdnnl',matlabLibDir);
                    buildInfo.addSysLibs('iomp5',sysLibDir);
                    mkldnnIncludeDir=fullfile(matlabroot,'extern','include','mkldnn');


                    buildInfo.addSysLibs('mwshared_layers',matlabLibDir);
                    buildInfo.addSysLibs('mwonednn_layers',matlabLibDir);
                else
                    buildInfo.addSysLibs('dnnl',mkldnnLibDir);
                    buildInfo.addSysLibs('omp',mkldnnLibDir);
                    linkFlags=strcat('-Wl,-rpath,',mkldnnLibDir);
                    buildInfo.addLinkFlags(linkFlags);
                    mkldnnIncludeDir=fullfile(getenv('INTEL_MKLDNN'),'include');
                end
            else
                deepLearningConfig=ctx.getConfigProp('DeepLearningConfig');
                if ctx.isCodeGenTarget('mex')




                    if(deepLearningConfig.UseShippingLibs==1)
                        buildInfo.addSysLibs('mwdnnl',matlabLibDir);
                        buildInfo.addSysLibs('iomp5',sysLibDir);
                    else
                        buildInfo.addSysLibs('dnnl',mkldnnLibDir);
                        if ctx.getConfigProp('EnableOpenMP')
                            buildInfo.addSysLibs('omp',mkldnnLibDir);
                        end
                        linkFlags=strcat('-Wl,-rpath,',mkldnnLibDir);
                        buildInfo.addLinkFlags(linkFlags);
                    end


                    buildInfo.addSysLibs('mwshared_layers',matlabLibDir);
                    buildInfo.addSysLibs('mwonednn_layers',matlabLibDir);

                    mkldnnIncludeDir=fullfile(matlabroot,'extern','include','mkldnn');
                else




                    assert(deepLearningConfig.UseShippingLibs==0,'UseShippingLibs is only supported for MEX target');
                    buildInfo.addSysLibs('dnnl',mkldnnLibDir);
                    if ctx.getConfigProp('EnableOpenMP')
                        buildInfo.addSysLibs('omp',mkldnnLibDir);
                    end
                    linkFlags=strcat('-Wl,-rpath,',mkldnnLibDir);
                    buildInfo.addLinkFlags(linkFlags);
                    mkldnnIncludeDir=fullfile(getenv('INTEL_MKLDNN'),'include');
                end
            end
        end

        function mkldnnIncludeDir=updateLinuxBuildOptions(buildInfo,ctx)
            matlabLibDir=fullfile(matlabroot,'bin','glnxa64');
            mkldnnLibDir=fullfile(getenv('INTEL_MKLDNN'),'lib');
            sysLibDir=fullfile(matlabroot,'sys','os','glnxa64');

            if dltargets.onednn.onednnApi.inSimulinkContext(ctx)
                if dltargets.onednn.onednnApi.isSimulinkSimulationTarget(ctx)

                    buildInfo.addSysLibs('mwdnnl',matlabLibDir);
                    buildInfo.addSysLibs('iomp5',sysLibDir);
                    mkldnnIncludeDir=fullfile(matlabroot,'extern','include','mkldnn');


                    buildInfo.addSysLibs('mwshared_layers',matlabLibDir);
                    buildInfo.addSysLibs('mwonednn_layers',matlabLibDir);
                else
                    buildInfo.addSysLibs('dnnl',mkldnnLibDir);
                    linkFlags=strcat('-Wl,-rpath,',mkldnnLibDir);
                    buildInfo.addLinkFlags(linkFlags);
                    mkldnnIncludeDir=fullfile(getenv('INTEL_MKLDNN'),'include');
                end
            else
                deepLearningConfig=ctx.getConfigProp('DeepLearningConfig');
                if ctx.isCodeGenTarget('mex')




                    if(deepLearningConfig.UseShippingLibs==1)
                        buildInfo.addSysLibs('mwdnnl',matlabLibDir);
                        buildInfo.addSysLibs('iomp5',sysLibDir);
                    else
                        buildInfo.addSysLibs('dnnl',mkldnnLibDir);
                        linkFlags=strcat('-Wl,-rpath,',mkldnnLibDir);
                        buildInfo.addLinkFlags(linkFlags);
                    end


                    buildInfo.addSysLibs('mwshared_layers',matlabLibDir);
                    buildInfo.addSysLibs('mwonednn_layers',matlabLibDir);

                    mkldnnIncludeDir=fullfile(matlabroot,'extern','include','mkldnn');
                else




                    assert(deepLearningConfig.UseShippingLibs==0,'UseShippingLibs is only supported for MEX target');
                    buildInfo.addSysLibs('dnnl',mkldnnLibDir);
                    linkFlags=strcat('-Wl,-rpath,',mkldnnLibDir);
                    buildInfo.addLinkFlags(linkFlags);
                    mkldnnIncludeDir=fullfile(getenv('INTEL_MKLDNN'),'include');
                end
            end

        end

        function simulinkContext=inSimulinkContext(ctx)
            simulinkContext=isa(ctx.ConfigData,'Simulink.ConfigSet');
        end

        function updateBuildInfo(buildInfo,ctx)
            [~,linkLibExt,~,~]=ctx.getStdLibInfo();
            if ispc
                mkldnnIncludeDir=dltargets.onednn.onednnApi.updateWindowsBuildOptions(buildInfo,ctx,linkLibExt);
            elseif ismac
                mkldnnIncludeDir=dltargets.onednn.onednnApi.updateMacBuildOptions(buildInfo,ctx);
            else
                mkldnnIncludeDir=dltargets.onednn.onednnApi.updateLinuxBuildOptions(buildInfo,ctx);
            end

            buildInfo.addIncludePaths(mkldnnIncludeDir);



            if(dltargets.onednn.onednnApi.inSimulinkContext(ctx)&&...
                dltargets.onednn.onednnApi.isSimulinkSimulationTarget(ctx))||...
                ctx.isCodeGenTarget('mex')

                if ispc
                    layerHeaderIncludeDir=fullfile(matlabroot,'derived','win64','src','include','layer');
                    layerImplHeaderIncludeDir=fullfile(matlabroot,'derived','win64','src','include','onednn');
                elseif ismac
                    layerHeaderIncludeDir=fullfile(matlabroot,'derived','maci64','src','include','layer');
                    layerImplHeaderIncludeDir=fullfile(matlabroot,'derived','maci64','src','include','onednn');
                else
                    layerHeaderIncludeDir=fullfile(matlabroot,'derived','glnxa64','src','include','layer');
                    layerImplHeaderIncludeDir=fullfile(matlabroot,'derived','glnxa64','src','include','onednn');
                end
                buildInfo.addIncludePaths(layerHeaderIncludeDir);
                buildInfo.addIncludePaths(layerImplHeaderIncludeDir);
            end


            deepLearningConfig=ctx.getConfigProp('DeepLearningConfig');


            if ctx.isCodeGenTarget('mex')
                mexCompilerCppConfig=mex.getCompilerConfigurations('c++');

                if~isempty(mexCompilerCppConfig)
                    mexToolchainName=mexCompilerCppConfig.Name;



                    if ispc||ismac
                        mexToolchainName=mexCompilerCppConfig.Manufacturer;
                    end



                    if deepLearningConfig.Instrumentation
                        sysLib='mwdnn_instrumentation';
                        sysLibPath=dltargets.internal.utils.getMLSysPath(mexToolchainName);
                        buildInfo.addSysLibs(sysLib,sysLibPath);
                    end
                end
            end
        end

        function result=isSimulinkSimulationTarget(ctx)
            result=dltargets.onednn.onednnApi.inSimulinkContext(ctx)&&...
            (ctx.isCodeGenTarget('sfun')||...
            strcmpi(ctx.getConfigProp('SystemTargetFile'),'modelrefsim.tlc')||...
            strcmpi(ctx.getConfigProp('SystemTargetFile'),'raccel.tlc')...
            );
        end

        function register()
            coder.inline('always');
            coder.allowpcode('plain');
        end

    end
end



