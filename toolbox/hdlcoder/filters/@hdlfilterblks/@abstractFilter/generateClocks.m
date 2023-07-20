function generateClocks(this,hN,hC)






    hS=this.findSignalWithValidRate(hN,hC,[hC.PirInputSignals(1),...
    hC.PirOutputSignals(1)]);
    [clk,clken,reset]=hdlgetclockbundle(hN,hC,hS,1,1,0);



