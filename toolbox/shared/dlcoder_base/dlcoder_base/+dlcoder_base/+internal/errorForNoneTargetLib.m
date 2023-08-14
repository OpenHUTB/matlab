function errorForNoneTargetLib(ctx)




    assert(~isempty(ctx),'ctx is empty in errorForNoneTargetLib.m');
    buildWorkflow=dlcoder_base.internal.getBuildWorkflow(ctx);
    switch buildWorkflow
    case 'matlab'

        error(message('gpucoder:cnnconfig:DeepLearningConfigUnset'));
    case 'simulink'
        if strcmpi(ctx.getConfigProp('GenerateGPUCode'),'CUDA')
            allowedValues='''cuDNN'' , ''TensorRT''';
            error(message('gpucoder:cnnconfig:DLTargetLibUnsetRtwCodegen','DLTargetLibrary',allowedValues));
        end
    end
end
