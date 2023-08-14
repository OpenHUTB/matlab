function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractfarrow');
    c=schema.class(pk,'farrowfd',parent);

    schema.prop(c,'Coefficients','mxArray');

    p=schema.prop(c,'CoeffSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'FDSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'MultiplicandSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'FDProdSLtype','ustring');
    set(p,'FactoryValue','double');




