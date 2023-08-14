function context=beginClockBundleContext(this,hN,hC,hS,up,dn,off)







    context.original_clk=hdlgetcurrentclock;
    context.original_clken=hdlgetcurrentclockenable;
    context.original_reset=hdlgetcurrentreset;

    [clk,clken,reset]=hdlgetclockbundle(hN,hC,hS,up,dn,off);


    hdlsetcurrentclock(clk);
    hdladdclockenablesignal(clken);
    hdlsetcurrentclockenable(clken);

    hdlsetcurrentreset(reset);



