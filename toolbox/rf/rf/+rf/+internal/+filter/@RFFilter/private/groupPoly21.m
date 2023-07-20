function grpPoly=groupPoly21(designData,omega)





    polyCoeffs=designData.Numerator21;


    grpReal=@(zeroes,omega)zeroes./(zeroes.^2+omega.^2);
    grpCplx=@(zeroes,omega)2*real(zeroes).*...
    (real(zeroes).^2+imag(zeroes).^2+omega.^2)./...
    ((real(zeroes).^2+imag(zeroes).^2-omega.^2).^2+...
    (2*real(zeroes)*omega).^2);


    flag=isfield(designData,'Auxiliary')&&...
    isfield(designData.Auxiliary,'Numerator21Polynomial');
    if flag&&~any(isinf(designData.Auxiliary.Numerator21Polynomial))
        [zeroes,numCplx]=...
        topconj(polyvalCoeffroots(designData.Auxiliary.Numerator21Polynomial));
    else
        [zeroes,numCplx]=topconj(polyvalCoeffroots(polyCoeffs));
    end

    lenZeroes=length(zeroes);
    if lenZeroes==0
        grpPoly=0;
    else
        if numCplx==0
            grpPoly=sum(bsxfun(grpReal,zeroes,omega),1);
        elseif numCplx==lenZeroes
            grpPoly=sum(bsxfun(grpCplx,zeroes,omega),1);
        else
            grpPoly=sum(bsxfun(grpCplx,zeroes(1:numCplx),omega),1)+...
            sum(bsxfun(grpReal,zeroes(numCplx+1:end),omega),1);
        end
    end
end
