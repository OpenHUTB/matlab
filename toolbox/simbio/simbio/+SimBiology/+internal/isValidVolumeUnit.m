function isValid=isValidVolumeUnit(unitString)

    [valid,qdObj]=SimBiology.internal.getPhysicalQuantityFromComposition(unitString);
    if valid
        hasVolume=qdObj.Length==3;
        hasExtraDimensions=qdObj.Temp~=0||qdObj.Current~=0||qdObj.LuminousIntensity~=0||...
        qdObj.Amount~=0||qdObj.Mass~=0||qdObj.Time~=0;
        isValid=hasVolume&&~hasExtraDimensions;
    else
        isValid=false;
    end
end
