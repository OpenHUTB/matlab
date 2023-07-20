function coeffs=getCICFIRCoefficients(~,N,Fac)







    x=ones(1,Fac);
    c=x;
    for idx=1:(N-1)
        c=conv(c,x);
    end
    coeffs=c;
end
