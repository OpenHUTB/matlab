%#codegen
%#internal


function act=getGateActivation(activation)
    coder.allowpcode('plain');

    coder.inline('always');

    switch activation
    case 'sigmoid'
        act=@coder.internal.layer.sigmoid;
    case 'hard-sigmoid'
        act=@coder.internal.layer.hardsigmoid;
    end
end
