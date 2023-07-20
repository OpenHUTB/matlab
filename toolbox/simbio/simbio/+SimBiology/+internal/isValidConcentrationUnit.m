function isValid=isValidConcentrationUnit(unitString)

    [valid,qdObj]=SimBiology.internal.getPhysicalQuantityFromComposition(unitString);
    if valid
        hasConcentration=xor(qdObj.Amount==1,qdObj.Mass==1)&&qdObj.Length==-3;
        hasExtraDimensions=qdObj.Temp~=0||qdObj.Current~=0||qdObj.LuminousIntensity~=0||qdObj.Time~=0;
        isValid=hasConcentration&&~hasExtraDimensions;
    else
        isValid=false;
    end
end
