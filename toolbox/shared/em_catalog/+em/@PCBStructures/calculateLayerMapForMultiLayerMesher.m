function mapValue=calculateLayerMapForMultiLayerMesher(obj,numLayers)



    metalLayerIndx=find(cellfun(@(x)isa(x,'antenna.Shape'),obj.Layers));
    dielectricLayerIndx=find(cellfun(@(x)isa(x,'dielectric'),obj.Layers));
    NumTotalLayers=numel(obj.Layers);


    if NumTotalLayers==1
        mapValue=1;
        return;
    end





    if isempty(dielectricLayerIndx)
        metalLayerIndx(end)=metalLayerIndx(end)+1;
        dielectricLayerIndx=2;
        NumTotalLayers=3;
    end


    if metalLayerIndx(1)==1&&metalLayerIndx(end)==NumTotalLayers
        layerCombiningMask=zeros(1,NumTotalLayers);
        layerCombiningMask(dielectricLayerIndx)=fliplr(numLayers);
        combinedLayers=fliplr(cumsum(fliplr(layerCombiningMask)));
        mapValue=fliplr(combinedLayers(metalLayerIndx));

    elseif dielectricLayerIndx(1)==1&&dielectricLayerIndx(end)==NumTotalLayers
        layerCombiningMask=zeros(1,NumTotalLayers);
        layerCombiningMask(dielectricLayerIndx)=fliplr(numLayers);
        combinedLayers=fliplr(cumsum(fliplr(layerCombiningMask)));
        mapValue=fliplr(combinedLayers(metalLayerIndx));

    elseif metalLayerIndx(1)==1&&dielectricLayerIndx(end)==NumTotalLayers
        layerCombiningMask=zeros(1,NumTotalLayers);
        layerCombiningMask(dielectricLayerIndx)=fliplr(numLayers);
        combinedLayers=fliplr(cumsum(fliplr(layerCombiningMask)));
        mapValue=fliplr(combinedLayers(metalLayerIndx));


    elseif dielectricLayerIndx(1)==1&&metalLayerIndx(end)==NumTotalLayers
        layerCombiningMask=zeros(1,NumTotalLayers);
        layerCombiningMask(dielectricLayerIndx)=fliplr(numLayers);
        combinedLayers=fliplr(cumsum(fliplr(layerCombiningMask)));
        mapValue=fliplr(combinedLayers(metalLayerIndx));

    end
