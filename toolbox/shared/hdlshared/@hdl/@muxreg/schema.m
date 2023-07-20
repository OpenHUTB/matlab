function schema








    mlock;


    package=findpackage('hdl');
    parent=findclass(package,'aRegister');
    c=schema.class(package,'muxreg',parent);

    p=schema.prop(c,'sel','mxArray');
    p=schema.prop(c,'selValues','mxArray');
    p=schema.prop(c,'muxtype','mxArray');


