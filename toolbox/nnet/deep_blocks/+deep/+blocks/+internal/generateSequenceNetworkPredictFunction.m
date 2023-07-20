function functionText=generateSequenceNetworkPredictFunction(...
    block,...
    networkToLoad,...
    numInputLayers,...
    numOutputLayers,...
    simSupported,...
    isDlNetwork,...
    inputFormats)





    inputs=strings(1,numInputLayers);
    inputSizes=strings(1,numInputLayers);
    inputTypes=strings(1,numInputLayers);

    for i=1:numInputLayers
        input="in_"+num2str(i);
        inputs(i)=input;
        inputSizes(i)="size("+input+")";
        inputTypes(i)="class("+input+")";
    end

    outputs=strings(1,numOutputLayers);
    suffix=deep.blocks.internal.getPredictOutputKey();
    for i=1:numOutputLayers
        outputs(i)="out_"+num2str(i)+suffix;
    end

    inputsString="{"+join(inputs,", ")+"}";
    inputSizesString="{"+join(inputSizes,", ")+"}";
    inputTypesString="{"+join(inputTypes,", ")+"}";
    outputsString=join(outputs,", ");
    outputsString="["+outputsString+"]";

    signature="function "+outputsString+" = sequenceNetworkPredict("+inputsString+")";


    inputFormatsString=deep.blocks.internal.cell2str(inputFormats);


    [useExtrinsicLines,extrinsicVar]=deep.blocks.internal.generateUseExtrinsicCode(simSupported);

    innerInputsString=join([...
    inputsString,...
    inputSizesString,...
    inputTypesString,...
    deep.blocks.internal.removeNewlines("coder.const("""+block+""")"),...
    "'"+networkToLoad+"'",...
    extrinsicVar,...
    string(isDlNetwork),...
    inputFormatsString],", ");

    call=outputsString+" = deep.blocks.internal.sequenceNetworkPredict("+innerInputsString+");";


    functionText=join([...
    signature,...
    useExtrinsicLines,...
    call,...
    "end"],newline);
end
