function maskObject=initializeMask(variantSystemHandle)





    schema=FunctionApproximation.internal.approximationblock.BlockSchema();
    v=get_param(variantSystemHandle,schema.FunctionVersionParameterName);
    variantsOff={};
    variantChoices=get_param(variantSystemHandle,'Variants');
    for iChoice=1:numel(variantChoices)
        block=variantChoices(iChoice).BlockName;
        variantTag=get_param(block,'Tag');
        if strcmp(variantTag,v)

            variantOn=variantTag;
            set_param(block,'VariantControl','eval(''true'');');
        else
            variantsOff{end+1}=variantTag;%#ok<AGROW>
            set_param(block,'VariantControl','eval(''false'');');
        end
    end

    maskObject=Simulink.Mask.get(variantSystemHandle);
    control=maskObject.getDialogControl(schema.CompareParameterName);
    if~isempty(control)
        control.Enabled='off';
        if~strcmp(variantOn,schema.getTagForOriginal())

            control.Enabled='on';
        end
    end
end