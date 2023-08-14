














function exampleSequenceLengths=getExampleSequenceLengths(net)
    mustBeA(net,'dlnetwork');
    numInputLayers=numel(net.InputNames);
    exampleSequenceLengths=ones(numInputLayers,1);

    exampleInputs=net.getExampleInputs();
    if~isempty(exampleInputs)




        for i=1:numInputLayers
            exampleInput=exampleInputs{i};
            timeDimension=finddim(exampleInput,'T');
            if~isempty(timeDimension)
                exampleSequenceLengths(i)=size(exampleInput,timeDimension);
            end
        end
    else



        inputLayers=dltargets.internal.getIOLayers(net);
        for i=1:numel(numInputLayers)
            inputLayer=inputLayers{i};
            if isa(inputLayer,'nnet.cnn.layer.SequenceInputLayer')
                exampleSequenceLengths(i)=inputLayer.MinLength;
            end
        end
    end
end