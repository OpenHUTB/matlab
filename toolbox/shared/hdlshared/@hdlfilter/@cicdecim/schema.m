function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractcic');
    c=schema.class(pk,'cicdecim',parent);

    schema.prop(c,'DecimationFactor','mxArray');


