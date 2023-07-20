function schema







    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractsinglestage');
    c=schema.class(pk,'abstractfir',parent);
    set(c,'Description','abstract');

