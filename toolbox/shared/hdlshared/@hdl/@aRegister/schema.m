function schema








    mlock;


    package=findpackage('hdl');

    c=schema.class(package,'aRegister');

    schema.prop(c,'isVHDL','bool');
    schema.prop(c,'isVerilog','bool');
    schema.prop(c,'processName','ustring');
    schema.prop(c,'hasAsyncReset','bool');
    schema.prop(c,'hasSyncReset','bool');
    schema.prop(c,'hasClockEnable','bool');
    schema.prop(c,'hasNegEdgeClock','bool');
    schema.prop(c,'resetAssertedLevel','bool');
    schema.prop(c,'useClockRisingEdge','bool');
    schema.prop(c,'baseIndent','mxArray');

    schema.prop(c,'resetvalues','mxArray');
    schema.prop(c,'inputs','mxArray');
    schema.prop(c,'outputs','mxArray');
    schema.prop(c,'clock','mxArray');
    schema.prop(c,'clockenable','mxArray');
    schema.prop(c,'reset','mxArray');


    p=schema.prop(c,'isProcessNeeded','bool');
    set(p,'FactoryValue',true);
