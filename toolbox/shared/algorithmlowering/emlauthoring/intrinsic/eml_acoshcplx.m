function y=eml_acoshcplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=eml_scalar_acosh(complex(x,0));
        else
            y=eml_scalar_acosh(x);
        end
    end
