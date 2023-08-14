

function blockPath=getBlockPathToEditor(editor)
    hid=editor.getHierarchyId();
    if(GLUE2.HierarchyService.isTopLevel(hid))
        obj=GLUE2.HierarchyService.getM3IObject(hid).temporaryObject;
        blockPath=obj.getName();
    else
        hid=GLUE2.HierarchyService.getParent(hid);
        obj=GLUE2.HierarchyService.getM3IObject(hid).temporaryObject;
        handle=obj.handle;
        hid=GLUE2.HierarchyService.getParent(hid);
        blockPath=Simulink.BlockPath.fromHierarchyIdAndHandle(hid,handle);
    end
end
