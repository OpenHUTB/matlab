function context=beginClockBundleContext(this,clk,clken,reset)






    context.original_clk=hdlgetcurrentclock;
    context.original_clken=hdlgetcurrentclockenable;
    context.original_reset=hdlgetcurrentreset;

    hdlsetcurrentclock(clk);
    hdladdclockenablesignal(clken);
    hdlsetcurrentclockenable(clken);
    hdlsetcurrentreset(reset);




