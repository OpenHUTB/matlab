function y=eml_coscplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=complex(eml_scalar_cos(x),0);
        else
            y=eml_scalar_cos(x);
        end
    end
