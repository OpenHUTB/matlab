

function dlConfig=getDeepLearningConfig(ctx,targetLib)





    if~isempty(ctx)



        dlConfig=ctx.getConfigProp('DeepLearningConfig');

        if isempty(dlConfig)
            if(ctx.isCodeGenTarget('rtw'))

                dlConfig=iGetDLConfigForRTW(ctx);
            elseif(ctx.isCodeGenTarget('sfun'))

                dlConfig=iGetDLConfigForSFUN(ctx);
            end
        end
    else

        assert(nargin>1);
        dlConfig=coder.DeepLearningConfig(targetLib);


    end
end

function dlConfig=iGetDLConfigForRTW(ctx)
    lib=ctx.getConfigProp('DLTargetLibrary');
    if strcmpi(lib,'arm-compute')
        dlConfig=coder.DeepLearningConfig('arm-compute');
        dlConfig.ArmComputeVersion=ctx.getConfigProp('DLArmComputeVersion');
        dlConfig.ArmArchitecture=ctx.getConfigProp('DLArmComputeArch');
    elseif strcmpi(lib,'mkl-dnn')
        dlConfig=coder.DeepLearningConfig('mkldnn');
    elseif strcmpi(lib,'none')
        dlConfig=coder.DeepLearningConfig('none');
    elseif strcmpi(lib,'cudnn')
        dlConfig=coder.DeepLearningConfig('cudnn');
        if strcmpi(ctx.getConfigProp('DLAutoTuning'),'on')
            dlConfig.AutoTuning=1;
        else
            dlConfig.AutoTuning=0;
        end
    elseif strcmpi(lib,'tensorrt')
        dlConfig=coder.DeepLearningConfig('tensorrt');
    elseif strcmpi(lib,'cmsis-nn')
        dlConfig=coder.DeepLearningConfig('TargetLibrary','cmsis-nn');
    else
        dlConfig=coder.DeepLearningConfig('TargetLibrary','none');
    end

end

function dlConfig=iGetDLConfigForSFUN(ctx)

    if dlcoderfeature('LibraryFreeSimulinkSimulation')



        lib='none';
    else
        lib=ctx.getConfigProp('SimDLTargetLibrary');
    end

    if strcmpi(lib,'mkl-dnn')
        dlConfig=coder.DeepLearningConfig('mkldnn');
    elseif strcmpi(lib,'cudnn')
        dlConfig=coder.DeepLearningConfig('cudnn');
        if strcmpi(ctx.getConfigProp('SimDLAutoTuning'),'on')
            dlConfig.AutoTuning=1;
        else
            dlConfig.AutoTuning=0;
        end
    elseif strcmpi(lib,'none')
        dlConfig=coder.DeepLearningConfig('none');
    elseif strcmpi(lib,'tensorrt')
        dlConfig=coder.DeepLearningConfig('tensorrt');
    elseif strcmpi(lib,'cmsis-nn')
        dlConfig=coder.DeepLearningConfig('TargetLibrary','cmsis-nn');
    end
end
