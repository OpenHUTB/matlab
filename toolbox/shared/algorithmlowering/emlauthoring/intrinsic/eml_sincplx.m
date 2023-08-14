function y=eml_sincplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=complex(eml_scalar_sin(x),0);
        else
            y=eml_scalar_sin(x);
        end
    end
