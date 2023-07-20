function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'abstractsinglestage');
    c=schema.class(pk,'delay',parent);

    schema.prop(c,'Latency','mxArray');




