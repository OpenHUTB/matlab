%#codegen



function ScalingFactor=generateHypotScalingFactor(cfType)
    coder.allowpcode('plain');

    ML=cfType.HypotIntermediatePrec;
    WL=ML+cfType.ExponentLength;

    tmp=1;
    for ii=0:1:cfType.MantissaLength
        tmp(:)=tmp*(1+2^(-2*double(ii)));
    end

    tmp(:)=1/sqrt(tmp);

    Type=CustomFloatType(WL,ML);
    tmp_cf=CustomFloat(tmp,Type);
    tmp1=bitconcat(fi(1,0,1,0),tmp_cf.MantissaReal);
    ScalingFactor=reinterpretcast(tmp1,numerictype(0,ML+1,ML));
end
