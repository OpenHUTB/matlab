function y=eml_tanhcplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=complex(eml_scalar_tanh(x),0);
        else
            y=eml_scalar_tanh(x);
        end
    end
