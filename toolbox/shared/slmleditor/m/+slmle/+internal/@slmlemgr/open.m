function editor=open(obj,objectId,blkH,studio)




    if nargin<3||isempty(blkH)
        blkH=slmle.internal.getBlockHandleFromObjectId(objectId);
    end

    if nargin<4
        if GLUE2.StudioApp.isInInteractiveOpen()
            studioApp=GLUE2.StudioApp.getStudioAppForInteractiveOpen();
            newApp=GLUE2.StudioApp.getNewWindowStudioAppForInteractiveOpen();
            if(~isempty(newApp))
                studioApp=newApp;
            end
            studio=studioApp.getStudio();
        else
            [studio,~]=slmle.internal.getStudioHandleFromBlockHandle(blkH);
        end
        if isempty(studio)


            studioApp=SLM3I.StudioApp;
            studio=DAS.Studio(studioApp);
            studio.initialize;
            studioApp.allowUpdateActiveContext();
        end
        studio.show;
    end

    if obj.debug
        SLM3I.SLDomain.setSharedWebBrowserInspector(true);
    end


    type=slmle.internal.checkMLFBType(objectId);


    if strcmp(type,'EMChart')
        adapterDiagram=SA_M3I.StudioAdapterDomain.getCreateStudioAdapterDiagramForBlockHandle(blkH);
    else
        adapterDiagram=SA_M3I.StudioAdapterDomain.getCreateStudioAdapterDiagramForStateflow(blkH,objectId);
    end

    openType='';
    adapterEditor=SLStudio.StudioAdapter.openStudioAdapterEditor(adapterDiagram,openType,studio);


    newStudio=adapterEditor.getStudio;


    editor=obj.addMLFBEditor(objectId,blkH,newStudio);
    editor.ed=adapterEditor;


    editor.open();