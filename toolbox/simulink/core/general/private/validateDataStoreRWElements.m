
function [ regionDesc, entries, leafBusObjectNames ] = validateDataStoreRWElements(  ...
blk, entries, editTimeCheck, editTimeErrPrefix )

memLayout = get_param( blk, 'DSMemoryLayout' );
defaultExpr = get_param( blk, 'DataStoreName' );

if isempty( entries )
entries = clean( str2cellarr( get_param( blk, 'DataStoreElements' ) ), editTimeErrPrefix );
if isempty( entries )
entries = { defaultExpr };
end 
end 
entries = clean( entries, editTimeErrPrefix );

mObj = elementExpressionProcessor( blk, memLayout, entries, defaultExpr, editTimeCheck, editTimeErrPrefix );
[ regionDesc, entries, leafBusObjectNames ] = validateExpressions( mObj );


function modArray = clean( inArray, repstr )

if isempty( inArray )
modArray = inArray;
else 
modArray = strrep( inArray, repstr, '' );
end 

function sep = getSeparator(  )

sep = '#';



function cellarr = str2cellarr( str )
cellarr = {  };
[ name, str ] = strtok( str, getSeparator(  ) );
if ~isempty( name )
cellarr{ end  + 1 } = name;
end 
if ~isempty( str )
cellarr = [ cellarr, str2cellarr( str ) ];
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpm_5YDs.p.
% Please follow local copyright laws when handling this file.

