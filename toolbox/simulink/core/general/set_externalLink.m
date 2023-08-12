function set_externalLink( blockPath, parameterName, symbolName, workspace )






if slfeature( 'ExplicitDataLinks' ) == 0
return ;
end 

set_param( blockPath, parameterName, symbolName );
setExplicitLink( blockPath, parameterName, workspace );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpSx_sHC.p.
% Please follow local copyright laws when handling this file.

