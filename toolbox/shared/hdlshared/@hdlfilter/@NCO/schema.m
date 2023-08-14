function schema





    mlock;

    pk=findpackage('hdlfilter');

    parent=findclass(pk,'AbstractHDLFilter');
    c=schema.class(pk,'NCO',parent);
    hdlpk=findpackage('hdl');
    hdlc=findclass(hdlpk,'NCO');
    schema.prop(c,'Oscillator','hdl.NCO');
    schema.prop(c,'Implementation','hdlimplementations');

