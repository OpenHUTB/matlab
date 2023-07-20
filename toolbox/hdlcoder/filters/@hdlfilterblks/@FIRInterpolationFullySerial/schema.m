function schema





    mlock;

    package=findpackage('hdlfilterblks');
    parent=findclass(package,'FIRInterpolationHDLInstantiation');
    schema.class(package,'FIRInterpolationFullySerial',parent);
