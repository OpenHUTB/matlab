



function overrideActiveVariantCheckBoxActionCB(cbinfo)

    blocks=SLStudio.Utils.getSelectedBlocks(cbinfo);
    assert(isscalar(blocks));
    bh=blocks.handle;
    obj=get_param(bh,'Object');

    wasOverrideVariant=~isempty(get_param(bh,'LabelModeActiveChoice'));

    if wasOverrideVariant
        obj.LabelModeActiveChoice='';



    else
        variantNames=SLStudio.toolstrip.internal.getVariantInfoFromBlock(bh);
        obj.LabelModeActiveChoice=variantNames{1};

    end

end