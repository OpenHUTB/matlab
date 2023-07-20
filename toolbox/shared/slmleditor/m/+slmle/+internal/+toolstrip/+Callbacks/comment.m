function comment(userdata,cbinfo)




    mgr=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    ed=mgr.getMLFBEditorByStudioAdapter(saEd);

    switch userdata
    case 'comment_out_line'
        ed.publish('comment_out_line',[]);
    case 'uncomment_line'
        ed.publish('uncomment_line',[]);
    case 'wrap_comments'
        ed.publish('wrap_comments',[]);
    otherwise
        return;
    end


    SLM3I.SLCommonDomain.focusEditorCEF(ed.ed);

