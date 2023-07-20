function y=eml_acoscplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=eml_scalar_acos(complex(x,0));
        else
            y=eml_scalar_acos(x);
        end
    end
