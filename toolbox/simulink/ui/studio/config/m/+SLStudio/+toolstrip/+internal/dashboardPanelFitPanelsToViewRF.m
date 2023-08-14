

function dashboardPanelFitPanelsToViewRF(cbinfo,action)
    action.enabled=false;
    editor=cbinfo.studio.App.getActiveEditor();
    if~isempty(SLM3I.SLDomain.getPanelIdsForEditor(editor))
        action.enabled=true;
    end
end