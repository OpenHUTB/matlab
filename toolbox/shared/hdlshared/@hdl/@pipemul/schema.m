function schema








    mlock;


    package=findpackage('hdl');
    parent=findclass(package,'aRegister');
    c=schema.class(package,'pipemul',parent);

    schema.prop(c,'inputpipelevels','mxArray');
    schema.prop(c,'outputpipelevels','mxArray');
    schema.prop(c,'realonly','bool');

    schema.prop(c,'roundmode','mxArray');
    schema.prop(c,'saturation','mxArray');

    schema.prop(c,'areg','mxArray');
    schema.prop(c,'breg','mxArray');
    schema.prop(c,'mreg','mxArray');
    schema.prop(c,'finalout','mxArray');
