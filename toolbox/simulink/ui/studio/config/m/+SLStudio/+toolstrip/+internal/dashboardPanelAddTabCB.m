

function dashboardPanelAddTabCB(cbinfo)
    panelInfo=SLStudio.Utils.getSelectedPanelInfo(cbinfo);
    if~isempty(panelInfo)
        editor=cbinfo.studio.App.getActiveEditor();
        SLM3I.SLDomain.addTabToPanel(editor,panelInfo.panelId);
    end
end