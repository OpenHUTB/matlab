function gr=getAutoMeshGrowthRate(obj)

    if getMesherType(obj)
        gr=getNewMesherGrowthRate(obj);
    else
        gr=getOldMesherGrowthRate(obj);
    end

end