function str=roundingWrap2fi(rnd)






    switch lower(rnd)
    case 'ceiling',
        str='ceil';
    case 'zero',
        str='fix';
    otherwise,
        str=lower(rnd);
    end

