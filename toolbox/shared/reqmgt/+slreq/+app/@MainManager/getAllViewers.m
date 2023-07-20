function allViewers=getAllViewers(this)



    spmgr=this.spreadsheetManager;
    if isempty(spmgr)
        allViewers={};
    else
        allViewers=spmgr.spreadSheetMap.values;
    end
    editorViewer=this.requirementsEditor;
    if~isempty(editorViewer)
        allViewers=[allViewers,{editorViewer}];
    end
end