function schema






    mlock;

    pk=findpackage('hdlfilter');

    parent=findclass(pk,'abstractsinglestage');
    c=schema.class(pk,'scalar',parent);

    schema.prop(c,'Gain','mxArray');

    schema.prop(c,'RoundMode','rmodetype');

    p=schema.prop(c,'OverflowMode','bool');
    set(p,'FactoryValue',false);

    p=schema.prop(c,'CoeffSLtype','ustring');
    set(p,'FactoryValue','double');


