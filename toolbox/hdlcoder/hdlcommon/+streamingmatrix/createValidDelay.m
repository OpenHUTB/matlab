function createValidDelay(validIn,validOut,delayLength,name)




    hN=validIn.Owner;

    hNewN=pirelab.createNewNetwork(...
    'Network',hN,...
    'Name',name,...
    'InportNames',{validIn.Name},...
    'InportTypes',validIn.Type,...
    'InportRates',validIn.SimulinkRate,...
    'OutportNames',{validOut.Name},...
    'OutportTypes',validOut.Type,...
    'OutportRates',validOut.SimulinkRate);
    hN.copyOptimizationOptions(hNewN,false);

    pirelab.instantiateNetwork(hN,hNewN,validIn,validOut,name);

    [validOutInner,~]=streamingmatrix.createEnabledDelayCounters(...
    hNewN.PirInputSignals,delayLength);

    buffer=pirelab.getWireComp(hNewN,validOutInner,hNewN.PirOutputSignals);
    buffer.setOutputDelay(1);
end
