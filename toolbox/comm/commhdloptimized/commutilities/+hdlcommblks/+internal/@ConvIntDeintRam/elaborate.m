function nComp=elaborate(this,hN,hC)







    hN2=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',{hC.PirInputSignals(1).Name},...
    'OutportNames',{hC.PirOutputSignals(1).Name});



    this.elaborateIntDeintRam(hN2,hC);


    nComp=pirelab.instantiateNetwork(hN,hN2,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);



