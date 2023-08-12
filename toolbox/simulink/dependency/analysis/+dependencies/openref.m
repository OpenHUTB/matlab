function openref( type, location )










R36
type( 1, : )char;
location( 1, : )char;
end 



specific_problems = { '.dll', '.mat', '.p', '.fig', '.so', '.stl', '.slmx' };

wildcard_problems = { '.mex' };

[ ~, ~, ext ] = fileparts( location );
if any( strcmp( ext, specific_problems ) ) || any( strncmp( ext, wildcard_problems, 4 ) )
i_error( dependencies.message( 'CannotOpenFileType', ext ) );
return 
end 

[ node, location ] = i_node_from_location( location );

location = i_handleCodeLocation( location, type );

dependency = dependencies.internal.graph.Dependency(  ...
node, location, node, location, type,  ...
dependencies.internal.graph.Dependencies.SourceRelationship );

try 
dependencies.internal.action.openUpstream( dependency )
catch ME
i_error( ME.message );
end 
end 



function [ node, location_out ] = i_node_from_location( location )
ind = strfind( location, dependencies.testHarnessDelimiter );
is_harness = ~isempty( ind );
if is_harness
lenDelim = length( dependencies.testHarnessDelimiter );
block_name = location( 1:ind - 1 );
file_location_to_adapt = block_name;
location_out = location( ind + lenDelim:end  );
harness_name = strtok( location_out, '/' );
else 
file_location_to_adapt = location;
location_out = location;
end 

file_location = i_find_existing_location( file_location_to_adapt );

if is_harness
node = dependencies.internal.graph.Nodes.createTestHarnessNode(  ...
file_location, block_name, harness_name );
else 
node = dependencies.internal.analysis.findFile( file_location );
if ~node.Resolved
symNode = dependencies.internal.analysis.findSymbol( file_location );
if symNode.isFile && symNode.Resolved
node = symNode;
end 
end 
end 

end 



function location = i_handleCodeLocation( location, type )
if ~ismember( strtok( type, "," ), [ "MATLABFile", "MATLABFileLine", "CSource" ] )

return ;
end 

lastColonIdx = find( location == ':', 1, "last" );
if isempty( lastColonIdx )

return ;
end 

location = location( lastColonIdx + 1:end  );
end 



function location_out = i_find_existing_location( location )
location_out = location;
if exist( location_out, 'file' )
return ;
end 





specialChar = @( string )string == ':' | string == '/';

while any( specialChar( location_out ) )
colon_or_slash = find( specialChar( location_out ), 1, 'last' );
location_out = location_out( 1:colon_or_slash - 1 );

if exist( location_out, 'file' )
return ;
end 
end 


location_out = location;

end 


function i_error( msg )
errordlg( msg, dependencies.message( 'Dialogs:OpenRefErrorTitle' ) );
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpm6Qpbm.p.
% Please follow local copyright laws when handling this file.

