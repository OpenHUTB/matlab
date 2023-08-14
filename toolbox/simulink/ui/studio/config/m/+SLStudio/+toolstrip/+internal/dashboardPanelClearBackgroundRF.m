

function dashboardPanelClearBackgroundRF(cbinfo,action)
    action.enabled=false;
    [panelInfo,block]=SLStudio.Utils.getSelectedPanelInfo(cbinfo);
    if~isempty(panelInfo)
        action.enabled=~isempty(get_param(block.handle,'PanelBackground'));
    end
end