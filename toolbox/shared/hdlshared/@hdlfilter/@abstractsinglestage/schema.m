function schema






    mlock;

    pk=findpackage('hdlfilter');
    parent=findclass(pk,'AbstractHDLFilter');
    c=schema.class(pk,'abstractsinglestage',parent);
    set(c,'Description','abstract');

    schema.prop(c,'Implementation','hdlimplementations');

    schema.prop(c,'InputSLType','ustring');

    schema.prop(c,'OutputSLType','ustring');

    schema.prop(c,'coeffvectorvtype','mxArray');

    schema.prop(c,'inputvectorvtype','mxArray');

    schema.prop(c,'outputvectorvtype','mxArray');



