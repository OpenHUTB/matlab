function adapterEditor=openStudioAdapterEditor(adapterDiagram,openTypeStr,studio)

    if nargin<3
        if GLUE2.StudioApp.isInInteractiveOpen
            studioApp=GLUE2.StudioApp.getStudioAppForInteractiveOpen();
        else
            studioApp=SLM3I.SLDomain.getLastActiveStudioAppFor(bdroot(adapterDiagram.blockHandle));
        end
        if isempty(studioApp)
            studioApp=SLM3I.StudioApp;
            studio=DAS.Studio(studioApp);
            studio.initialize;
            studioApp.allowUpdateActiveContext();
        end
    else
        studioApp=studio.App;
    end


    config=dig.Configuration.get();
    service=dig.ActionService(config);
    service.flushRefreshQueue;



    if~isempty(openTypeStr)&&~strcmp(openTypeStr,studioApp.getEditorOpenType())

        savedType=studioApp.getEditorOpenType();
        scopedOpenTypeRestore=onCleanup(@()studioApp.setEditorOpenType(savedType));
        studioApp.setEditorOpenType(openTypeStr);
    end

    editorHID=GLUE2.HierarchyServiceUtils.getDefaultHID(adapterDiagram);
    if studioApp.isInInteractiveOpen
        editorHID=studioApp.getHIDOfObjectBeingOpenedInteractively;
        if GLUE2.HierarchyService.isValid(editorHID)
            if GLUE2.HierarchyService.isElement(editorHID)
                editorHID=GLUE2.HierarchyServiceUtils.getDiagramHIDWithParent(adapterDiagram,editorHID);
            end
        end
    end

    adapterEditor=studioApp.openEditorWithHID(adapterDiagram,editorHID);
end
