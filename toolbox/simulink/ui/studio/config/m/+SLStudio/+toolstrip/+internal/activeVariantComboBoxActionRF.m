



function activeVariantComboBoxActionRF(cbinfo,action)

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);

    if isempty(blocks)
        action.enabled=false;
        return;
    end
    action.enabled=true;

    assert(isscalar(blocks));
    bh=blocks.handle;

    overrideVariant=get_param(bh,'LabelModeActiveChoice');
    isVaraintOverride=~isempty(overrideVariant);

    [variantNames,~,comboBoxEntries]=SLStudio.toolstrip.internal.getVariantInfoFromBlock(bh);

    if~isempty(comboBoxEntries)
        idx=find(strcmp(variantNames,overrideVariant),1);
        if isempty(idx)
            idx=1;
            comboBoxEntries=[{message('simulink_ui:studio:resources:selectVariantText').getString()},comboBoxEntries(1:end)];
        end
        stringValue=comboBoxEntries{idx};
    else
        stringValue='';
    end

    action.validateAndSetEntries(comboBoxEntries);
    action.selectedItem=stringValue;
end

