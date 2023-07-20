function open=isHIDOpenInAnyTab(studio,hid)




    exactMatch=false;
    if GLUE2.HierarchyService.isDiagram(hid)
        domain=GLUE2.HierarchyService.getDomainName(hid);
        switch domain
        case 'Simulink'
            exactMatch=true;
        case 'StudioAdapterDomain'
            p=GLUE2.HierarchyService.getParent(hid);
            h=SA_M3I.StudioAdapterDomain.getSLHandleForHID(p);
            exactMatch=~Stateflow.SLUtils.isStateflowBlock(h);
        end
    end

    open=false;
    tabbed_editors=GLUE2.Domain.findAllTabbedEditorsInStudio(studio);
    for index=1:length(tabbed_editors)
        editor=tabbed_editors(index);
        editor_hid=editor.getHierarchyId;
        if exactMatch
            open=hid.eq(editor_hid);
        else
            open=hid.refersToSameBackendObjectAs(editor_hid);
        end
        if open
            break;
        end
    end
end
