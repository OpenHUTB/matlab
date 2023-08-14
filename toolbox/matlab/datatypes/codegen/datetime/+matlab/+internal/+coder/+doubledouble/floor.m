function b=floor(a)%#codegen



    coder.allowpcode('plain');

    ahi=real(a);
    alo=imag(a);

    b=complex(floor(ahi),0);


    for j=1:numel(a)
        if b(j)==real(ahi(j))
            b(j)=matlab.internal.coder.doubledouble.addToLoAndAdjust(b(j),floor(alo(j)));
        end
    end

