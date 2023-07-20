

function dashboardBlockShowPanelMenuActionCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor();
    if~isempty(SLM3I.SLDomain.getPanelIdsForEditor(editor))
        SLM3I.SLDomain.showPanelMetaMenuForEditor(editor);
    end
end
