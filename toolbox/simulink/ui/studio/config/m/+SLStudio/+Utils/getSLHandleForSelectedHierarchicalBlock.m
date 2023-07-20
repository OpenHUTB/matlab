function blkHandle=getSLHandleForSelectedHierarchicalBlock(cbinfo)









    obj=SLStudio.Utils.getOneMenuTarget(cbinfo);
    parent_hid=cbinfo.studio.App.getActiveEditor.getHierarchyId;
    if~isempty(obj)&&isvalid(obj)
        if isa(obj,'GLUE2.Diagram')
            hid=parent_hid;
        else
            hid=GLUE2.HierarchyServiceUtils.getElementHIDWithParent(obj,parent_hid);
        end
        if~GLUE2.HierarchyService.isValid(hid)
            hid=parent_hid;
        end
    else
        hid=parent_hid;
    end
    blkHandle=SLM3I.SLCommonDomain.getSLHandleForHID(hid);
end
