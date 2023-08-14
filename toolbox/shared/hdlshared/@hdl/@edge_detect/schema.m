function schema








    mlock;


    package=findpackage('hdl');

    c=schema.class(package,'edge_detect');

    p=schema.prop(c,'edge_type','mxArray');
    p=schema.prop(c,'input','mxArray');
    p=schema.prop(c,'output','mxArray');
    p=schema.prop(c,'clock','mxArray');
    p=schema.prop(c,'clockenable','mxArray');
    p=schema.prop(c,'reset','mxArray');
    p=schema.prop(c,'processName','mxArray');


    p=schema.prop(c,'op','mxArray');
    p=schema.prop(c,'in_notzero','mxArray');
    p=schema.prop(c,'in_notzero_delayed','mxArray');
    p=schema.prop(c,'notin_idx','mxArray');
    p=schema.prop(c,'notout_idx','mxArray');
    p=schema.prop(c,'opin1','mxArray');
    p=schema.prop(c,'opin2','mxArray');
    p=schema.prop(c,'resetvalue','mxArray');

    p=schema.prop(c,'hN','mxArray');
    p.FactoryValue=[];

    p=schema.prop(c,'slrate','mxArray');
    p.FactoryValue=-1;