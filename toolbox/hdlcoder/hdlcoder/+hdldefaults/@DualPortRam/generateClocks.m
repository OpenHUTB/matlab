function generateClocks(this,~,hC)




    din=hC.PirInputSignals(1);
    din_ram=hC.PirOutputSignals(1);

    hS=this.findSignalWithValidRate(hC.Owner,hC,[din,din_ram]);

    [clk,clken0,reset]=hdlgetclockbundle(hC.Owner,hC,hS,1,1,0);

