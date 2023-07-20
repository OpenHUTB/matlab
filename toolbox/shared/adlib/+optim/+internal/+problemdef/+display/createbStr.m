function bStr=createbStr(b,nelem)










    bStr=strings(nelem,1);

    bNonZero=b~=0;
    bStr(bNonZero)=string(abs(full(b(bNonZero))));
