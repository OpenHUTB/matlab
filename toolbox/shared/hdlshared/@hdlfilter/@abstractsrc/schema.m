function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractfarrow');
    c=schema.class(pk,'abstractsrc',parent);
    set(c,'Description','abstract');

    p=schema.prop(c,'CoeffSLtype','ustring');
    set(p,'FactoryValue','double');

