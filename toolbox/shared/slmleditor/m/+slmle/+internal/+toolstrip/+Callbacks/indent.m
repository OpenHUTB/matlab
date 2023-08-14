function indent(userdata,cbinfo)





    m=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    ed=m.getMLFBEditorByStudioAdapter(saEd);

    switch userdata
    case 'smart_indent'
        ed.publish('smart_indent',[]);
    case 'left_indent'
        ed.publish('left_indent',[]);
    case 'right_indent'
        ed.publish('right_indent',[]);
    otherwise
        return;
    end


    SLM3I.SLCommonDomain.focusEditorCEF(ed.ed);

end
