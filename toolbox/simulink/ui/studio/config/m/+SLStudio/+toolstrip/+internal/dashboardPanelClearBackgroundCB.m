

function dashboardPanelClearBackgroundCB(cbinfo)
    panelInfo=SLStudio.Utils.getSelectedPanelInfo(cbinfo);
    if~isempty(panelInfo)
        editor=cbinfo.studio.App.getActiveEditor();
        SLM3I.SLDomain.clearPanelBackground(editor,panelInfo.panelId);
    end
end