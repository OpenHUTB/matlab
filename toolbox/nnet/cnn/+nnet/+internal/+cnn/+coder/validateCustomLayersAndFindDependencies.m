function customLayerFiles=validateCustomLayersAndFindDependencies(network)





    layers=network.Layers;
    nLayers=numel(layers);
    customLayerFiles={};
    for i=1:nLayers
        if isa(layers(i),"nnet.layer.Layer")
            customLayerClass=class(layers(i));
            currentCustomLayerFile=which(customLayerClass);
            if exist(currentCustomLayerFile,'file')
                layerWasAnalyzed=ismember(currentCustomLayerFile,customLayerFiles);
                if~layerWasAnalyzed

                    files=matlab.codetools.requiredFilesAndProducts(currentCustomLayerFile);
                    customLayerFiles=[customLayerFiles;files(:)];%#ok<AGROW>
                end
            else


                error(message('nnet_cnn:dlAccel:InvalidCustomLayer',customLayerClass))
            end
        end
    end
end
