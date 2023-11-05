function ret=getTICCSv3(opt)
    switch(opt)
    case 'name',
        ret='Texas Instruments Code Composer Studio';
    case 'tag',
        ret='ccslinktgtpref';
    case 'tag64xp'
        ret='ccslinktgtpref_c64xp';
    otherwise,
        ret=[];
    end


