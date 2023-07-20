

function dashboardPanelFitPanelsToViewCB(cbinfo)
    editor=cbinfo.studio.App.getActiveEditor();
    if~isempty(SLM3I.SLDomain.getPanelIdsForEditor(editor))
        SLM3I.SLDomain.fitVisiblePanelsToCurrentView(editor);
    end
end