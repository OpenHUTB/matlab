classdef MATLABCoderToolchainListFilter < coder.make.internal.ToolchainListFilter

    properties ( Access = private )
        IsGPUCoder
    end

    methods
        function obj = MATLABCoderToolchainListFilter( isGpuCoder, prodHWDeviceType, targetHWDeviceType, prodEqTarget )

            arguments
                isGpuCoder( 1, 1 )logical
                prodHWDeviceType( 1, : )char
                targetHWDeviceType( 1, : )char
                prodEqTarget( 1, 1 )logical
            end


            obj.IsGPUCoder = isGpuCoder;
            if prodEqTarget
                obj = obj.setTargetHWDeviceType( prodHWDeviceType );
            else
                obj = obj.setTargetHWDeviceType( targetHWDeviceType );
            end
        end

        function ret = isProductConfigurationCompatible( obj, toolchainInfoRegistry )
            arguments
                obj
                toolchainInfoRegistry( 1, 1 )coder.make.internal.IToolchainInfoRegistry
            end



            tcName = toolchainInfoRegistry.Name;
            if contains( tcName, 'AUTOSAR Adaptive' )
                ret = false;
                return ;
            end

            isGPUToolchain = contains( tcName, 'NVIDIA' ) &&  ...
                ~strcmpi( tcName, 'GNU GCC for NVIDIA Embedded Processors' );

            ret = obj.IsGPUCoder == isGPUToolchain;
        end
    end
end


