function schema






    mlock;

    package=findpackage('hdlfilterblks');
    parent=findclass(package,'DiscreteFIRFilterHDLInstantiation');
    hThisClass=schema.class(package,'DiscreteFIRFrameBased',parent);
    schema.method(hThisClass,'elaborateFrameBased','Static');