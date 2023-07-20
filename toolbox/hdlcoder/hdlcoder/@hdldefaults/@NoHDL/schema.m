function schema








    mlock;


    package=findpackage('hdlbuiltinimpl');
    parent=findclass(package,'EmlImplBase');

    package=findpackage('hdldefaults');
    this=schema.class(package,'NoHDL',parent);
