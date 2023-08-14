function nComp=elaborateIntDeint(this,hN,hC,intdelay,blkComment)






    hN2=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',{hC.PirInputSignals(1).Name},...
    'OutportNames',{hC.PirOutputSignals(1).Name});

    hN2.addComment(blkComment);


    this.elaborateIntDeintShiftReg(hN2,hC,intdelay);


    nComp=pirelab.instantiateNetwork(hN,hN2,hC.PirInputSignals,hC.PirOutputSignals,hC.Name);


