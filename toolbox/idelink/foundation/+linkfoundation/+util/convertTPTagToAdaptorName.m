function ret=convertTPTagToAdaptorName(tag)




    switch(tag)
    case 'multilinktgtpref',
        ret='Green Hills MULTI';
    case{ticcsext.Utilities.getTICCSv3('tag'),ticcsext.Utilities.getTICCSv3('tag64xp')}
        ret=ticcsext.Utilities.getTICCSv3('name');
    case{ticcsext.Utilities.getTICCSv4('tag'),ticcsext.Utilities.getTICCSv4('tag64xp')}
        ret=ticcsext.Utilities.getTICCSv4('name');
    case{ticcsext.Utilities.getTICCSv5('tag'),ticcsext.Utilities.getTICCSv5('tag64xp')}
        ret=ticcsext.Utilities.getTICCSv5('name');
    case 'vdsplinktgtpref',
        ret='Analog Devices VisualDSP++';
    case 'eclipseidetgtpref',
        ret='Eclipse';
    case 'wrworkbenchtgtpref',
        ret='Wind River Diab/GCC (makefile generation only)';
    case 'xilinxisetgtpref',
        ret='XILINX ISE Design Suite (makefile generation only)';
    otherwise,
        ret=[];
    end


