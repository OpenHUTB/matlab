function isElementWise=checkProductIsElementWise(blockH)








    coder.inline('always');
    coder.allowpcode('plain');

    coder.const(blockH);
    coder.extrinsic('sldvprivate');
    isElementWise=coder.const(sldvprivate('getMultiplicationType',blockH));
end