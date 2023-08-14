function schema






    mlock;

    pk=findpackage('hdlfilter');

    parent=findclass(pk,'abstractmultirate');
    c=schema.class(pk,'abstractinterp',parent);
    set(c,'Description','abstract');

    schema.prop(c,'InterpolationFactor','mxArray');


