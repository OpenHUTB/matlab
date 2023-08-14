













function SetSignalBufferSize(hN,networkInfo)


    sortedLayers=networkInfo.SortedLayers;

    noOfLayers=numel(sortedLayers);

    for iLayer=1:noOfLayers
        layerInfo=networkInfo.getLayerInfo(sortedLayers(iLayer).Name);
        comp=hN.Components(iLayer);
        for jOut=1:comp.getNumOut()
            outputNumElements=prod(layerInfo.outputSizes{jOut});
            comp.PirOutputSignals(jOut).setNumElements(outputNumElements);
        end
    end

end