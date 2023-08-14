function owner=getContextFromStudioSpawningInfo(BD)
    owner=[];

    targetEditor=getEditorByBDHandle(BD);
    if~isempty(targetEditor)
        hid=targetEditor.getHierarchyId;
        pid=GLUE2.HierarchyService.getParent(hid);

        if(GLUE2.HierarchyService.isValid(pid))
            m3iobj=GLUE2.HierarchyService.getM3IObject(pid);
            block=m3iobj.temporaryObject;
            blockHandle=block.handle;
            owner=blockHandle;
        end
    else
        return
    end
end
