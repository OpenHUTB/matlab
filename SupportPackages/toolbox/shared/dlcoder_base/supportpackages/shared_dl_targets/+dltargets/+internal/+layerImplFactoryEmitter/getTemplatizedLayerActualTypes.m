

function actualTypes=getTemplatizedLayerActualTypes(layerString)





    persistent layerStringToTemplateActualsMap;
    if isempty(layerStringToTemplateActualsMap)
        layerStringToTemplateActualsMap=iPopulateLayerStringToTemplateActualsMap();
    end

    assert(layerStringToTemplateActualsMap.Count>0,...
    'layerString-to-templateActuals map is empty');
    assert(isKey(layerStringToTemplateActualsMap,layerString),...
    'layerString for templatized layer was not found in the layerStringToTemplateActualsMap');

    actualTypes=layerStringToTemplateActualsMap(layerString);
end

function layerStringToTemplateActualsMap=iPopulateLayerStringToTemplateActualsMap()
    layerStringToTemplateActualsMap=containers.Map;











    layerStringToTemplateActualsMap('Int8Convolution')=...
    {{'signed char','float'},{'signed char','signed char'}};
    layerStringToTemplateActualsMap('Int8FC')=...
    {{'signed char','float'},{'signed char','signed char'}};
end
