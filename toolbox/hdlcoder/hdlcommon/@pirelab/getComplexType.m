






function cplxType=getComplexType(pirType)
    if(pirType.isArrayType)
        cplxType=pirelab.getComplexType(pirType.BaseType);
    elseif pirType.isComplexType
        cplxType=pirType;
    else
        cplxType=[];
    end
    return
end
