function schema








    mlock;


    package=findpackage('hdl');
    parent=findclass(package,'aRegister');
    c=schema.class(package,'tapdelay',parent);

    p=schema.prop(c,'nDelays','mxArray');
    p=schema.prop(c,'delayOrder','mxArray');
    p=schema.prop(c,'includeCurrent','mxArray');

    p=schema.prop(c,'tmpsignal','mxArray');
