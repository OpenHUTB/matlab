function varargout=dlnetworkPredict(net,inputs,inputFormats,predictEnabled,activationLayers)



%#codegen
    coder.allowpcode('plain');
    coder.inline('always');
    coder.internal.prefer_const(inputFormats,predictEnabled,activationLayers);



    inputDlArrays=cell(size(inputs));
    coder.unroll();
    for i=1:numel(inputs)
        inputDlArrays{i}=dlarray(inputs{i},coder.const(inputFormats{i}));
    end




    if coder.const(predictEnabled)
        if coder.target('MATLAB')
            outputLayers=[net.OutputNames,activationLayers];
        else

            outputLayers=coder.const(iConcatenateOutputsNames(net.OutputNames,activationLayers));
        end
    else
        outputLayers=activationLayers;
    end


    dlArrayOutputs=cell(size(outputLayers));
    [dlArrayOutputs{:}]=predict(net,inputDlArrays{:},'Outputs',coder.const(outputLayers));


    if coder.target('MATLAB')

        varargout=cell(size(outputLayers));
    end


    coder.unroll();
    for i=1:length(dlArrayOutputs)
        varargout{i}=extractdata(dlArrayOutputs{i});
    end

end


function outputLayers=iConcatenateOutputsNames(outputNames,activationLayers)
    coder.inline('always');
    totalOutputs=numel(outputNames)+numel(activationLayers);
    outputLayers=cell(totalOutputs,1);
    activationLayersCounter=1;
    coder.unroll();
    for i=1:totalOutputs
        if i<=numel(outputNames)
            outputLayers{i}=outputNames{i};
        else
            outputLayers{i}=activationLayers{activationLayersCounter};
            activationLayersCounter=activationLayersCounter+1;
        end
    end
    outputLayers=coder.const(outputLayers);
end
