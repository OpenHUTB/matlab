function setOutputCompProperties(outputcomp,outputNodeName,networkInfo)




    assert(strcmp(outputcomp.getCompKey,'gpucoder.output_layer_comp'));

    outputNamesIdx=networkInfo.OutputLayerNameToOutputNamesIdxMap(outputNodeName);


    outputcomp.setOutputNamesIndex(int32(outputNamesIdx));


end
