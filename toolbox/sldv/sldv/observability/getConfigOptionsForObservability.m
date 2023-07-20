function configOptionVal=getConfigOptionsForObservability(configOptionName)



    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(configOptionName);
    coder.extrinsic('sldvprivate');
    configOptionVal=coder.const(sldvprivate('getConfigOptionsForObservability',configOptionName));
end
