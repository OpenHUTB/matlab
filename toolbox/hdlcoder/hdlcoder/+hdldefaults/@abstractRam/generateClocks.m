function generateClocks(this,hN,hC)





    if(hC.NumberOfPirInputPorts>0)
        hS=hC.PirInputSignals(1);
    else
        hS=hC.PirOutputSignals(1);
    end


    [clk,clken,reset]=hdlgetclockbundle(hN,hC,hS,1,1,0);

    userData=this.getHDLUserData(hC);
    if userData.ramIsGeneric


        [clk,clken,reset]=hdlgetclockbundle(hN,hC,hS,1,1,1);
    end



















