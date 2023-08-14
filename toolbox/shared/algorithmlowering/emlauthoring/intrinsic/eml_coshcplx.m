function y=eml_coshcplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=complex(eml_scalar_cosh(x),0);
        else
            y=eml_scalar_cosh(x);
        end
    end
