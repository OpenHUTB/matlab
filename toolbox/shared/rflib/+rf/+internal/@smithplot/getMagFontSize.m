function[siz,mul]=getMagFontSize(p,dir)





    if nargin<2
        dir=0;
    else
        dir=round(dir);
    end

    fsz=p.pFontSize;
    lim=p.FontSizeLimits;
    mul=p.CircleFontSizeMultiplier;
    siz=fsz*mul+dir;
    siz=min(lim(2),max(lim(1),siz));
    mul=siz./fsz;
    mul=round(mul*100)/100;
