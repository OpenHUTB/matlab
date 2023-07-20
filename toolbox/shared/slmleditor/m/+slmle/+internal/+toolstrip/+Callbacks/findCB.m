function findCB(userdata,cbinfo)

    mgr=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    ed=mgr.getMLFBEditorByStudioAdapter(saEd);

    if strcmpi(userdata,'find')
        ed.publish('find_text',[]);
    end


    SLM3I.SLCommonDomain.focusEditorCEF(ed.ed);