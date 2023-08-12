function pmsl_buildlibrary( sys, iconSize, padding, maxCols )





















narginchk( 4, 4 );

sys = get_param( sys, 'Handle' );
sysName = getfullname( sys );

try 






annotation = find_system( sys, 'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices, 'FindAll', 'on', 'Type', 'annotation' );




libDb = PmSli.LibraryDatabase;
libs = libDb.getLibraryNames( sysName );



libs = setdiff( libs, 'mblibv1' );

numLibEntries = numel( libs );

if numLibEntries > 0




libEntries = libDb.getLibraryEntry( libs );




libDescriptors = get( libEntries, { 'Descriptor' } );
[ libDescriptors, idx ] = iSortDescriptors( sysName, libDescriptors );
libEntries = libEntries( idx );
libFullNames = strcat( sysName, '/', libDescriptors );




positions = repmat( [ 0, 0, iconSize ], size( libEntries, 1 ), size( libEntries, 2 ) );






leftOver = mod( numLibEntries, maxCols );
partialRow = leftOver > 0;
numRows = floor( numLibEntries / maxCols ) + partialRow;




stepSize = padding + iconSize;

for i = 1:numRows



rowStart = ( i - 1 ) * maxCols + 1;
if i == numRows && partialRow
rowIdx = rowStart:rowStart + leftOver - 1;
else 
rowIdx = rowStart:rowStart + maxCols - 1;
end 




numInRow = length( rowIdx );





hOffset = padding( 1 ) + stepSize( 1 ) * ( maxCols - numInRow ) / 2;




positions( rowIdx, 1 ) = hOffset + ( 0:stepSize( 1 ):stepSize( 1 ) * ( numInRow - 1 ) );
positions( rowIdx, 2 ) = min( padding ) + stepSize( 2 ) * ( i - 1 );
positions( rowIdx, 3 ) = positions( rowIdx, 1 ) + iconSize( 1 );
positions( rowIdx, 4 ) = positions( rowIdx, 2 ) + iconSize( 2 );
end 




hPositions = [ positions( :, 1 );positions( :, 3 ) ];
vPositions = [ positions( :, 2 );positions( :, 4 ) ];




for i = 1:numLibEntries
entry = libEntries( i );


block = add_block( 'built-in/SubSystem', libFullNames{ i },  ...
'Position', positions( i, : ),  ...
'OpenFcn', entry.Name,  ...
'FontName', 'Verdana',  ...
'FontSize', '11',  ...
'DropShadow', 'off' );

entry.Icon.setupIcon( block );

end 





location = get_param( sys, 'Location' );
location( 3 ) = location( 1 ) + padding( 1 ) + maxCols * stepSize( 1 );
location( 4 ) = location( 2 ) + ( max( vPositions ) ) + padding( 2 );




if ~isempty( annotation )
curNotePos = get( annotation, 'Position' );
newNotePos( 1 ) = ( min( hPositions ) + max( hPositions ) ) / 2 -  ...
( curNotePos( 3 ) - curNotePos( 1 ) ) / 2;
newNotePos( 2 ) = max( vPositions ) + padding( 2 );
newNotePos( 3 ) = newNotePos( 1 ) + curNotePos( 3 ) - curNotePos( 1 );
newNotePos( 4 ) = newNotePos( 2 ) + curNotePos( 4 ) - curNotePos( 2 );
set_param( annotation,  ...
'Position', newNotePos,  ...
'HorizontalAlignment', 'center',  ...
'VerticalAlignment', 'Top' );





location( 4 ) = location( 4 ) + 60;
end 

location( 3 ) = location( 3 ) + 50;
location( 4 ) = location( 4 ) + 210;




set_param( sys, 'Location', location );

end 

catch exception




lCleanupLoadFcn;
rethrow( exception );

end 




lCleanupLoadFcn;

function lCleanupLoadFcn

set_param( sys, 'PostLoadFcn', '' );

end 

end 

function [ newOrder, newIdx ] = iSortDescriptors( sysName, existingOrder )




if strcmp( 'simscape', sysName )


specifiedInitialLibraries = { sprintf( 'Foundation\nLibrary' ); ...
'Utilities' };





initialLibraries = intersect( specifiedInitialLibraries, existingOrder, 'stable' );

initialLibrariesIdx = zeros( size( initialLibraries ) );
for idx = 1:length( initialLibraries )
initialLibrariesIdx( idx ) = find( strcmp( initialLibraries{ idx }, existingOrder ) );
end 


[ remainingLibraries, remainingLibrariesIdx ] = setdiff( existingOrder, specifiedInitialLibraries );


newOrder = [ initialLibraries;remainingLibraries ];
newIdx = [ initialLibrariesIdx;remainingLibrariesIdx ];
else 
[ newOrder, newIdx ] = sort( existingOrder );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpXlreVa.p.
% Please follow local copyright laws when handling this file.

