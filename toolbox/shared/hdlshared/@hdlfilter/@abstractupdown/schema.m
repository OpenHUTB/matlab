function schema





    mlock;

    pk=findpackage('hdlfilter');

    parent=findclass(pk,'AbstractHDLFilter');
    c=schema.class(pk,'abstractupdown',parent);

    hdlc=findclass(pk,'NCO');%#ok
    hdlc=findclass(pk,'mfiltcascade');%#ok

    schema.prop(c,'NCO','hdlfilter.NCO');
    schema.prop(c,'Mixer','hdlfilter.AbstractHDLFilter');
    schema.prop(c,'Filters','hdlfilter.mfiltcascade');
    schema.prop(c,'Implementation','hdlimplementations');

    schema.prop(c,'RateChangeFactor','mxArray');
    schema.prop(c,'InputSLType','ustring');
    schema.prop(c,'OutputSLType','ustring');
    schema.prop(c,'FiltersCastSLType','ustring');

