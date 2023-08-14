

function dashboardPanelCollapseCB(cbinfo)
    panelInfo=SLStudio.Utils.getSelectedPanelInfo(cbinfo);
    if~isempty(panelInfo)
        editor=cbinfo.studio.App.getActiveEditor();
        SLM3I.SLDomain.setPanelCompacted(editor,panelInfo.panelId,~panelInfo.compacted);
    end
end