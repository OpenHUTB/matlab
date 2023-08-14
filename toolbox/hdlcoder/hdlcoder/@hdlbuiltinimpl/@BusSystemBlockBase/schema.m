function schema








    mlock;


    package=findpackage('hdlbuiltinimpl');
    parent=findclass(package,'EmlImplBase');

    package=findpackage('hdlbuiltinimpl');
    this=schema.class(package,'BusSystemBlockBase',parent);

    schema.method(this,'expandBusSignalsForSystemBlock','static');
