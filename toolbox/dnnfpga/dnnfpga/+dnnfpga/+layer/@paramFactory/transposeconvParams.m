function param=transposeconvParams(this,layer,fpgaParamLayers,pvpairs)




    param=fpgaParamLayers{end};
    if(isfield(pvpairs,'hastransposedconv'))
        hasTransposedConv=pvpairs.hastransposedconv;
    else
        hasTransposedConv=false;
    end



    isLayerTransposedConv=hasTransposedConv&&(numel(fpgaParamLayers)==2)&&isa(layer,'nnet.cnn.layer.Convolution2DLayer');

    if(isLayerTransposedConv)
        param.type='FPGA_TransposedConv';
        weightSize=size(layer.Weights);




















        param.unpoolRemainder=[1-weightSize(1);1-weightSize(2)];
        param.paddingMode=[0;0;0;0];
        param.outputSize=[param.origImgSize(1:2).*param.origOpSizeValue(1:2)+param.unpoolRemainder;param.inputFeatureNum].';
    end

    if(hasTransposedConv)
        param.ExpWeights=0;
        param.ExpBias=0;
    end

end

