

function dashboardPanelAddBackgroundCB(cbinfo)
    panelInfo=SLStudio.Utils.getSelectedPanelInfo(cbinfo);
    if~isempty(panelInfo)
        editor=cbinfo.studio.App.getActiveEditor();
        addPanelBackgroundFromToolstrip(editor,panelInfo.panelId);
    end
end