










function validateComputeCapability(coderCfg,precision,minComputeCapability)



    gpuCfg=coderCfg.GpuConfig;

    if isa(coderCfg,'coder.MexCodeConfig')
        hostGPU=gpuDevice;
        computeVersion=str2double(hostGPU.ComputeCapability);
        if(computeVersion<str2double(minComputeCapability))
            error(message('gpucoder:cnnconfig:unsupported_compute_host',precision,minComputeCapability));
        end

    elseif isa(coderCfg,'coder.CodeConfig')||isa(coderCfg,'coder.EmbeddedCodeConfig')



        if isempty(gpuCfg.ComputeCapability)

            error(message('gpucoder:cnnconfig:unsupported_compute',precision,minComputeCapability));


        elseif strcmpi(precision,'INT8')&&strcmpi(gpuCfg.ComputeCapability,'6.2')
            error(message('gpucoder:cnnconfig:int8_unsupported_hardware'));


        elseif str2double(gpuCfg.ComputeCapability)<str2double(minComputeCapability)
            error(message('gpucoder:cnnconfig:unsupported_compute',precision,minComputeCapability));
        end

    end
end
