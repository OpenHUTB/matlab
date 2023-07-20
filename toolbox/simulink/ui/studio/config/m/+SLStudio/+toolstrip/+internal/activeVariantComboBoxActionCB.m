



function activeVariantComboBoxActionCB(cbinfo)

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    assert(isscalar(blocks));
    bh=blocks.handle;

    [variantNames,~,comboBoxEntries]=SLStudio.toolstrip.internal.getVariantInfoFromBlock(bh);

    if~isempty(variantNames)
        selectedVariantComboBox=cbinfo.EventData;
        idx=find(strcmp(comboBoxEntries,selectedVariantComboBox),1);
        selectedVariant=variantNames{idx};
        set_param(bh,'LabelModeActiveChoice',selectedVariant)
    end

end

