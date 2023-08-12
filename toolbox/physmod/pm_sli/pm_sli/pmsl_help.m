function link = pmsl_help( block )









d = docroot;

if isempty( d )

directory = fileparts( which( mfilename ) );
link = fullfile( directory, 'pmsl_herr.html' );

else 

link = pmsl_defaultdocumentation;
if nargin > 0
link = lHandleSpecialBlockLink( block );
if isempty( link )

entry = pmsl_getblocklibraryentry( block );
if ~isempty( entry )
link = entry.getDocumentation( block );
end 

end 
end 

if ~isempty( link )
link = [ d, '/', link ];
end 

end 

end 

function link = lHandleSpecialBlockLink( block_hdl )






link = '';
slld = sllastdiagnostic;

map = struct( 'TwoWayConnection', 'twowayconnection.html',  ...
'PMIOPort', 'connectionport.html',  ...
'SimscapeComponentBlock', 'simscapecomponent.html',  ...
'SimscapeBus', 'simscapebus.html',  ...
'ConnectionLabel', 'connectionlabel.html',  ...
'VariantPMConnector', 'variantconnector.html' );

try 
blockType = get_param( block_hdl, 'BlockType' );
catch exception %#ok
blockType = '';
sllastdiagnostic( slld );

end 

if ~isempty( blockType ) && isfield( map, blockType )
[ dummy, referenceRoot ] = pmsl_defaultdocumentation;
link = [ referenceRoot, '/', map.( blockType ) ];
end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpHzcpem.p.
% Please follow local copyright laws when handling this file.

