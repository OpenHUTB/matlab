function newType=adjustToLookupBlockSpecification(originalType,spacingValue)





















    newType=originalType;
    if isfi(spacingValue)&&spacingValue.isscalingslopebias
        cast1=fi(double(spacingValue),1,54);
    else
        cast1=fi(spacingValue,1,54);
    end

    success=false;
    while~success
        cast2=fi(cast1,newType);
        cast3=fi(cast2,1,54);

        if cast3==cast1
            success=true;
        else
            newType.WordLength=newType.WordLength+1;
            newType.FractionLength=newType.FractionLength+1;
        end
    end
end
