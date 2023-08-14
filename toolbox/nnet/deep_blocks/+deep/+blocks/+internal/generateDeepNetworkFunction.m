function functionText=generateDeepNetworkFunction(...
    block,...
    networkToLoad,...
    numInputLayers,...
    numPredictOutputLayers,...
    numActivationOutputLayers,...
    simSupported,...
    isDlNetwork,...
    miniBatchSize,...
    predictEnabled,...
    inputFormats,...
    activationLayers)





    inputs=strings(1,numInputLayers);
    inputSizes=strings(1,numInputLayers);
    inputTypes=strings(1,numInputLayers);

    for i=1:numInputLayers
        input="in_"+num2str(i);
        inputs(i)=input;
        inputSizes(i)="size("+input+")";
        inputTypes(i)="class("+input+")";
    end

    numOutputs=numPredictOutputLayers+numActivationOutputLayers;

    if numOutputs>0
        outputs=strings(1,numOutputs);
    else
        outputs="";
    end

    for i=1:numOutputs
        suffix="";
        if i<=numPredictOutputLayers
            suffix=deep.blocks.internal.getPredictOutputKey();
        end
        outputs(i)="out_"+num2str(i)+suffix;
    end

    inputsString="{"+join(inputs,", ")+"}";
    inputSizesString="{"+join(inputSizes,", ")+"}";
    inputTypesString="{"+join(inputTypes,", ")+"}";
    outputsString=join(outputs,", ");
    outputsString="["+outputsString+"]";

    if numOutputs>0
        signature="function "+outputsString+" = deepNetwork("+inputsString+")";
    else
        signature="function deepNetwork("+inputsString+")";
    end

    inputFormatsString=deep.blocks.internal.cell2str(inputFormats);
    activationsString=deep.blocks.internal.cell2str(activationLayers);

    [useExtrinsicLines,extrinsicVar]=deep.blocks.internal.generateUseExtrinsicCode(simSupported);


    innerInputsString=join([...
    inputsString,...
    inputSizesString,...
    inputTypesString,...
    deep.blocks.internal.removeNewlines("coder.const("""+block+""")"),...
    "'"+networkToLoad+"'",...
    extrinsicVar,...
    string(isDlNetwork),...
    miniBatchSize,...
    string(predictEnabled),...
    inputFormatsString,...
    activationsString],", ");
    if numOutputs>0
        call=outputsString+" = deep.blocks.internal.deepNetwork("+innerInputsString+");";
    else
        call="deep.blocks.internal.deepNetwork("+innerInputsString+");";
    end


    functionText=join([...
    signature,...
    useExtrinsicLines,...
    call,...
    "end"],newline);
end
