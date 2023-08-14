function[gateWeights,stateWeights]=getGateAndStateWeights(numHiddenUnits,weights)




    ignoreStateIndices=false;
    [iInd,fInd,oInd,zInd]=coder.internal.layer.rnnUtils.lstmUtils.computeGateAndStateIndices(...
    numHiddenUnits,ignoreStateIndices);
    ifoInd=[iInd,fInd,oInd];

    gateWeights=weights(ifoInd,:);
    stateWeights=weights(zInd,:);

end
