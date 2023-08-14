function out=getfreqinhz(funit,fdata)


    switch funit
    case 'hz'
        scale=1;
    case 'khz'
        scale=1e3;
    case 'mhz'
        scale=1e6;
    case 'ghz'
        scale=1e9;
    end
    out=scale*fdata;