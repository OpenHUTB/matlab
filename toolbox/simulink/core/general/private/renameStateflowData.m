

function renameStateflowData( blockHandle, oldDataName, newDataName )






oldDataName = strtrim( oldDataName );
newDataName = strtrim( newDataName );
chartID = sfprivate( 'block2chart', blockHandle );
if ( ~isempty( newDataName ) )
chartH = sf( 'IdToHandle', chartID );
allData = chartH.find( '-isa', 'Stateflow.Data', '-or', '-isa', 'Stateflow.Message', '-or', '-isa', 'Stateflow.Event' );
dataH = searchDataName( allData, oldDataName );


if length( dataH ) == 2 && sfprivate( 'isInPlaceData', dataH( 1 ) ) && sfprivate( 'isInPlaceData', dataH( 2 ) )
dataH( 1 ).Name = newDataName;
dataH( 2 ).Name = newDataName;
return ;
end 
assert( isscalar( dataH ) );
dataH.Name = newDataName;
end 
end 

function [ dataToRename ] = searchDataName( allData, oldDataName )
if ( ~isnan( str2double( oldDataName ) ) )
dataToRename = allData.find( 'Name', [ 'Inport', oldDataName ] );
if ( isempty( dataToRename ) )
dataToRename = allData.find( 'Name', [ 'Outport', oldDataName ] );
end 
else 
dataToRename = allData.find( 'Name', oldDataName );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpSPyNrE.p.
% Please follow local copyright laws when handling this file.

