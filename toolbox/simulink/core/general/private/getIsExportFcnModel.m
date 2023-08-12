function result = getIsExportFcnModel( model )

result = false;

if strcmpi( get_param( model, 'Type' ), 'block_diagram' )
result = strcmpi( get_param( model, 'IsExportFunctionModel' ), 'on' );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcMI242.p.
% Please follow local copyright laws when handling this file.

