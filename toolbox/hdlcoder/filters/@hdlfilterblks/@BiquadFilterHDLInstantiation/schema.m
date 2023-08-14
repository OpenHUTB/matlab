function schema








    mlock;


    package=findpackage('hdlfilterblks');
    parent=findclass(package,'DigitalFilterHDLInstantiation');
    schema.class(package,'BiquadFilterHDLInstantiation',parent);
