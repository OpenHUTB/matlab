function schema








    mlock;


    package=findpackage('hdl');

    c=schema.class(package,'BypassRegister');

    p=schema.prop(c,'isVHDL','bool');
    p=schema.prop(c,'isVerilog','bool');
    p=schema.prop(c,'processName','ustring');
    p=schema.prop(c,'hasAsyncReset','bool');
    p=schema.prop(c,'hasSyncReset','bool');
    p=schema.prop(c,'hasClockEnable','bool');
    p=schema.prop(c,'hasNegEdgeClock','bool');
    p=schema.prop(c,'resetAssertedLevel','bool');
    p=schema.prop(c,'useClockRisingEdge','bool');
    p=schema.prop(c,'baseIndent','mxArray');
    p=schema.prop(c,'resetvalues','mxArray');

    p=schema.prop(c,'dataIn','mxArray');
    p=schema.prop(c,'selectIn','mxArray');
    p=schema.prop(c,'dataOut','mxArray');
    p=schema.prop(c,'clock','mxArray');
    p=schema.prop(c,'clockenable','mxArray');
    p=schema.prop(c,'reset','mxArray');


