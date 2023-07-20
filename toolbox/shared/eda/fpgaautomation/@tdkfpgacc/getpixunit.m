function pf=getpixunit







    if isunix,
        pf=1;
    else
        pf=get(0,'screenpixelsperinch')/96;
    end


