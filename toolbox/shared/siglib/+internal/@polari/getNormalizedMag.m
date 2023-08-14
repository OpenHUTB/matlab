function r=getNormalizedMag(p,r)






    rlim=p.pMagnitudeLim;
    r=(r-rlim(1))./(rlim(2)-rlim(1));
