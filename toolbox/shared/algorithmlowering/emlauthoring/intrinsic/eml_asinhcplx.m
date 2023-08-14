function y=eml_asinhcplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=complex(eml_scalar_asinh(x),0);
        else
            y=eml_scalar_asinh(x);
        end
    end
