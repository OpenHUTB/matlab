function isValid=isValidAmountUnit(unitString)

    [valid,qdObj]=SimBiology.internal.getPhysicalQuantityFromComposition(unitString);
    if valid
        hasAmount=xor(qdObj.Amount==1,qdObj.Mass==1);
        hasExtraDimensions=qdObj.Time~=0||qdObj.Length~=0||qdObj.Temp~=0||qdObj.Current~=0||qdObj.LuminousIntensity~=0;
        isValid=hasAmount&&~hasExtraDimensions;
    else
        isValid=false;
    end
end
