
function inputSizes=getNetworkInputSizes(net,batchSize)
    if nargin<2
        batchSize=1;
    end


    inputLayers=dltargets.internal.getIOLayers(net);







    inputSizes=cellfun(@(x)x.InputSize,inputLayers,'UniformOutput',false);

    inputSizes=dltargets.internal.formatInputSizes(inputSizes,batchSize);
end