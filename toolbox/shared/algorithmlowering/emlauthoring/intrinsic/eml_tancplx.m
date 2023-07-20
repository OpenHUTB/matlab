function y=eml_tancplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=complex(eml_scalar_tan(x),0);
        else
            y=eml_scalar_tan(x);
        end
    end
