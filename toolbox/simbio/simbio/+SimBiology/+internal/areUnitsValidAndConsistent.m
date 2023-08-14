function tfConsistent=areUnitsValidAndConsistent(unit1,unit2)


















    if isempty(unit1)||isempty(unit2)
        tfConsistent=false;
        return
    end
    [valid1,qdObj1]=SimBiology.internal.getPhysicalQuantityFromComposition(unit1);
    [valid2,qdObj2]=SimBiology.internal.getPhysicalQuantityFromComposition(unit2);
    if~valid1||~valid2

        tfConsistent=false;
        return
    end
    tfConsistent=qdObj1.Time==qdObj2.Time&&qdObj1.Amount==qdObj2.Amount&&...
    qdObj1.Mass==qdObj2.Mass&&qdObj1.Length==qdObj2.Length&&...
    qdObj1.Temp==qdObj2.Temp&&qdObj1.Current==qdObj2.Current&&...
    qdObj1.LuminousIntensity==qdObj2.LuminousIntensity;
end
