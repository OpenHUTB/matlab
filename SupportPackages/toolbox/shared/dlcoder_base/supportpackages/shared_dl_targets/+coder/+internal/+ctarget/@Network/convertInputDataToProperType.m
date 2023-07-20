function currentLayerInput=convertInputDataToProperType(obj,isQuantizedLayer,prevLayerOutput)%#ok






%#codegen


    coder.allowpcode('plain');
    coder.inline('always');

    coder.internal.prefer_const(isQuantizedLayer);

    if~coder.const(isQuantizedLayer)&&~isa(prevLayerOutput,'single')


        currentLayerInput=coder.internal.layer.elementwiseOperation(@single,prevLayerOutput,single(1));
    else





        currentLayerInput=prevLayerOutput;
    end
