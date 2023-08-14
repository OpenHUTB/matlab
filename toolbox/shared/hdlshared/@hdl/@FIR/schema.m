function schema








    mlock;


    package=findpackage('hdl');

    c=schema.class(package,'FIR');

    p=schema.prop(c,'datain','mxArray');
    p=schema.prop(c,'filterout','mxArray');
    p=schema.prop(c,'length','mxArray');
    p=schema.prop(c,'taps','mxArray');
    p=schema.prop(c,'product_type','mxArray');
    p=schema.prop(c,'product_mode','mxArray');

    p=schema.prop(c,'adder_mode','mxArray');
    p=schema.prop(c,'adder_implementation','mxArray');

    p=schema.prop(c,'pipeline_processname','ustring');
    p=schema.prop(c,'resetvalues','mxArray');

    p=schema.prop(c,'data_pipe','mxArray');
    p=schema.prop(c,'tap_products','mxArray');

    p=schema.prop(c,'hN','mxArray');
    p.FactoryValue=[];

    p=schema.prop(c,'slrate','mxArray');
    p.FactoryValue=-1;
