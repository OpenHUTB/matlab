function schema








    mlock;


    package=findpackage('hdl');

    c=schema.class(package,'divide');


    p=schema.prop(c,'inputs','mxArray');

    p=schema.prop(c,'output','mxArray');

    p=schema.prop(c,'rounding','mxArray');
    p=schema.prop(c,'saturation','mxArray');
    p=schema.prop(c,'type','mxArray');

