function[clk,clken,reset]=hdlgetclockbundle(hN,hC,hS,up,down,offset)



    [clk,clken,reset]=hN.getClockBundle(hS,up,down,offset);





    if~isempty(hC)&&hC.isBlackBox
        if hC.isInstantiable
            cp=hC.addInputPort('clock',clk.Name);
            cep=hC.addInputPort('clock_enable',hdlgetparameter('clockenablename'));
            rp=hC.addInputPort('reset',reset.Name);
            clk.addReceiver(cp);
            clken.addReceiver(cep);
            reset.addReceiver(rp);
        else
            hC.connectClockBundle(clk,clken,reset);
        end
    end
end

