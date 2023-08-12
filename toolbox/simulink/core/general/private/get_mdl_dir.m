function oDir = get_mdl_dir( iMdl )




oDir = '';



try 
fullPath = get_param( iMdl, 'FileName' );
catch 
fullPath = sls_resolvename( iMdl );
end 


if ( ~isempty( dir( fullPath ) ) )
oDir = fileparts( fullPath );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqseS1f.p.
% Please follow local copyright laws when handling this file.

