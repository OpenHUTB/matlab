function modelddg_file_cb(h,dlgH)



    h2=h.getWorkspace;
    val=dlgH.getWidgetValue('WorkspaceFile');
    h2.FileName=val;
