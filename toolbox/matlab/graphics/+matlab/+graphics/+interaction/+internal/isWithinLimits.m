function ret=isWithinLimits(limits1,limits2)




    tolerance=1e-2*diff(limits1);
    ret=limits2(1)<=(limits1(1)+tolerance)&&(limits2(2)+tolerance)>=limits1(2);
