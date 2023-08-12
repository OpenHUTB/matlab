classdef mapUtils < handle

methods ( Static )
function addEntries( map, mapKeys, val )
arrayfun( @( mk )classdiagram.app.core.notifications.mapUtils.addEntry(  ...
map, mk, val ), mapKeys );
end 

function addEntry( map, key, val )
if ~map.isKey( key )
map( key ) = val;%#ok<NASGU>
else 
vals = map( key );
if isa( vals, 'cell' )
vals = [ vals{ : } ];
end 
vals = [ vals, val ];
if isa( vals, 'struct' ) && isfield( vals, 'actionUuid' )
[ ~, idx ] = unique( [ vals.actionUuid ] );
vals = vals( idx );
else 
vals = unique( vals );
end 
map( key ) = vals;%#ok<NASGU>
end 
end 



function merged = mergeMaps( m1, m2 )
if isempty( m2 )
merged = m1;
return ;
end 
if isempty( m1 )
merged = m2;
return ;
end 
keySet = keys( m1 );
keySetAdd = keys( m2 );
valueSetAdd = values( m2 );

idx = ismember( keySetAdd, keySet );
keyMerge = keySetAdd( idx );
valueMerge = valueSetAdd( idx );
if isempty( keyMerge )
merged = [ m1;m2 ];
return ;
end 

function mergeNonUniqueKeys( mapadd, mapremove, key, val )
classdiagram.app.core.notifications.mapUtils.addEntry( mapadd, key, val );


remove( mapremove, key );
end 
cellfun( @( key, val )mergeNonUniqueKeys( m1, m2, key, val ), keyMerge, valueMerge );
merged = [ m1;m2 ];
end 


function val = removeKey( map, mapKeys )
val = [  ];
for key = mapKeys
if map.isKey( key )
val = [ val, map( key ) ];
map.remove( key );
end 
end 
end 



function removeEntry( map, mapKeys, vals )
for key = mapKeys
if ~map.isKey( key )
continue ;
end 
entries = map( key );
idx = ~ismember( entries, vals );
if ~idx
classdiagram.app.core.notifications.mapUtils.removeKey( map, key );
else 
map( key ) = entries( idx );
end 
end 
end 

function items = getValsByMultipleKeys( map, multkeys, optional )
R36
map;
multkeys;
optional.not( 1, 1 )logical = false;
end 
allkeys = keys( map );
if optional.not
idx = ~ismember( allkeys, multkeys );
else 
idx = ismember( allkeys, multkeys );
end 
allvals = values( map );
items = allvals( idx );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpz0yD7l.p.
% Please follow local copyright laws when handling this file.

