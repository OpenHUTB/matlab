function[slope,bias]=getParamsForRescaleForOversizedInput(minCur,maxCur,minNew,maxNew)




    minCur=min(minCur,[],1:2);
    maxCur=max(maxCur,[],1:2);
    [slope,bias]=coder.internal.layer.inputLayerUtils.getParamsForRescale(minCur,maxCur,minNew,maxNew);

end
