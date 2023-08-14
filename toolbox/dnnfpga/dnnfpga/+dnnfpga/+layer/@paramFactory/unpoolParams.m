function param=unpoolParams(this,layer,fpgaParamLayers,pvpairs)




    param=fpgaParamLayers{end};
    if(isfield(pvpairs,'hasunpool'))
        hasUnpool=pvpairs.hasunpool;
    else
        hasUnpool=false;
    end

    if(isfield(pvpairs,'unpoolremainder'))
        unpoolRemainder=pvpairs.unpoolremainder;
    else
        unpoolRemainder=[0;0];
    end



    isLayerUnpool=hasUnpool&&(numel(fpgaParamLayers)==2)&&...
    isa(layer,'nnet.cnn.layer.Convolution2DLayer');

    if isLayerUnpool
        param.type='FPGA_Unpool2D';
        param.unpoolRemainder=unpoolRemainder;
        param.paddingMode=[0;0;0;0];
        param.outputSize=[param.origImgSize(1:2).*param.origOpSizeValue(1:2)+param.unpoolRemainder;param.inputFeatureNum].';
    end

end

