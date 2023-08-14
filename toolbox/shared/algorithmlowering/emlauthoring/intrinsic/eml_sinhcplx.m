function y=eml_sinhcplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=complex(eml_scalar_sinh(x),0);
        else
            y=eml_scalar_sinh(x);
        end
    end
