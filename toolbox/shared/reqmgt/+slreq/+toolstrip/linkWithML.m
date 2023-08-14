function linkWithML(cbinfo)
    slreq.toolstrip.activateEditor(cbinfo);
    unBlock=slreq.app.MainManager.blockEditors();
    slreq.das.Requirement.onLinkToSelectedML();
end