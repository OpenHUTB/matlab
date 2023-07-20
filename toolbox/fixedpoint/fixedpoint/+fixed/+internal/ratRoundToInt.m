function[nearestInt,remainder]=ratRoundToInt(r)




    n=r.signedFullNum();
    d=r.fullDen();

    fm=fimath('RoundingMethod','Nearest',...
    'OverflowAction','Saturate',...
    'ProductMode','FullPrecision',...
    'SumMode','FullPrecision');

    nnt=numerictype(n);
    dnt=numerictype(d);
    qnt=quotientType(nnt,dnt);

    n2=fi(n,nnt,fm);
    d2=fi(d,dnt,fm);

    quot=divide(qnt,n2,d2);

    nearestInt=removefimath(quot);

    remainder=r-fixed.internal.ratPlus((d*nearestInt),d);
end

function qnt=quotientType(nnt,dnt)

    qnt=nnt;

    numPow2WtMSBit=nnt.WordLength-1+nnt.FixedExponent;
    quotPow2WtMSBit=numPow2WtMSBit-dnt.FixedExponent;

    desiredWordLength=max(3,quotPow2WtMSBit);

    if~nnt.Signed&&dnt.Signed
        qnt.Signed=true;
        desiredWordLength=desiredWordLength+2;
    else
        desiredWordLength=desiredWordLength+1;
    end
    qnt.WordLength=desiredWordLength;
    qnt.FixedExponent=0;
end
