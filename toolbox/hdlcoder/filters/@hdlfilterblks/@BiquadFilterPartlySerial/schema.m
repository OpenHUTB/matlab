function schema






    mlock;


    package=findpackage('hdlfilterblks');
    parent=findclass(package,'BiquadFilterHDLInstantiation');
    schema.class(package,'BiquadFilterPartlySerial',parent);
