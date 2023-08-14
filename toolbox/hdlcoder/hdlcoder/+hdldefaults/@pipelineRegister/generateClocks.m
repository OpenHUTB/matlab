function generateClocks(this,hN,hC)


    hS=this.findSignalWithValidRate(hC.Owner,hC,hC.SLOutputPorts(1).Signal);
    [~,~,~]=hdlgetclockbundle(hN,hC,hS,1,1,0);
end
