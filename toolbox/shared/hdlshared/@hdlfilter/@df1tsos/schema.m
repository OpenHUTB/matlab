function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractdf1');
    c=schema.class(pk,'df1tsos',parent);

    p=schema.prop(c,'SectionInputSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'SectionOutputSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'MultiplicandSLtype','ustring');
    set(p,'FactoryValue','double');

