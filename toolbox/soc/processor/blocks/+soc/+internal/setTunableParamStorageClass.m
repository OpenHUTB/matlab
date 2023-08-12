function msg = setTunableParamStorageClass( tunableParamName )




evalin( 'base', tunableParamName + ".CoderInfo.StorageClass = 'ExportedGlobal';" );
msg = "Set storage class of '" + tunableParamName + "' to 'ExportedGlobal'.";
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpLZkf59.p.
% Please follow local copyright laws when handling this file.

