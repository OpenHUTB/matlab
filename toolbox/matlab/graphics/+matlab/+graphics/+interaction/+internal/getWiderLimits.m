function finallim=getWiderLimits(lim1,lim2)



    if all(lim1==0)
        finallim=lim2;
        return
    end

    lower=min(lim1([1,3,5]),lim2([1,3,5]));
    upper=max(lim1([2,4,6]),lim2([2,4,6]));
    finallim([1,3,5])=lower;
    finallim([2,4,6])=upper;
