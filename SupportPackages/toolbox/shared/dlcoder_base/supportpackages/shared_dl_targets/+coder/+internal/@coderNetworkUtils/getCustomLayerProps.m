function layerProps=getCustomLayerProps(networkInfo)
























    coder.allowpcode('plain');

    layerProps=struct();
    numCustomLayers=0;


    layers=networkInfo.SortedLayers;


    numLayers=numel(layers);


    layerToCompMapInfo=dltargets.internal.LayerToCompMapInfo();
    layerToCompMap=layerToCompMapInfo.getLayersToCompMap();

    layerProps.layerObj={};
    layerProps.layerIdx=zeros;

    for idx=1:numLayers
        layer=layers(idx);



        if dltargets.internal.checkIfCustomLayer(layer)&&~dltargets.internal.checkIfOutputLayer(layer)
            if~isKey(layerToCompMap,class(layer))

                numCustomLayers=numCustomLayers+1;
                layerInfo=networkInfo.getLayerInfo(layer.Name);
                layerProps.layerIdx(numCustomLayers)=idx;
                layerProps.layerObj{numCustomLayers}=layer;
                layerProps.inputSizes{numCustomLayers}=layerInfo.inputSizes;
                layerProps.hasSequenceInput{numCustomLayers}=layerInfo.hasSequenceInput;
                layerProps.isInputFormattedDlarray(numCustomLayers)=isa(layer,'nnet.layer.Formattable');



                layerProps.inputFormats{numCustomLayers}=layerInfo.inputFormats;
                layerProps.outputFormats{numCustomLayers}=layerInfo.outputFormats;
                layerProps.hasDlarrayInputs(numCustomLayers)=layerInfo.hasDlarrayInputs;

            end
        end
    end

    layerProps.numCustomLayers=numCustomLayers;

end
