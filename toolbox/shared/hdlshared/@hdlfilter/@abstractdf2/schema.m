function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractsos');
    c=schema.class(pk,'abstractdf2',parent);
    set(c,'Description','abstract');

    p=schema.prop(c,'SectionInputSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'SectionOutputSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'StateSLtype','ustring');
    set(p,'FactoryValue','double');


