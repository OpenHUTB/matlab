function schema






    mlock;

    package=findpackage('hdlfilterblks');
    parent=findclass(package,'abstractFilter');
    schema.class(package,'FIRDecimationHDLInstantiation',parent);
