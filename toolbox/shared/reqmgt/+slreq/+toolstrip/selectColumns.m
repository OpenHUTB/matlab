function selectColumns(cbinfo)
    if nargin>0
        slreq.toolstrip.activateEditor(cbinfo);
    end
    editorname='#?#standalonecontext#?#';
    slreq.gui.ColumnSelector.show(editorname);
end