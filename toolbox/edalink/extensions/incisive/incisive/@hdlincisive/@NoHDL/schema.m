function schema








    mlock;


    package=findpackage('hdldefaults');
    parent=findclass(package,'NoHDL');

    package=findpackage('hdlincisive');
    this=schema.class(package,'NoHDL',parent);
