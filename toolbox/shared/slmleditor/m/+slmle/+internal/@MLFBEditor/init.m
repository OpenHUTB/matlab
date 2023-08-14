function init(obj)




    persistent eid
    if isempty(eid)
        eid=1;
    else
        eid=eid+1;
    end
    obj.eid=eid;

    obj.type=slmle.internal.checkMLFBType(obj.objectId);
    obj.chartId=sf('get',obj.objectId,'state.chart');
    if strcmp(obj.type,'EMChart')
        obj.h=idToHandle(sfroot,obj.chartId);
    else
        obj.h=idToHandle(sfroot,obj.objectId);
    end


    m=slmle.internal.slmlemgr.getInstance;
    obj.listener=event.listener(m,'MLFB',@obj.callback);


    c=obj.studio.getService('GLUE2:EditorClosed');
    obj.editorCloseCBId=c.registerServiceCallback(@obj.onEditorClose);


    cAE=obj.studio.getService('GLUE2:ActiveEditorChanged');
    obj.activeEditorChangeCBId=cAE.registerServiceCallback(@obj.handleActiveEditorChanged);




    obj.fText=sf('get',obj.objectId,'state.eml.script');
