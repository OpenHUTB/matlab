function retValue = useFindSystemVariantsMatchFilter( variantControl )

arguments
    variantControl Simulink.internal.VariantsOptionRemoval ...
        = Simulink.internal.VariantsOptionRemoval.DEFAULT_TEMP_ACTIVEVARIANTS;
end

if variantControl == Simulink.internal.VariantsOptionRemoval.DEFAULT_ALLVARIANTS

    retValue = slfeature( 'FindSystemVariantsRemoval' ) >= 7;
else
    retValue = slfeature( 'FindSystemVariantsRemoval' ) > 0;
end
