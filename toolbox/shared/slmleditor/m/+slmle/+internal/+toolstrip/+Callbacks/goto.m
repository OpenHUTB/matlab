function goto(userdata,cbinfo,lineNum)




    m=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    ed=m.getMLFBEditorByStudioAdapter(saEd);

    switch userdata
    case 'goto_line'
        ed.publish('goto_popup',[]);
    case 'goto_functions'
        data.lineNum=lineNum;
        ed.publish('goto_functions',data);
    end


    SLM3I.SLCommonDomain.focusEditorCEF(ed.ed);
