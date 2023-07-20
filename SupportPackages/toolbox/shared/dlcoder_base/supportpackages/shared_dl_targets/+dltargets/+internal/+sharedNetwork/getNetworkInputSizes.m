function inputSizes=getNetworkInputSizes(net,inputLayers)













    if isdlnetwork(net)&&~isempty(net.getExampleInputs)
        exampleInputs=net.getExampleInputs;



        inputSizes=cellfun(@(exampleInput)size(exampleInput),exampleInputs,UniformOutput=false);
        for i=1:numel(exampleInputs)
            timeDimIdx=finddim(exampleInputs{i},'T');
            batchDimIdx=finddim(exampleInputs{i},'B');
            indicesOfDimsToRemove=[timeDimIdx,batchDimIdx];


            inputSizes{i}(indicesOfDimsToRemove)=[];
        end
    else
        inputSizes=cellfun(@(layer)layer.InputSize,inputLayers,UniformOutput=false);
    end
end


function tf=isdlnetwork(net)
    tf=isa(net,'dlnetwork');
end