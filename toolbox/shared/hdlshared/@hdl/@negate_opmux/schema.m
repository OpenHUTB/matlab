function schema








    mlock;


    package=findpackage('hdl');

    c=schema.class(package,'negate_opmux');
    p=schema.prop(c,'rounding','mxArray');
    p=schema.prop(c,'saturation','mxArray');
    p=schema.prop(c,'in','mxArray');
    p=schema.prop(c,'sel','mxArray');
    p=schema.prop(c,'out','mxArray');
    p=schema.prop(c,'negate_string','mxArray');

