function complexInt64Str=stringifyComplexInt64(inVal)




    keepItReal=real(inVal);
    keepItFake=imag(inVal);

    myImagSign='+';
    if keepItFake<0&&~isreal(inVal)
        myImagSign='';
    end
    complexInt64Str=sprintf('%d%s%di',keepItReal,myImagSign,keepItFake);

end
