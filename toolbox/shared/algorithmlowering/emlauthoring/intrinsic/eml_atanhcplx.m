function y=eml_atanhcplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=eml_scalar_atanh(complex(x,0));
        else
            y=eml_scalar_atanh(x);
        end
    end
