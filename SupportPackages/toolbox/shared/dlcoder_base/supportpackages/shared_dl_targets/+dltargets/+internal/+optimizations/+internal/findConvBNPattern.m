function convBN=findConvBNPattern(name,nameToLayerObj,convBN,diG,transformProperties)
















    isFusable=iCheckIfFusable(name,nameToLayerObj,transformProperties,diG);
    if isFusable
        receivingLayer=successors(diG,name);
        assert(numel(receivingLayer)==1,...
        'Only the convolution layers with no fan out should check for recieving layer being Batch Norm');

        receivingLayer=receivingLayer{:};
        if isBatchNorm(receivingLayer,nameToLayerObj)
            convLayer=nameToLayerObj(name);
            batchNormLayer=nameToLayerObj(receivingLayer);


            modifiedConvLayer=dltargets.internal.optimizations.internal.modifyConvolutionLearnableParams(convLayer,batchNormLayer);
            convBN(name)={modifiedConvLayer,batchNormLayer};
        end
    end
end

function isBN=isBatchNorm(layerName,nameToLayerObj)
    isBN=isa(nameToLayerObj(layerName),'nnet.cnn.layer.BatchNormalizationLayer');
end

function isFusable=iCheckIfFusable(name,nameToLayerObj,transformProperties,diG)

    isConv=isa(nameToLayerObj(name),'nnet.cnn.layer.Convolution2DLayer')||...
    isa(nameToLayerObj(name),'nnet.cnn.layer.GroupedConvolution2DLayer');

    isActivationLayer=transformProperties.isActivationLayer(name);


    isFusable=~isActivationLayer&&isConv;


    isFusable=isFusable&&dltargets.internal.optimizations.internal.hasNoFanOut(diG,name);




    receivingLayer=successors(diG,name);
    isFusable=isFusable&&~isempty(receivingLayer);

end
