function c=divide(a,b)%#codegen




    coder.allowpcode('plain');


    coder.internal.errorIf(~isreal(b),'MATLAB:datetime:DoubleDoubleAssertionCodegen')

    ahi=real(a);

    c=complex(ahi./b,0);
    t=matlab.internal.coder.doubledouble.two_prod(real(c),b);
    thi=real(t);


    s=complex(zeros(size(t)),zeros(size(t)));

    for j=1:numel(a)
        if(ahi(j)~=thi(j))
            s(j)=matlab.internal.coder.doubledouble.two_diff(ahi(j),thi(j));
        end
    end
    s=s+1i*imag(a)-1i*imag(t);
    c=matlab.internal.coder.doubledouble.addToLoAndAdjust(c,(real(s)+imag(s))/b);
end
