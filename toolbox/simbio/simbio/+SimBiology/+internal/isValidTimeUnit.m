function isValid=isValidTimeUnit(unitString)

    [valid,qdObj]=SimBiology.internal.getPhysicalQuantityFromComposition(unitString);
    if valid
        hasTime=qdObj.Time==1;
        hasExtraDimensions=qdObj.Amount~=0||qdObj.Mass~=0||qdObj.Length~=0||qdObj.Temp~=0||qdObj.Current~=0||qdObj.LuminousIntensity~=0;
        isValid=hasTime&&~hasExtraDimensions;
    else
        isValid=false;
    end
end
