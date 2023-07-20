function param=populateConvLayerParamsFromData(param,weights,bias,input)



    param.inputFeatureNum=size(input,3);
    param.outputFeatureNum=size(weights,4);
    param.origOpSizeValue=[size(weights,1);size(weights,2);1];
    param.origImgSize=[size(input,1);size(input,2);1];
    if(isfield(param,'stridePhase')&&isfield(param,'dilationMode'))
        resultSize=dnnfpga.processorbase.conv2Processor.getResultSize(size(input)',size(weights)',param.paddingMode,param.strideMode,param.stridePhase,param.dilationMode);
        param.firstWritePos=[0;resultSize(1);0;resultSize(2)];
        param.finalWriteSize=resultSize;
    else
        param.firstWritePos=[-1,-1,-1,-1];
        param.finalWriteSize=[-1,-1];
    end
    param.weights=weights;
    param.bias=bias;
    param.type='FPGA_Conv2D';
end
