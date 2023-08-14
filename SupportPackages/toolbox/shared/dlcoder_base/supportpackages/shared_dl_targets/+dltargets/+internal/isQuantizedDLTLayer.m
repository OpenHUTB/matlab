function isQuantized=isQuantizedDLTLayer(quantizationSpecification,layerName)




    isQuantized=false;
    if isKey(quantizationSpecification,layerName)
        layerQuantizationSpec=quantizationSpecification(layerName);
        isQuantized=layerQuantizationSpec.isQuantizationEnabled;
    end
