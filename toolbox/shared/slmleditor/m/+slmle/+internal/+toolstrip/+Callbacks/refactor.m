function refactor(userdata,cbinfo)





    m=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    ed=m.getMLFBEditorByStudioAdapter(saEd);

    switch userdata
    case 'refactor_local_fxn'
        ed.publish('refactor_local_fxn',[]);
    case 'refactor_external_fxn'
        ed.publish('refactor_external_fxn',[]);
    otherwise
        return;
    end


    SLM3I.SLCommonDomain.focusEditorCEF(ed.ed);

end
