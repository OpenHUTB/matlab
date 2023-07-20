function menu=ctrlVarContextMenu(~,ctrlVarRow,dlg)







    menu=[];
    ssComp=dlg.getWidgetInterface('controlVariablesSSWidgetTag');
    rows=ssComp.getSelection;
    if isempty(rows)
        return;
    end
    rowArr=vertcat(rows{:});
    rowIdcs=[rowArr(:).CtrlVarIdx];
    modelName=ctrlVarRow.DialogSchema.BDName;
    isShowUsage=true;
    showUsageCommand=@(tag)slvariants.internal.manager.ui.config.highlightVarCtrlUsageCallback(modelName,rowIdcs,isShowUsage);
    showUsageLabel=message('Simulink:VariantManagerUI:ControlVariablesContextShowUsage').getString();

    menu=struct('label',showUsageLabel,...
    'checked',false,...
    'icon','',...
    'enabled',true,...
    'command',showUsageCommand,...
    'visible',true,...
    'tag',slvariants.internal.manager.ui.config.VMgrConstants.ShowUsage);
    hideUsageLabel=message('Simulink:VariantManagerUI:ControlVariablesContextHideUsage').getString();
    hideUsageCommand=@(tag)slvariants.internal.manager.ui.config.highlightVarCtrlUsageCallback(modelName,rowIdcs,~isShowUsage);

    menu(end+1)=struct('label',hideUsageLabel,...
    'checked',false,...
    'icon','',...
    'enabled',true,...
    'command',hideUsageCommand,...
    'visible',true,...
    'tag',slvariants.internal.manager.ui.config.VMgrConstants.HideUsage);
end


