function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractfir');
    this=schema.class(pk,'abstractfarrow',parent);

    schema.prop(this,'RoundMode','rmodetype');
    p=schema.prop(this,'OverflowMode','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(this,'ProductSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(this,'AccumSLtype','ustring');
    set(p,'FactoryValue','double');


