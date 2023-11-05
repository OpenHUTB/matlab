function ret=getTICCSv4(opt)
    switch(opt)
    case 'name',
        ret='Texas Instruments Code Composer Studio v4 (makefile generation only)';
    case 'tag',
        ret='ccslinktgtpref_ccsv4';
    case 'tag64xp'
        ret='ccslinktgtpref_ccsv4_c64xp';
    otherwise,
        ret=[];
    end


