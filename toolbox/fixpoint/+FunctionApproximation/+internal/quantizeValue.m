function quantizedValue=quantizeValue(value,dataType)






    if fixed.internal.type.isAnyFloat(dataType)

        if ishalf(dataType)
            value=min(max(value,-half.realmax()),half.realmax());
            quantizedValue=double(half(value));
        elseif issingle(dataType)
            value=min(max(value,-realmax('single')),realmax('single'));
            quantizedValue=double(single(value));
        else
            quantizedValue=double(value);
        end
    else

        slAdj=dataType.SlopeAdjustmentFactor;
        bias=dataType.Bias;
        newValue=(value-bias)/slAdj;
        slope=dataType.Slope/slAdj;
        scaledValue=newValue/slope;
        scaledValue=round(scaledValue);
        wl=dataType.WordLength;
        s=dataType.SignednessBool;
        scaledValue=min(scaledValue,(2^(wl-s))-1);
        scaledValue=max(scaledValue,-s*2^(wl-1));
        quantizedValue=scaledValue*slope;
        quantizedValue=quantizedValue*slAdj+bias;
    end
end
