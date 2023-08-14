classdef(Sealed)GpuConfigController<coderapp.internal.config.AbstractController




    methods
        function updateComputeCapability(this,defaultGpuConfig,toolchain)
            if isempty(defaultGpuConfig)
                return
            end

            allowedVals=[];
            if~isempty(toolchain)
                if(contains(toolchain,'NVIDIA CUDA for Jetson Tegra K1'))
                    allowedVals={'3.2'};
                elseif(contains(toolchain,'NVIDIA CUDA for Jetson Tegra X1'))
                    allowedVals={'5.3'};
                elseif(contains(toolchain,'NVIDIA CUDA for Jetson Tegra X2'))
                    allowedVals={'6.2'};
                end
            end
            if isempty(allowedVals)
                allowedVals=defaultGpuConfig.getOptions('ComputeCapability');
            end
            this.import('AllowedValues',allowedVals);
        end

        function value=validateBlockAlignment(~,value)
            coderapp.internal.gpu.GpuConfigController.validatePowerOfTwo(value,'BlockAlignment');
        end

        function value=validateMinPoolSize(~,value)
            coderapp.internal.gpu.GpuConfigController.validatePowerOfTwo(value,'MinPoolSize');
        end

        function value=validateMaxPoolSize(~,value)
            coderapp.internal.gpu.GpuConfigController.validatePowerOfTwo(value,'MaxPoolSize');
        end
    end

    methods(Access=private,Static)
        function validatePowerOfTwo(value,param)
            if(value==0)||(bitand(value,value-1)~=0)
                error(message('gpucoder:common:ParameterMustBePowerOf2',param))
            end
        end
    end
end
