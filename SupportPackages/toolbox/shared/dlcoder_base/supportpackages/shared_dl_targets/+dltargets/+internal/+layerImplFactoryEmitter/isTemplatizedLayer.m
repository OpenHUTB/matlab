
function isTemplatized=isTemplatizedLayer(layerString)





    templatizedLayers={'Int8Convolution','Int8FC'};

    isTemplatized=any(strcmp(layerString,templatizedLayers));
end
