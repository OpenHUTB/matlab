function print(userdata,cbinfo)


    mgr=slmle.internal.slmlemgr.getInstance;
    saEd=cbinfo.studio.App.getActiveEditor;
    ed=mgr.getMLFBEditorByStudioAdapter(saEd);

    switch userdata
    case 'print'
        ed.publish('print_code',[]);
    case 'print_selection'
        ed.publish('print_selection',[]);
    case 'print_setup'
        ed.publish('print_setup',[]);
    otherwise
    end