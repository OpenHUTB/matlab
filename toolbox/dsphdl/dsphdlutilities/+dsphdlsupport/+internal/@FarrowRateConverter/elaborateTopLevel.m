function newNet=elaborateTopLevel(this,hN,hC,blockInfo)








    hDriver=hdlcurrentdriver;
    blockInfo.synthesisTool=hDriver.getParameter('SynthesisTool');
    if blockInfo.ResetInputPort&&strcmpi(blockInfo.Mode,'Input port')
        inportNames={'dataIn','validIn','rate','syncReset'};
    elseif blockInfo.ResetInputPort
        inportNames={'dataIn','validIn','syncReset'};
    elseif strcmpi(blockInfo.Mode,'Input port')
        inportNames={'dataIn','validIn','rate'};
    else
        inportNames={'dataIn','validIn'};
    end

    outportNames={'dataOut','validOut'};
    if length(hC.PirOutputPorts)==3
        outportNames={'dataOut','validOut','ready'};
    end

    newNet=pirelab.createNewNetworkWithInterface(...
    'Network',hN,...
    'RefComponent',hC,...
    'InportNames',inportNames,...
    'OutportNames',outportNames);





    dataIn=newNet.PirInputSignals(1);
    validIn=newNet.PirInputSignals(2);
    dataRate=dataIn.simulinkRate;
    dinType=pirgetdatatypeinfo(dataIn.Type);
    isInputComplex=dinType.iscomplex;


    dataOut=newNet.PirOutputSignals(1);
    validOut=newNet.PirOutputSignals(2);
    if length(newNet.PirOutputSignals)>2
        ready=newNet.PirOutputSignals(3);
    else

        ready=newNet.addSignal(pir_boolean_t,'ready');
        ready.SimulinkRate=dataRate;
    end






    inputRate=dataIn.SimulinkRate;
    dataOut.SimulinkRate=inputRate;
    validOut.SimulinkRate=inputRate;
    ready.SimulinkRate=inputRate;
    booleanT=pir_boolean_t();

    inSignals=[dataIn,validIn];




end

