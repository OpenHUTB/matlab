function layer_heights=calculateLayerZCoords(obj)
    metalLayerIndx=cellfun(@(x)isa(x,'antenna.Shape'),obj.Layers);
    dielectricLayerIndx=cellfun(@(x)isa(x,'dielectric'),obj.Layers);
    subThickness=cell2mat(arrayfun(@(x)(x.Thickness),obj.Substrate,'UniformOutput',false));
    if numel(metalLayerIndx)<=2&&~all(dielectricLayerIndx)
        layer_heights=[subThickness,0];
        layer_heights=layer_heights(metalLayerIndx);
    else
        mask=double(dielectricLayerIndx);
        mask(mask==1)=deal((fliplr(subThickness)));
        layer_heights=fliplr(cumsum(fliplr(mask)));
        layer_heights=layer_heights(metalLayerIndx);


    end
    if~size(layer_heights,1)==1

        layer_heights=layer_heights';
    end
end