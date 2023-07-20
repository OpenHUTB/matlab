

function PanelWebBlockDialogPropertyCB(dlg,obj)
    blockHandle=get(obj.blockObj,'handle');

    newName=strtrim(dlg.getWidgetValue('panelName'));
    dlg.setWidgetValue('panelName',newName);
    panelInfo=jsondecode(get_param(blockHandle,'PanelInfo'));
    oldName=panelInfo.name;


    if strcmp(oldName,newName)
        dlg.clearWidgetDirtyFlag('panelName');
        dlg.clearWidgetWithError('panelName');
        return;
    end


    blockDiagramHandle=bdroot(blockHandle);
    if~isempty(newName)&&~SLM3I.SLDomain.isPanelNameUnique(bdroot(blockDiagramHandle),newName)
        dlg.setWidgetWithError('panelName',...
        DAStudio.UI.Util.Error('panelName','Error',...
        message('simulink_ui:webblocks:resources:PanelNameMustBeUnique').getString(),...
        [255,0,0,100]));
        return;
    end


    panelInfo.name=newName;
    set_param(blockHandle,'PanelInfo',jsonencode(panelInfo));
    dlg.clearWidgetDirtyFlag('panelName');
    dlg.clearWidgetWithError('panelName');
end
