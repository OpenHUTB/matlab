function param=commonFCParams(this,WL,layer,processor,fpgaParamLayers)




    param=struct;
    param.type='FPGA_FC';
    param.matrixSize=[layer.InputSize,layer.OutputSize];
    param.featureSize=0;
    param.gapMultiplier=1;
    param.reLUMode=0;
    param.reLUValue=0;
    param.reLUScaleExp=0;
    param.rescaleExp=0;
    param.phase=layer.Name;
    param.frontendLayers={layer.Name};







    param.fcOutputExp=0;
    param.fcInputExp=0;
    assert(~isempty(layer.Weights)&&~isempty(layer.Bias),'Input SeriesNetwork layer %d doesn''t have weights or bias.',numel(fpgaParamLayers)+1);

    Weights=layer.Weights;
    Bias=layer.Bias;
    [importedOp,importedBias]=dnnfpga.processorbase.fcProcessor.importOperator(Weights,Bias);
    param.weights=importedOp';
    param.bias=importedBias;
    param.WL=WL;
    param.numberOfPaddedZeros=0;
    param.denominatorAddressSizeMinusOne=0;
    param.iterCounterWLimit=processor.getCC.fcp.iterCounterWLimit;
    param.snLayer=layer;

end

