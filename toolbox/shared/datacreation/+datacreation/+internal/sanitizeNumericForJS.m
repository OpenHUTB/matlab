function returnVal=sanitizeNumericForJS(inVal)




    if isnan(inVal)
        returnVal='NaN';
        return;
    end

    if isinf(inVal)&&inVal>0
        returnVal='inf';
        return;
    end

    if isinf(inVal)&&inVal<0
        returnVal='-inf';
        return;
    end

    if isa(inVal,'embedded.fi')
        returnVal=double(inVal);
        return;
    end

    returnVal=inVal;
    return;
end
