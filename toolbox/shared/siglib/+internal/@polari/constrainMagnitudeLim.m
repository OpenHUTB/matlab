function lim=constrainMagnitudeLim(p,lim)



    c=p.MagnitudeLimBounds;
    lim(1)=max(lim(1),c(1));
    lim(2)=min(lim(2),c(2));
