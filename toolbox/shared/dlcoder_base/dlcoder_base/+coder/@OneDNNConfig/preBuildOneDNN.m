






function preBuildOneDNN(obj,codeConfig)


    if(obj.Instrumentation)
        obj.OptimizationConfig.ConvAddReLUFusion=false;
        obj.OptimizationConfig.ConvAddClippedReLUFusion=false;
        obj.OptimizationConfig.ConvAddLeakyReLUFusion=false;
        obj.OptimizationConfig.ConvAddTanhFusion=false;
        obj.OptimizationConfig.ConvAddELUFusion=false;
        obj.OptimizationConfig.ConvAddSigmoidFusion=false;

        obj.OptimizationConfig.HorizontalConvFusion=false;
        obj.OptimizationConfig.StrideOptimization=false;
        obj.OptimizationConfig.RNNLayerFusion=false;


        obj.OptimizationConfig.ConvClippedReLUFusion=false;
        obj.OptimizationConfig.ConvTanhFusion=false;
        obj.OptimizationConfig.ConvSigmoidFusion=false;
        obj.OptimizationConfig.ConvLeakyReLUFusion=false;
        obj.OptimizationConfig.ConvELUFusion=false;
    end

    if(obj.UseShippingLibs==-1)
        if isa(codeConfig,'coder.MexCodeConfig')
            obj.UseShippingLibs=1;
        else
            obj.UseShippingLibs=0;
        end
    end
end
