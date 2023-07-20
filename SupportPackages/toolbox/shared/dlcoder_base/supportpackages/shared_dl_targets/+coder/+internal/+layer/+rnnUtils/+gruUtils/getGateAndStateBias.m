function[inputGateBias,inputStateBias,recurrentGateBias,recurrentStateBias]=...
    getGateAndStateBias(numHiddenUnits,bias,hasRecurrentBias)




    [rInd,zInd,hInd,rIndRecurrent,zIndRecurrent,hIndRecurrent]=...
    coder.const(@coder.internal.layer.rnnUtils.gruUtils.gruGateIndices,numHiddenUnits);

    inputGateBias=bias([rInd,zInd],:);
    inputStateBias=bias(hInd,:);

    if hasRecurrentBias
        recurrentGateBias=bias([rIndRecurrent,zIndRecurrent],:);
        recurrentStateBias=bias(hIndRecurrent,:);
    else
        recurrentGateBias=[];
        recurrentStateBias=[];
    end

end
