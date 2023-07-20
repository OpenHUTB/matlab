function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractfarrow');
    c=schema.class(pk,'farrowlinearfd',parent);

    p=schema.prop(c,'Coefficients','mxArray');
    set(p,'FactoryValue',[-1,1;1,0],'AccessFlags.PublicSet','off');

    p=schema.prop(c,'FDSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'TapsumSLtype','ustring');
    set(p,'FactoryValue','double');



