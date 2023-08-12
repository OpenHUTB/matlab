function [ ok, errorid ] = updateVariantObjectInBlockDialogs( dialog, name )



ok = true;
errorid = '';


dialogSource = dialog.getSource;
if isa( dialogSource, 'Simulink.Variant' )
variantObject = dialogSource;
else 
variantObject = dialogSource.getForwardedObject;
end 
assert( isa( variantObject, 'Simulink.Variant' ) );


subsysVariantsddg_cb( 'UpdateObject', variantObject, name );
mdlrefddg_cb( 'UpdateObject', variantObject, name );
variantSourceSinkddg_cb( 'UpdateObject', variantObject, name );
variantPMConnectorddg_cb( 'UpdateObject', variantObject, name );

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp79clH2.p.
% Please follow local copyright laws when handling this file.

