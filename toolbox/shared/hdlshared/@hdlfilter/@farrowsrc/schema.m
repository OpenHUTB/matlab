function schema







    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractsrc');
    c=schema.class(pk,'farrowsrc',parent);

    schema.prop(c,'Coefficients','mxArray');

    schema.prop(c,'InterpolationFactor','mxArray');

    schema.prop(c,'DecimationFactor','mxArray');

    p=schema.prop(c,'FDSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'MultiplicandSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'FDProdSLtype','ustring');
    set(p,'FactoryValue','double');

    schema.prop(c,'FDFixptSettings','mxArray');


