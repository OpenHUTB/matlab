function ret=getTICCSv5(opt)




    switch(opt)
    case 'name',
        ret='Texas Instruments Code Composer Studio v5 (makefile generation only)';
    case 'tag',
        ret='ccslinktgtpref_ccsv5';
    case 'tag64xp'
        ret='ccslinktgtpref_ccsv5_c64xp';
    otherwise,
        ret=[];
    end


