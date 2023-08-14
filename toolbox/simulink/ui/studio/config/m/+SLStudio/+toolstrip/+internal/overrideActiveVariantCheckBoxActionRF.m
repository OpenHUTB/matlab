



function overrideActiveVariantCheckBoxActionRF(cbinfo,action)

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

    action.selected=isVaraintOverride;
end

