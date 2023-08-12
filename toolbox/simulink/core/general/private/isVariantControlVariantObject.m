function isVariantObject = isVariantControlVariantObject( block, control )




isVariantObject = false;
try %#ok<TRYNC>


control = strtrim( control );














isVariantObject = isvarname( control ) && existsInGlobalScope( bdroot( block ), control ) &&  ...
evalinGlobalScope( bdroot( block ), [ 'isa(', control, ', ''Simulink.Variant'');' ] );
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpauWaX2.p.
% Please follow local copyright laws when handling this file.

