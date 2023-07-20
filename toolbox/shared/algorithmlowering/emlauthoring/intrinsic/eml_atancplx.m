function y=eml_atancplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=complex(eml_scalar_atan(x),0);
        else
            y=eml_scalar_atan(x);
        end
    end
