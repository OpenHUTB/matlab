function maskVal=convertMaskValueToInt(paramVal)

    if ischar(paramVal)
        maskVal=paramVal;
    elseif isfi(paramVal)
        maskVal=int(paramVal);
    elseif isinteger(paramVal)||islogical(paramVal)
        val=pirelab.convertInt2fi(paramVal);
        maskVal=int(val);
    else
        maskVal=paramVal;
    end
end