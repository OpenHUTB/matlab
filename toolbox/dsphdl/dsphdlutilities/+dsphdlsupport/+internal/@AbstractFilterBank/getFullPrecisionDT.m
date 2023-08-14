function fullPrecision=getFullPrecisionDT(this,blockInfo)









    inputDT=numerictype(blockInfo.DATA_SIGNED,blockInfo.DATA_WORDLENGTH,-blockInfo.DATA_FRACTIONLENGTH);
    coefDT=numerictype(blockInfo.COEF_SIGNED,blockInfo.COEF_WORDLENGTH,-blockInfo.COEF_FRACTIONLENGTH);
    if strcmpi(blockInfo.FilterCoefficientSource,'Input port (Parallel interface)')
        fullPrecision=fi([0,0],(coefDT.SignednessBool||inputDT.SignednessBool),coefDT.WordLength+inputDT.WordLength+ceil(log2(double(blockInfo.FilterLength))),coefDT.FractionLength+inputDT.FractionLength);
    else
        [fullPrecision,~]=coder.const(@dsp.internal.FIRFilterPrecision,...
        fi(reshape(blockInfo.FilterCoefficient,1,[]),coefDT,'RoundingMethod','Nearest'),inputDT);
    end









end
