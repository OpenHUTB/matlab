function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractfirt');
    c=schema.class(pk,'dffirt',parent);

    schema.prop(c,'Coefficients','mxArray');

    schema.prop(c,'RoundMode','rmodetype');

    p=schema.prop(c,'OverflowMode','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'CoeffSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'ProductSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'AccumSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'StateSLtype','ustring');
    set(p,'FactoryValue','double');


