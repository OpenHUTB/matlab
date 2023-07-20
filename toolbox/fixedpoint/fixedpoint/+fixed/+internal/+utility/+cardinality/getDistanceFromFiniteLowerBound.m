function distances=getDistanceFromFiniteLowerBound(values)





























    datatype=fixed.internal.type.extractNumericType(values);
    lowerBoundInteger=fixed.internal.utility.cardinality.getEncodedIntegerForLowerBound(datatype);
    if fixed.internal.type.isAnyFloat(datatype)
        lowerboundToNegativeEpsOfZero=fixed.internal.utility.cardinality.getLowerBoundToNegativeEpsOfZeroDistance(datatype);
        castFunction=fixed.internal.utility.cardinality.getCastToIntegerFunctionForFloatingPoint(datatype);
        distances=zeros(size(values),'like',lowerBoundInteger);
        negativeValues=values<0;
        positiveValues=values>0;
        zeroValues=values==0;
        negativeZeroValues=fixed.internal.utility.isnegzero(values);
        positiveZeroValues=zeroValues&~negativeZeroValues;
        distances(negativeValues)=lowerBoundInteger-castFunction(values(negativeValues))+1;
        distances(positiveValues)=lowerboundToNegativeEpsOfZero+2+castFunction(values(positiveValues));
        distances(negativeZeroValues)=lowerboundToNegativeEpsOfZero+1;
        distances(positiveZeroValues)=lowerboundToNegativeEpsOfZero+2;
    else
        if isboolean(datatype)
            integerValues=fixed.internal.math.castLogicalToUfix1(values);
        else
            if~isfi(values)

                values=fi(values,datatype);
            end
            integerValues=fixed.internal.type.stripScaling(values);
        end
        distances=fixed.internal.math.subtractBinPtFullPrec(integerValues,lowerBoundInteger);
        wl=datatype.WordLength;
        dtOutput=numerictype(0,wl+1,0);
        distances=fi(distances,dtOutput);
    end
end