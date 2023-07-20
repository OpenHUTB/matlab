function schema






    mlock;

    pk=findpackage('hdlfilter');

    parent=findclass(pk,'abstractdecim');
    c=schema.class(pk,'firtdecim',parent);

    p=schema.prop(c,'StateSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'PolyAccumSLtype','ustring');
    set(p,'FactoryValue','double');


