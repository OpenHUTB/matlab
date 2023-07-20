function generateClocks(this,hN,hC)%#ok





    if(hC.NumberOfPirInputPorts>0)
        hS=hC.PirInputSignals(1);
    else
        hS=hC.PirOutputSignals(1);
    end
    [clk,clken,reset]=hdlgetclockbundle(hN,hC,hS,1,1,0);%#ok



