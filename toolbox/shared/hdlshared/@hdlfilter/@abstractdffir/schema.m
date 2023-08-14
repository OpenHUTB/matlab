function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractfir');
    c=schema.class(pk,'abstractdffir',parent);
    set(c,'Description','abstract');

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


