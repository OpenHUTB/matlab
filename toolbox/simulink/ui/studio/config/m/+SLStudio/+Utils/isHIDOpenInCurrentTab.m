function open=isHIDOpenInCurrentTab(studio,hid)




    active_editor=studio.App.getActiveEditor;
    active_editor_hid=active_editor.getHierarchyId;
    if GLUE2.HierarchyService.isDiagram(hid)||GLUE2.HierarchyService.isTopLevel(active_editor_hid)
        active_editor_parent_hid=active_editor_hid;
    else
        active_editor_parent_hid=GLUE2.HierarchyService.getParent(active_editor_hid);
    end
    if active_editor_parent_hid==hid
        open=true;
    else
        open=false;
    end
end
