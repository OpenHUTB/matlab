function FCToConv=findFC(name,nameToLayerObj,FCToConv,diG,FCBNReLUxformFlag)

















    isFC=isa(nameToLayerObj(name),'nnet.cnn.layer.FullyConnectedLayer');
    if isFC
        FCLayer=nameToLayerObj(name);

        if FCBNReLUxformFlag
            if dltargets.internal.optimizations.internal.hasNoFanOut(diG,name)
                recievingLayer=successors(diG,name);
                assert(numel(recievingLayer)==1,...
                'Only the FC layers with no fan out should check for recieving layer being ReLU Layer');

                recievingLayer=recievingLayer{:};
                if isReLULayer(recievingLayer,nameToLayerObj)||isBatchNorm(recievingLayer,nameToLayerObj)

                    convLayer=dltargets.internal.optimizations.internal.createConvFromFC(FCLayer);
                    FCToConv(name)=convLayer;
                end
            end
        else

            convLayer=dltargets.internal.optimizations.internal.createConvFromFC(FCLayer);
            FCToConv(name)=convLayer;
        end

    end
end

function isReLU=isReLULayer(layerName,nameToLayerObj)
    isReLU=isa(nameToLayerObj(layerName),'nnet.cnn.layer.ReLULayer');
end

function isBN=isBatchNorm(layerName,nameToLayerObj)
    isBN=isa(nameToLayerObj(layerName),'nnet.cnn.layer.BatchNormalizationLayer');
end
