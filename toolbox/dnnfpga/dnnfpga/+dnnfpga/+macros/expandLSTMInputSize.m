function lstmLayerMod=expandLSTMInputSize(sz,lstmLayerOrig)

    lstmLayerMod=lstmLayerOrig;
    if sz>lstmLayerOrig.InputSize
        delta=sz-lstmLayerOrig.InputSize;
        inputWeights=lstmLayerOrig.InputWeights;
        inputWeightsSize=size(inputWeights);
        added=zeros(inputWeightsSize(1),delta,'like',inputWeights);
        lstmLayerMod=lstmLayer(inputWeightsSize(1)/4,Name=lstmLayerOrig.Name,...
        OutputMode=lstmLayerOrig.OutputMode);
        lstmLayerMod.InputWeights=horzcat(inputWeights,added);
        lstmLayerMod.RecurrentWeights=lstmLayerOrig.RecurrentWeights;
        lstmLayerMod.Bias=lstmLayerOrig.Bias;
    elseif sz<lstmLayer.InputSize
        error("Specified sz must be >= to the original LSTM input size.");
    end

end