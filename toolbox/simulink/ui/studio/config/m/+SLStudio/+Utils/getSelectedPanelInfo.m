

function[panelInfo,block]=getSelectedPanelInfo(cbinfo)
    panelInfo=[];
    block=SLStudio.Utils.getSingleSelectedBlock(cbinfo);
    if~isempty(block)&&strcmp(block.type,'PanelWebBlock')
        panelInfoJson=get_param(block.handle,'PanelInfo');
        panelInfo=jsondecode(panelInfoJson);
    end
end