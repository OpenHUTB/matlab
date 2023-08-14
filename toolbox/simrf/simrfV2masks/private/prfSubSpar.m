function prSpar=prfSubSpar(s1,s2)







    polyLen=cellfun(@length,{s1,s2});
    padNum=max(polyLen)-polyLen;
    s1Pad=[zeros(1,padNum(1)),s1];
    s2Pad=[zeros(1,padNum(2)),s2];


    s1Neg=s1Pad;
    s1Neg(end-1:-2:1)=-s1Neg(end-1:-2:1);
    s2Neg=s2Pad;
    s2Neg(end-1:-2:1)=-s2Neg(end-1:-2:1);

    part1=conv(s1Pad,s1Neg);
    part2=conv(s2Pad,s2Neg);

    part1(end-1:-2:1)=0;
    part2(end-1:-2:1)=0;
    newS2=part1-part2;

    newS2(abs(newS2)<1e-10)=0;
    allRoots=roots(newS2);
    leftRoots=allRoots(real(allRoots)<0);
    zeroRoots=allRoots(abs(allRoots)<1e-10);
    jaxisRoots=allRoots(real(allRoots)==0&abs(imag(allRoots))>1e-10);
    prSpar=1;
    for i=1:length(leftRoots);
        prSpar=conv(prSpar,[1,-leftRoots(i)]);
    end
    for i=1:length(zeroRoots)/2
        prSpar=conv(prSpar,[1,0]);
    end
    for i=1:length(jaxisRoots)
        prSpar=conv(prSpar,[1,-jaxisRoots(i)]);
    end



end