classdef TreeReader < handle




methods ( Access = public, Static )

function roots = getRootEntries( mcosView )
roots = mcosView.getForest.roots.toArray;
end 

function name = getName( optionalNode )
if isempty( optionalNode.node )
name = '';
else 
name = optionalNode.node.name;
end 
end 

function icon = getIcon( optionalNode )
if isempty( optionalNode.node )
icon = '';
else 
icon = optionalNode.node.iconUri;
end 
end 

function name = getNameOnSide( entry, side )
sideIndex = uint8( side );
optionalNode = entry.nodes( sideIndex );

import comparisons.internal.tree.TreeReader.getName
name = getName( optionalNode );
end 

function path = getPathOnSide( entry, side, formatPathAsString, delimiter )
R36
entry comparisons.viewmodel.tree.mfzero.Entry
side
formatPathAsString logical = true
delimiter char = '/'
end 

import comparisons.internal.tree.TreeReader.getNameOnSide
import comparisons.internal.tree.TreeReader.getPathOnSide

currentEntry = entry;
currentName = getNameOnSide( entry, side );
path = { currentName };

while ~isempty( currentName ) && ~isempty( currentEntry.parent )
currentEntry = currentEntry.parent;
currentName = getNameOnSide( currentEntry, side );
path = [ { currentName }, { delimiter }, path ];%#ok<AGROW>
end 

if formatPathAsString
path = [ path{ : } ];
end 
end 

function bool = isChanged( entry )

if ~strcmp( entry.match.editTypes( 1 ), "Same" )

bool = true;
elseif isempty( entry.nodes( 1 ).node ) || isempty( entry.nodes( 2 ).node )

bool = true;
else 
bool = false;
submetrics = entry.match.submetrics;
for f = fields( submetrics )'
if submetrics.( f{ 1 } )


bool = true;
return 
end 
end 
end 

end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpigoemq.p.
% Please follow local copyright laws when handling this file.

