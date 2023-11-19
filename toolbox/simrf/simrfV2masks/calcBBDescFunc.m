function VoutBB=calcBBDescFunc(Vin,coeffsRPB,VsatIn,VSatOutRPB)

    VinPreSat=Vin(Vin<=VsatIn);
    VinPostSat=Vin(Vin>VsatIn);
    VoutBBpresat=zeros(size(VinPreSat));
    VoutBBpostsat=zeros(size(VinPostSat));
    for n=1:ceil(length(coeffsRPB)/2)
        VoutBBpresat=VoutBBpresat+nchoosek(2*n,n)/2^(2*n-1)*...
        coeffsRPB(2*n-1)*VinPreSat.^(2*n-1);
        alpha=VsatIn./VinPostSat;
        VoutBBpostsat=VoutBBpostsat+...
        coeffsRPB(2*n-1)*VinPostSat.^(2*n-1)/(4^n).*...
        (coeff(alpha,n)+nchoosek(2*n,n)*asin(alpha));
    end
    VoutBBpostsat=4/pi*(VoutBBpostsat+VSatOutRPB*sqrt(1-alpha.^2));
    VoutBB=[VoutBBpresat,VoutBBpostsat];
end

function c=coeff(alpha,n)



    c=0;
    for k=1:n
        c=c+nchoosek(2*n,n-k)/k*...
        ((2*alpha.^2-1+2*1j*alpha.*sqrt((1-alpha.^2))).^k-...
        (2*alpha.^2-1-2*1j*alpha.*sqrt((1-alpha.^2))).^k);
    end
    c=c*1j/2;
end