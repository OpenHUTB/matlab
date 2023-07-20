function switchColumnsView(cbinfo)





    ed=Simulink.typeeditor.app.Editor.getInstance;

    if ed.isVisible
        viewChoice=cbinfo.EventData;
        ed.setColumnView(viewChoice);
        listProps=Simulink.typeeditor.app.Editor.getColumnsForView(viewChoice);
        colMenuProps=listProps(~strcmp(DAStudio.message('Simulink:busEditor:PropElementName'),listProps));
        lc=ed.getListComp;
        lc.setColumns(listProps,'','',false);
        lc.setColumnMenu(colMenuProps);
        lc.update(true);
    end