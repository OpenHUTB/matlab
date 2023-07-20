function schema








    mlock;


    package=findpackage('hdl');
    parent=findclass(package,'aRegister');
    c=schema.class(package,'dspdelay',parent);

    schema.prop(c,'nDelays','mxArray');
    schema.prop(c,'tmpsignal','mxArray');

