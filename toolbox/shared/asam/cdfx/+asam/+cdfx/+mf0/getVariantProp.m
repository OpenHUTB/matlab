function propElement=getVariantProp(inst,variantIndex)








    if isempty(inst.SW_INSTANCE_PROPS_VARIANTS)
        error(message('asam_cdfx:CDFX:UnexpectedVariantProperties',asam.cdfx.mf0.getShortName(inst)));
    end


    propElement=inst.SW_INSTANCE_PROPS_VARIANTS.SW_INSTANCE_PROPS_VARIANT(1);
end

