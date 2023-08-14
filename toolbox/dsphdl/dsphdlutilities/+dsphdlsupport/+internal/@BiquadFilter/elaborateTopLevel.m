function newNet=elaborateTopLevel(this,hN,hC,blockInfo)





















    inportNames={'dataIn','validIn'};
    outportNames={'dataOut','validOut'};

    newNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportNames,...
    'OutportNames',outportNames);





    dataIn=newNet.PirInputSignals(1);
    validIn=newNet.PirInputSignals(2);
    dataRate=dataIn.simulinkRate;
    dinType=pirgetdatatypeinfo(dataIn.Type);

































    dataOut=newNet.PirOutputSignals(1);
    validOut=newNet.PirOutputSignals(2);






    dataOut.SimulinkRate=dataRate;
    validOut.SimulinkRate=dataRate;

    inSignals=[dataIn,validIn];
    outSignals=[dataOut,validOut];

    this.elabBiquadFilter(newNet,blockInfo,inSignals,outSignals);

end

