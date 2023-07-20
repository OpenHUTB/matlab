function checkTensorrtParams(coderCfg,dlConfig)





    assert(isa(dlConfig,'coder.TensorRTConfig'));

    if isempty(coderCfg.GpuConfig)||~coderCfg.GpuConfig.Enabled
        error(message('gpucoder:cnnconfig:MissingGpuConfig',dlConfig.TargetLibrary));
    end

    if strcmpi(dlConfig.DataType,'fp32')||strcmpi(dlConfig.DataType,'fp16')

        if~isempty(dlConfig.DataPath)
            coderprivate.warnBacktraceOff(message('gpucoder:cnncodegen:ignore_tensorrt_param','DataPath'));
        end
        if dlConfig.NumCalibrationBatches>0
            coderprivate.warnBacktraceOff(message('gpucoder:cnncodegen:ignore_tensorrt_param','NumCalibrationBatches'));
        end




        if strcmpi(dlConfig.DataType,'fp16')

            if strcmpi(coderCfg.GpuConfig.ComputeCapability,'6.1')
                error(message('gpucoder:cnncodegen:FP16NotSupportedForCC6p1'));
            else
                dlcoder_base.internal.validateComputeCapability(coderCfg,'FP16','5.3');
            end
        end
    else
        assert(isequal(dlConfig.DataType,'int8'))





        dlcoder_base.internal.validateComputeCapability(coderCfg,'INT8','6.1');

        if isempty(dlConfig.DataPath)||~exist(dlConfig.DataPath,'dir')
            error(message('dnn_core:cnncodegen:InvalidTensorRTConfigDataPath',dlConfig.DataPath));
        end

        validateINT8CalibrationAlgorithm(dlConfig);
    end
end


function validateINT8CalibrationAlgorithm(dlConfig)







    supportedCalibrationAlgos={'IInt8MinMaxCalibrator','IInt8EntropyCalibrator2'};

    if~any(strcmpi(dlConfig.CalibrationAlgorithm,supportedCalibrationAlgos))
        error(message('gpucoder:cnncodegen:InvalidInt8Calibrator','CalibrationAlgorithm',strjoin(supportsupportedCalibrationAlgosdTypes,', ')));
    end

end



