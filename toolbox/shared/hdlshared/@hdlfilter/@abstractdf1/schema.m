function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractsos');
    c=schema.class(pk,'abstractdf1',parent);
    set(c,'Description','abstract');

    p=schema.prop(c,'NumStateSLtype','ustring');
    set(p,'FactoryValue','double');

    p=schema.prop(c,'DenStateSLtype','ustring');
    set(p,'FactoryValue','double');


