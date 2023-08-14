function hasSequenceInput=checkNetworkForSequenceInput(net,inputLayers)












    if(~isdlnetwork(net))||(isdlnetwork(net)&&isempty(net.getExampleInputs))

        hasSequenceInput=any(cellfun(@(layer)isa(layer,'nnet.cnn.layer.SequenceInputLayer'),inputLayers));
    else
        assert(isdlnetwork(net));
        assert(net.Initialized);

        hasSequenceInput=false;
        exampleInputs=net.getExampleInputs;
        for i=1:numel(exampleInputs)
            hasSequenceInput=~isempty(finddim(exampleInputs{i},'T'));
            if hasSequenceInput
                break;
            end
        end
    end
end

function tf=isdlnetwork(net)
    tf=isa(net,'dlnetwork');
end