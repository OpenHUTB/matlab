function endClockBundleContext(this,context)





    hdlsetcurrentclock(context.original_clk);
    hdlsetcurrentclockenable(context.original_clken);
    hdlsetcurrentreset(context.original_reset);



