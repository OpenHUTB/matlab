function param=commonConvParams(this,layer,previousLayerParam)






    param=struct;
    param.phase=layer.Name;
    param.frontendLayers={layer.Name};

    param.WL=1;
    param.reLUScaleExp=0;
    param.rescaleExp=0;
    param.reLUValue=0;
    param.avgMultiplier=1;
    param.weights=layer.Weights;
    param.bias=layer.Bias;

    param.type='FPGA_Conv2D';
    param.unpoolRemainder=[0;0];

    param.weights=layer.Weights;
    param.bias=layer.Bias;

    param.convSplitMode=0;


    param.strideMode=layer.Stride(2);

    param.stridePhase=[0;0];
    param.reLUMode=0;


    param.paddingMode=[layer.PaddingSize(1);layer.PaddingSize(2);layer.PaddingSize(3);layer.PaddingSize(4)];

    param.dilationMode=[layer.DilationFactor(1),layer.DilationFactor(2)];
    param.lrnLocalSize=5;
    param.lrnAlpha=0.0001/param.lrnLocalSize;
    param.lrnBeta=0.75;
    param.lrnK=1;
    param.lrnFeaturePadding=fix(param.lrnLocalSize/2);

    param.firstWritePos=[];
    param.finalWriteSize=[];

    param.outputFeatureNum=size(param.weights,4);
    param.origOpSizeValue=[size(param.weights,1);size(param.weights,2);1];

    param.smallLayerEn=0;
    param.maxpoolType=0;


    param.snLayer=layer;
    if(isa(previousLayerParam.snLayer,'nnet.cnn.layer.ImageInputLayer'))
        InputImgSize=previousLayerParam.snLayer.InputSize;
        param.inputFeatureNum=InputImgSize(3);
        param.origImgSize=[InputImgSize(1);InputImgSize(2);1];
    else
        inputSize=dnnfpga.compiler.propagateConvLayerOutputSize(previousLayerParam);
        param.inputFeatureNum=previousLayerParam.outputFeatureNum;
        param.origImgSize=[inputSize(1);inputSize(2);1];
    end
end

