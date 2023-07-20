function out=activationsWrapper(network,inputs,layer)




    activationsOut=network.activations(inputs{:},layer);

    if iscell(activationsOut)
        out=activationsOut{:};
    else
        out=activationsOut;
    end

end