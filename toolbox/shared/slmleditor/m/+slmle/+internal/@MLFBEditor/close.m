function close(obj)




    ed=obj.ed;
    studio=ed.getStudio();


    c=studio.getService('GLUE2:EditorClosed');
    c.unRegisterServiceCallback(obj.editorCloseCBId);
    cAE=studio.getService('GLUE2:ActiveEditorChanged');
    cAE.unRegisterServiceCallback(obj.activeEditorChangeCBId);

    SLM3I.SLCommonDomain.removeWebContentFromEditor(ed);

    if(studio.getTabCount()==1&&ed.isVisible)

        ed.gotoParent;
    else
        studio.App.closeEditor(ed);
    end


    obj.ready=true;
    obj.closed=true;
    m=slmle.internal.slmlemgr.getInstance;
    m.cleanupMLFBEditorMap;

    if isa(sf('IdToHandle',obj.chartId),'Stateflow.EMChart')||...
        isa(sf('IdToHandle',obj.objectId),'Stateflow.EMFunction')
        obj.unregisterFocusListener();
    end

