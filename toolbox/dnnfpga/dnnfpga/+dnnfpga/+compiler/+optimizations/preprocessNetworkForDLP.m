










function[xformedNet,changed]=preprocessNetworkForDLP(net,dataTransferNum)
    import dnnfpga.compiler.optimizations.*

    lgraph=layerGraph(net);

    changed=false;


    layers=lgraph.Layers';
    for layer=layers
        if(isa(layer,'nnet.cnn.layer.SequenceInputLayer')||isa(layer,'nnet.cnn.layer.FeatureInputLayer'))
            changed=true;
            r=imageInputLayer([1,1,layer.InputSize],'Name',layer.Name,...
            'Normalization',layer.Normalization,...
            'NormalizationDimension',layer.NormalizationDimension);
            lgraph=LayerGraphSupport.replaceLayer(lgraph,r,layer.Name);

        end
    end

    layers=lgraph.Layers';

    for layer=layers
        if dnnfpga.macros.Macros.isMacro(layer)
            changed=true;
            macroNet=dnnfpga.macros.Macros.createNet(layer,dataTransferNum);
            lgraph=LayerGraphSupport.flattenIntoLayerGraph(layer,...
            layerGraph(macroNet),...
            lgraph);
        end
    end

    if changed
        layers=lgraph.Layers';

        for layer=layers

            [layerCopy,lchanged]=LayerGraphSupport.copyLayer(layer);
            if lchanged
                changed=true;


                lgraph=LayerGraphSupport.replaceLayer(lgraph,layerCopy);
            end
        end
    end
    if changed
        xformedNet=assembleNetwork(lgraph);
    else
        xformedNet=net;
    end
end


