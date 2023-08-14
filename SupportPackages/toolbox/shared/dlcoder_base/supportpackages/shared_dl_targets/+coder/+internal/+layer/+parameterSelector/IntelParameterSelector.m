classdef IntelParameterSelector<coder.internal.layer.parameterSelector.DefaultParameterSelector





    methods

        function obj=IntelParameterSelector()


            obj.MatrixMultiplicationParameters=...
            coder.internal.layer.matrixMultiplication.CgirCpuParameters('SimdRegistersPerColumn',4,...
            'RegisterBlockWidth',4,...
            'CacheBlockSizeM',96,...
            'CacheBlockSizeK',144,...
            'CacheBlockSizeN',180,...
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
