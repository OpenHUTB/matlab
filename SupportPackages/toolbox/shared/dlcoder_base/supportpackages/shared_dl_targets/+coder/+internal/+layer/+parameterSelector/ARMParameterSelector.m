classdef ARMParameterSelector<coder.internal.layer.parameterSelector.DefaultParameterSelector





    methods

        function obj=ARMParameterSelector()


            obj.MatrixMultiplicationParameters=...
            coder.internal.layer.matrixMultiplication.CgirCpuParameters('SimdRegistersPerColumn',2,...
            'RegisterBlockWidth',2,...
            'CacheBlockSizeM',64,...
            'CacheBlockSizeK',64,...
            'CacheBlockSizeN',64,...
            'UsePackingA',false,...
            'UsePackingB',false);

        end

        function params=selectMatrixMultiplicationParameters(obj,specification,buildContext)
            params=...
            selectMatrixMultiplicationParameters@...
            coder.internal.layer.parameterSelector.DefaultParameterSelector(obj,...
            specification,buildContext);

        end

        function params=selectConvolutionParameters(obj,specification,buildContext)
            simdLength=dltargets.internal.getLargestSIMDWidth('vload','single',buildContext);
            params=coder.internal.layer.convUtils.getOptimizedParamsForConv(obj,specification,simdLength);
        end
    end
end
