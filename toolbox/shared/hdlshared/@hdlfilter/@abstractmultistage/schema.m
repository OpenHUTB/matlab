function schema






    mlock;

    pk=findpackage('hdlfilter');

    parent=findclass(pk,'AbstractHDLFilter');
    c=schema.class(pk,'abstractmultistage',parent);
    schema.prop(c,'Stage','hdlfilter.AbstractHDLFilter vector');

    schema.prop(c,'RateChangeFactors','mxArray');

    schema.prop(c,'Implementation','hdlimplementations');


