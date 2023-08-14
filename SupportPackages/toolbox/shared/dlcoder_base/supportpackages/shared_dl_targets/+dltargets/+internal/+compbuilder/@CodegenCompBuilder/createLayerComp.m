function comp=createLayerComp(layer,converter)




    compBuilderName=dltargets.internal.compbuilder.CodegenCompBuilder.getCompBuilderName(layer,converter);
    getCompKindMethod=[compBuilderName,'.','getCompKind'];
    compKind=feval(getCompKindMethod);

    comp=dltargets.internal.compbuilder.CodegenCompBuilder.addComponentToNetwork(converter.hN,compKind,layer.Name);


    getCompKeyMethod=[compBuilderName,'.','getCompKey'];
    comp.setCompKey(feval(getCompKeyMethod,layer));



    if isprop(layer,'NumInputs')
        for inportIdx=2:layer.NumInputs
            comp.addInPorts(inportIdx-1,1);
        end
    end

    if isprop(layer,'NumOutputs')
        for outportIdx=2:layer.NumOutputs
            comp.addOutPorts(outportIdx-1,1);
        end
    end


    layerInfoMap=converter.getLayerInfo(layer.Name);


    inputFormats=layerInfoMap.inputFormats;
    outputFormats=layerInfoMap.outputFormats;

    dltargets.internal.setCompDataFormats(comp,inputFormats,outputFormats);

end
