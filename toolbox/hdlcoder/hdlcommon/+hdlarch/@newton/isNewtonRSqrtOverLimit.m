function isover=isNewtonRSqrtOverLimit(hInSignals,intermType)





    inputType=hInSignals(1).Type.getLeafType;
    inputWL=inputType.WordLength;
    inputFL=-inputType.FractionLength;
    maxDynamicShift=ceil((max(inputWL,inputFL))/2)-1;
    preshiftWL=intermType.WordLength+maxDynamicShift;

    if preshiftWL>128;
        isover=true;
    else
        isover=false;
    end

