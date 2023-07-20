

function dashboardPanelAddTabRF(cbinfo,action)
    action.enabled=false;
    panelInfo=SLStudio.Utils.getSelectedPanelInfo(cbinfo);
    if~isempty(panelInfo)
        action.enabled=true;
    end
end