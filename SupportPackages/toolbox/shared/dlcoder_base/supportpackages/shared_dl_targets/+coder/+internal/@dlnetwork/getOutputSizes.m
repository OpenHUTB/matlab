













function[outputSizes,outputFormats]=getOutputSizes(dlnet,inputSizes,inputFormats,outputNames)




    assert(isa(dlnet,'dlnetwork'));


    numInputs=numel(inputSizes);
    inputs=cell(1,numInputs);
    for i=1:numInputs
        inputs{i}=dlarray(ones(inputSizes{i}),inputFormats{i});
    end

    if isempty(outputNames)
        outputNames=dlnet.OutputNames;
    end

    [outputSizes,outputFormats]=deep.internal.sdk.forwardDataAttributes(dlnet,inputs{:},'Outputs',outputNames);

end
