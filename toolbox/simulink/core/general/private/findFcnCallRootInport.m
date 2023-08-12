function result = findFcnCallRootInport( model )




model = get_param( model, 'Handle' );
result = find_system( model, 'SearchDepth', 1,  ...
'BlockType', 'Inport',  ...
'OutputFunctionCall', 'on' );
return ;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpzkcyRU.p.
% Please follow local copyright laws when handling this file.

