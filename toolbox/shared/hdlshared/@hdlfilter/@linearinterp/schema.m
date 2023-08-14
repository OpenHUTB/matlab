function schema






    mlock;

    pk=findpackage('hdlfilter');

    parent=findclass(pk,'abstractfirinterp');
    schema.class(pk,'linearinterp',parent);

