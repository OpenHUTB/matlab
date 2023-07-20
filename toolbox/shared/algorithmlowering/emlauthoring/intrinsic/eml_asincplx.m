function y=eml_asincplx(x)

%#codegen

    coder.allowpcode('plain');

    if isfloat(x)
        if isreal(x)
            y=eml_scalar_asin(complex(x,0));
        else
            y=eml_scalar_asin(x);
        end
    end

