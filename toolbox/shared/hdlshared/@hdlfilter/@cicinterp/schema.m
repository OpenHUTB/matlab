function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractcic');
    c=schema.class(pk,'cicinterp',parent);

    schema.prop(c,'InterpolationFactor','mxArray');



