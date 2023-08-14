






function preBuildCuDNN(obj)

    if(strcmpi(obj.DataType,'int8')||...
        obj.Instrumentation)
        obj.OptimizationConfig.HorizontalConvFusion=false;
        obj.OptimizationConfig.StrideOptimization=false;



        obj.OptimizationConfig.ConvClippedReLUFusion=false;
        obj.OptimizationConfig.ConvTanhFusion=false;
        obj.OptimizationConfig.ConvSigmoidFusion=false;
        obj.OptimizationConfig.ConvLeakyReLUFusion=false;
        obj.OptimizationConfig.ConvELUFusion=false;

        obj.OptimizationConfig.ConvAddClippedReLUFusion=false;
        obj.OptimizationConfig.ConvAddLeakyReLUFusion=false;
        obj.OptimizationConfig.ConvAddTanhFusion=false;
        obj.OptimizationConfig.ConvAddELUFusion=false;
        obj.OptimizationConfig.ConvAddSigmoidFusion=false;

    end
end
