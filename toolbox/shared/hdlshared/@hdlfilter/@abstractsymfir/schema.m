function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractdffir');
    c=schema.class(pk,'abstractsymfir',parent);

    p=schema.prop(c,'TapSumSLtype','ustring');
    set(p,'FactoryValue','double');





