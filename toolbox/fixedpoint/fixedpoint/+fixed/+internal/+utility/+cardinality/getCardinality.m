function cardinality=getCardinality(intervalObject,datatype,includeNegativeZero)



































    assert(isscalar(intervalObject),'Interval object must be a non-empty scalar.');
    assert(isfinite(intervalObject.LeftEnd)&&isfinite(intervalObject.RightEnd),'Interval ends must be finite.');
    assert(~isnan(intervalObject),'Interval ends must not be NaN.');

    maxWL=fixed.internal.type.fiMaxWordLength-2;
    datatype=fixed.internal.type.extractNumericType(datatype);
    wlAssertMessage=['Word length exceeds max value of ',int2str(maxWL)];
    assert(datatype.WordLength<=maxWL,wlAssertMessage);

    if nargin<3
        includeNegativeZero=true;
    end

    quantizedValues=quantize(intervalObject,datatype);
    cardinality=uint64(0);
    if~isempty(quantizedValues)
        distances=fixed.internal.utility.cardinality.getDistanceFromFiniteLowerBound(quantizedValues);
        cardinality=cast(distances(end)-distances(1)+1,'like',distances(1));
        if~includeNegativeZero&&fixed.internal.type.isAnyFloat(datatype)
            cutOff=fixed.internal.utility.cardinality.getLowerBoundToNegativeEpsOfZeroDistance(datatype)+1;
            if distances(1)<=cutOff&&distances(end)>=cutOff
                cardinality=cast(cardinality-1,'like',cardinality);
            end
        end
    end
    nt=fixed.internal.type.extractNumericType(cardinality);
    if nt.WordLength<=64
        cardinality=uint64(cardinality);
    end
end