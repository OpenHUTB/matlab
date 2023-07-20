function param=commonPoolParams(this,WL,layer,processor,previousLayerParam,pvpairs,net)




    param=struct;
    param.phase=layer.Name;
    param.frontendLayers={layer.Name};
    param.convSplitMode=0;
    strideLimit=dnnfpga.compiler.processorStrideLimit(processor);
    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSupportedStride(layer.Stride(1),layer.Name,strideLimit-1);
    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForSymmetricStride(layer.Stride(1),layer.Stride(2),layer.Name);
    param.strideMode=layer.Stride(2);
    param.stridePhase=[0;0];


    param.paddingMode=double([layer.PaddingSize(1);layer.PaddingSize(2);layer.PaddingSize(3);layer.PaddingSize(4)]);
    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForPaddingSize(param.paddingMode,layer.Name,2);
    param.reLUValue=0;
    param.rescaleExp=0;
    param.reLUScaleExp=0;
    param.dilationMode=1;
    param.lrnLocalSize=5;
    param.lrnAlpha=0.0001/param.lrnLocalSize;
    param.lrnBeta=0.75;
    param.lrnK=1;
    param.lrnFeaturePadding=fix(param.lrnLocalSize/2);

    if(isfield(pvpairs,'maxpooltype'))
        maxpoolType=pvpairs.maxpooltype;
    else
        maxpoolType=0;
    end

    param.maxpoolType=maxpoolType;
    param.unpoolRemainder=[0;0];
    param.snLayer=layer;

    existedOtherLayers=dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkNetworkExistsOtherLayers(net,layer);
    if(~existedOtherLayers)
        if(previousLayerParam.hasTrueInputLayer)


            msg=message('dnnfpga:dnnfpgacompiler:UnsupportedNoConv');
            error(msg);
        else
            inputSize=previousLayerParam.snLayer.InputSize;
            param.inputFeatureNum=inputSize(3);
            param.outputFeatureNum=inputSize(3);
        end
    else
        if(isa(previousLayerParam.snLayer,'nnet.cnn.layer.ImageInputLayer'))
            inputSize=previousLayerParam.origImgSize;
            param.inputFeatureNum=InputImgSize(3);
            param.outputFeatureNum=InputImgSize(3);
        else
            inputSize=dnnfpga.compiler.propagateConvLayerOutputSize(previousLayerParam);
            param.inputFeatureNum=previousLayerParam.outputFeatureNum;
            param.outputFeatureNum=previousLayerParam.outputFeatureNum;
        end
    end

    param.origImgSize=[inputSize(1);inputSize(2);1];
    param.origOpSizeValue=[layer.PoolSize(1);layer.PoolSize(2);1];

    filterSizeLimit=dnnfpga.compiler.processorPoolSizeLimit(processor);
    dnnfpga.compiler.seriesNetworkAndPIRFrontend.checkForFilterSize(param.origOpSizeValue,layer.Name,1,filterSizeLimit);
    param.firstWritePos=[];
    param.finalWriteSize=[];
    param.correspondingAlexnetLayer=i;
    avgMultiplier=1/(param.origOpSizeValue(1)*param.origOpSizeValue(2));
    param.avgMultiplier=avgMultiplier;
    param.WL=WL;
    param.type='FPGA_Maxpool2D';


    outImageSize1=dnnfpga.compiler.propagateConvLayerOutputSize(param);

    if isfield(processor.getBCC,'convp')
        threadNumber=processor.getBCC.convp.conv.threadNumLimit;
    else
        threadNumber=processor.getBCC.conv.threadNumLimit;
    end
    outImageSize1=[outImageSize1(1),outImageSize1(2),ceil(param.outputFeatureNum/threadNumber)];











    if(prod(outImageSize1)<26)

        param.smallLayerEn=1;
    else
        param.smallLayerEn=0;
    end

end

