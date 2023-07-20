

function dashboardPanelCollapseRF(cbinfo,action)
    action.enabled=false;



    editor=cbinfo.studio.App.getActiveEditor();
    if SLM3I.SLDomain.getPanelEditModeForEditor(editor)
        return;
    end
    panelInfo=SLStudio.Utils.getSelectedPanelInfo(cbinfo);
    if~isempty(panelInfo)
        action.selected=panelInfo.compacted;
        action.enabled=true;
    end
end