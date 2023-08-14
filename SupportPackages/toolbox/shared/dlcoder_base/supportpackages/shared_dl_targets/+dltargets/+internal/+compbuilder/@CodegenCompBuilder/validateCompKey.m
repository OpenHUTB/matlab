function validateCompKey(layer,converter,comp)


    translatedCompKey=comp.getCompKey();
    layerBuilderName=dltargets.internal.compbuilder.CodegenCompBuilder.getCompBuilderName(layer,converter);
    getCompKeyMethod=[layerBuilderName,'.','getCompKey'];
    compKey=feval(getCompKeyMethod,layer);

    if~isequal(translatedCompKey,compKey)

        assert(strcmpi(compKey,'gpucoder.fc_layer_comp')&&...
        strcmpi(translatedCompKey,'gpucoder.conv_layer_comp'),...
        'Mismatch in expected and actual components');
    end
end
