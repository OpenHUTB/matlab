function onEditorClose(obj,cbinfo)





    if cbinfo.EventData==obj.ed

        obj.ready=true;

        obj.closed=true;


        if isvalid(obj.studio)
            c=obj.studio.getService('GLUE2:EditorClosed');
            c.unRegisterServiceCallback(obj.editorCloseCBId);
            cAE=obj.studio.getService('GLUE2:ActiveEditorChanged');
            cAE.unRegisterServiceCallback(obj.activeEditorChangeCBId);
        end


        m=slmle.internal.slmlemgr.getInstance;
        m.cleanupMLFBEditorMap;
    end
