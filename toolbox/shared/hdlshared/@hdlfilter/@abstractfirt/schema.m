function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractfir');
    c=schema.class(pk,'abstractfirt',parent);
    set(c,'Description','abstract');


