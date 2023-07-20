function[gateWeights,stateWeights]=getGateAndStateWeights(numHiddenUnits,weights)




    [rInd,zInd,hInd]=...
    coder.const(@coder.internal.layer.rnnUtils.gruUtils.gruGateIndices,numHiddenUnits);

    gateWeights=weights([rInd,zInd],:);
    stateWeights=weights(hInd,:);

end
