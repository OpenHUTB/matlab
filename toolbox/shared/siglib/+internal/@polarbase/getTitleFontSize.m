function[siz,mul]=getTitleFontSize(p,sel,dir)







    if nargin<3
        dir=0;
    else
        dir=round(dir);
    end

    if strcmpi(sel,'top')
        mul=p.TitleTopFontSizeMultiplier;
    else
        mul=p.TitleBottomFontSizeMultiplier;
    end
    fsz=p.pFontSize;
    lim=p.TitleFontSizeLimits;
    siz=fsz*mul+dir;
    siz=min(lim(2),max(lim(1),siz));
    mul=siz./fsz;
    mul=round(mul*100)/100;
