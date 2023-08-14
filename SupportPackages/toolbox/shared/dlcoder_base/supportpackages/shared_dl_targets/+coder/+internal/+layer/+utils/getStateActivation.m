%#codegen
%#internal


function act=getStateActivation(activation)
    coder.allowpcode('plain');

    coder.inline('always');

    switch activation
    case 'tanh'
        act=@coder.internal.layer.tanh;
    case 'softsign'
        act=@coder.internal.layer.softsign;
    end
end


