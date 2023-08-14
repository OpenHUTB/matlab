function data=getAllResources(hCS)







    mobj=get_param(hCS.getModel(),'object');
    if~isempty(mobj)
        if mobj.isHierarchyBuilding
            data=get_param(hCS,'DynamicTargetHardwareResourcesBuilding');
        else
            data=get_param(hCS,'DynamicTargetHardwareResourcesUpdating');
        end
    else
        data=[];
    end

end