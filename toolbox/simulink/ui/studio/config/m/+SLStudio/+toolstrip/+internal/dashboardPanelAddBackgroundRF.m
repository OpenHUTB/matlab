

function dashboardPanelAddBackgroundRF(cbinfo,action)
    action.enabled=false;
    [panelInfo,block]=SLStudio.Utils.getSelectedPanelInfo(cbinfo);
    if~isempty(panelInfo)
        hasBackground=~isempty(get_param(block.handle,'PanelBackground'));
        if hasBackground
            action.text='simulink_ui:studio:resources:dashboardPanelChangeBackgroundLabel';
        else
            action.text='simulink_ui:studio:resources:dashboardPanelAddBackgroundLabel';
        end
        action.enabled=true;
    end
end