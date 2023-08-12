function retValue = useFindSystemVariantsMatchFilter( variantControl )




R36
variantControl Simulink.internal.VariantsOptionRemoval ...
 = Simulink.internal.VariantsOptionRemoval.DEFAULT_TEMP_ACTIVEVARIANTS;
end 
















if variantControl == Simulink.internal.VariantsOptionRemoval.DEFAULT_ALLVARIANTS

retValue = slfeature( 'FindSystemVariantsRemoval' ) >= 7;
else 
retValue = slfeature( 'FindSystemVariantsRemoval' ) > 0;
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpxf49nj.p.
% Please follow local copyright laws when handling this file.

