function schema








    mlock;


    package=findpackage('hdl');
    parent=findclass(package,'aRegister');
    c=schema.class(package,'intdelay',parent);

    p=schema.prop(c,'nDelays','mxArray');
    p=schema.prop(c,'tmpsignal','mxArray');
