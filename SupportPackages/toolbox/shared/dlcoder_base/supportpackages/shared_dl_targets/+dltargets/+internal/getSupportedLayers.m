
function layerNames=getSupportedLayers(targetName,returnAllCustomLayersOnPath)


















    if nargin<2
        returnAllCustomLayersOnPath=false;
    end


    targetName=lower(char(targetName));


    layerKeys=dltargets.internal.getSupportedLayerTypes(targetName);

    classList=dltargets.internal.utils.GetSupportedLayersUtils.getClassListOnPath(returnAllCustomLayersOnPath);


    customLayerClassesOnPath=dltargets.internal.getCustomLayersOnPath(returnAllCustomLayersOnPath,classList);

    customLayerClassesOnPath([customLayerClassesOnPath.Abstract])=[];


    fromRedirectedClassOnPath=dltargets.internal.getFromRedirectedLayersOnPath(returnAllCustomLayersOnPath,classList);
    customLayerClassesOnPath=[customLayerClassesOnPath;fromRedirectedClassOnPath];


    supportedCustomLayerKeys=dltargets.internal.getCustomLayersSupportedForCodegen(customLayerClassesOnPath,targetName);
    if~isempty(supportedCustomLayerKeys)
        supportedCustomLayerKeys=filterNonUserVisibleCustomLayers(supportedCustomLayerKeys,targetName);
    end


    layerToCompMapInfo=dltargets.internal.LayerToCompMapInfo();
    handCodedCustomLayers=keys(layerToCompMapInfo.getCustomLayersToCompMap());


    layerKeys=filterHandCodedCustomLayersNotOnPath(layerKeys,handCodedCustomLayers,customLayerClassesOnPath);



    layerKeys=union(layerKeys,supportedCustomLayerKeys);

    layerNames=dltargets.internal.utils.GetSupportedLayersUtils.formatLayerClassNames(layerKeys);
end

function filteredLayerNames=filterHandCodedCustomLayersNotOnPath(layerKeys,handCodedCustomLayers,customLayerClassesOnPath)





    targetSpecificHandCodedCustomLayerIndices=contains(layerKeys,handCodedCustomLayers);
    nonCustomLayers=layerKeys(~targetSpecificHandCodedCustomLayerIndices);
    handCodedCustomLayers=layerKeys(targetSpecificHandCodedCustomLayerIndices);


    customLayerClassNamesOnPath=cell(1,numel(customLayerClassesOnPath));
    [customLayerClassNamesOnPath{:}]=customLayerClassesOnPath.Name;
    handCodedCustomLayersOnPath=handCodedCustomLayers(contains(handCodedCustomLayers,customLayerClassNamesOnPath));



    filteredLayerNames=[nonCustomLayers,handCodedCustomLayersOnPath];
end

function filteredLayerNames=filterNonUserVisibleCustomLayers(layerKeys,targetName)


    nonUserVisibleLayerClassTypes={'SoftplusLayerBase'};
    if~strcmp(targetName,"none")



        nonUserVisibleLayerClassTypes{end+1}='LSTMProjectedLayer';
    end

    filteredLayerNames=layerKeys(~contains(layerKeys,nonUserVisibleLayerClassTypes));
end

