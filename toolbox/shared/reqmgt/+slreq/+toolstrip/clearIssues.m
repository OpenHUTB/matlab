function clearIssues(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    appmgr=slreq.app.MainManager.getInstance();
    selection=appmgr.requirementsEditor.getCurrentSelection;


    if isempty(selection)
        return;
    end


    if isa(selection(1),'slreq.das.LinkSet')
        slreq.das.LinkSet.onClearOnChangeIssues();
    else
        slreq.das.Link.onClearingChangeIssue();
    end
end