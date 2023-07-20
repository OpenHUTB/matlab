function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractsrc');
    c=schema.class(pk,'firsrc',parent);

    schema.prop(c,'RateChangeFactors','mxArray');

    schema.prop(c,'PolyphaseCoefficients','mxArray');




