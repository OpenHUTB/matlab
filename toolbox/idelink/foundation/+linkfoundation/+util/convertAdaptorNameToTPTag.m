function ret=convertAdaptorNameToTPTag(name)




    switch(name)
    case 'Green Hills MULTI',
        ret='multilinktgtpref';
    case 'Texas Instruments Code Composer Studio',
        ret='ccslinktgtpref';
    case ticcsext.Utilities.getTICCSv4('name'),
        ret=ticcsext.Utilities.getTICCSv4('tag');
    case ticcsext.Utilities.getTICCSv5('name'),
        ret=ticcsext.Utilities.getTICCSv5('tag');
    case 'Analog Devices VisualDSP++',
        ret='vdsplinktgtpref';
    case 'Eclipse',
        ret='eclipseidetgtpref';
    case 'Wind River Diab/GCC (makefile generation only)',
        ret='wrworkbenchtgtpref';
    case 'XILINX ISE Design Suite (makefile generation only)'
        ret='xilinxisetgtpref';
    otherwise,
        ret=[];
    end


