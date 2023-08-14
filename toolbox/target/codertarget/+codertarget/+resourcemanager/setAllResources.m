function data=setAllResources(hCS,data)





    mobj=get_param(hCS.getModel(),'object');
    if mobj.isHierarchyBuilding
        set_param(hCS,'DynamicTargetHardwareResourcesBuilding',data);
    else
        set_param(hCS,'DynamicTargetHardwareResourcesUpdating',data);
    end

end