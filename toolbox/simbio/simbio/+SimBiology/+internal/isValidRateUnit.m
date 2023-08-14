function isValid=isValidRateUnit(unitString)

    [valid,qdObj]=SimBiology.internal.getPhysicalQuantityFromComposition(unitString);
    if valid
        hasRate=xor(qdObj.Amount==1,qdObj.Mass==1)&&qdObj.Time==-1;
        hasExtraDimensions=qdObj.Length~=0||qdObj.Temp~=0||qdObj.Current~=0||qdObj.LuminousIntensity~=0;
        isValid=hasRate&&~hasExtraDimensions;
    else
        isValid=false;
    end
end
