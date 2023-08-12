function externalInputString = createInputString( inputmap, dataSource,  ...
USE_BASE_WORKSPACE, dataNames, dataClassNames )



externalInputString = '';



aCellOfNames = dataNames;
aCellOfDataTypes = dataClassNames;
isContainer = lIsContainerSignal( aCellOfNames );


if any( strcmp( aCellOfDataTypes, 'Simulink.SimulationData.Dataset' ) )

dataSetVarNames = { aCellOfNames{  ...
strcmp( aCellOfDataTypes, 'Simulink.SimulationData.Dataset' ) } };%#ok<CCAT1>


for kDS = 1:length( dataSetVarNames )


dataSetVar = getVar( dataSetVarNames{ kDS } );
elementNames = {  };


for kEl = dataSetVar.getLength: - 1:1
[ ~, elementNames{ kEl } ] = dataSetVar.getElement( kEl );
end 



cellOfMapNames = { inputmap( : ).DataSourceName };

idxEmpty = find( cellfun( @isempty, cellOfMapNames ) == 1 );


if ~isempty( idxEmpty )
for kEmpty = 1:length( idxEmpty )
cellOfMapNames{ idxEmpty( kEmpty ) } = '';
end 
end 
[ C, ~, ~ ] = intersect( elementNames, cellOfMapNames );

if ~isempty( C )
externalInputString =  ...
buildInputStrDataset( dataSetVarNames{ kDS },  ...
elementNames, cellOfMapNames, inputmap );
return ;
end 
end 

end 


emptyIdx = cellfun( 'isempty', { inputmap( : ).DataSourceName } );

if ~any( emptyIdx ) &&  ...
all( ~cellfun( 'isempty', strfind( { inputmap( : ).DataSourceName }, '(:' ) ) )


varFromMap = inputmap( 1 ).DataSourceName( 1:strfind( inputmap( 1 ).DataSourceName, '(:' ) - 1 );


externalInputString = [  ];



doesMatchVar = strcmp( aCellOfNames, varFromMap );



if any( doesMatchVar ) && isContainer( doesMatchVar )
externalInputString = aCellOfNames{ doesMatchVar };
end 

return ;
end 





if ~any( emptyIdx ) &&  ...
length( unique( { inputmap( : ).DataSourceName } ) ) == 1 &&  ...
any( ismember( aCellOfNames, inputmap( 1 ).DataSourceName ) ) &&  ...
iofile.Util.isValidTimeExpression( getVar( aCellOfNames{ ismember( aCellOfNames, inputmap( 1 ).DataSourceName ) } ) )

externalInputString = aCellOfNames{ ismember( aCellOfNames, inputmap( 1 ).DataSourceName ) };
return ;

end 


if ~any( emptyIdx ) &&  ...
length( unique( { inputmap( : ).DataSourceName } ) ) == 1 &&  ...
any( ismember( aCellOfNames, inputmap( 1 ).DataSourceName ) ) &&  ...
( Simulink.sdi.internal.Util.isStructureWithTime( getVar( aCellOfNames{ ismember( aCellOfNames, inputmap( 1 ).DataSourceName ) } ) ) ||  ...
Simulink.sdi.internal.Util.isStructureWithoutTime( getVar( aCellOfNames{ ismember( aCellOfNames, inputmap( 1 ).DataSourceName ) } ) ) )

externalInputString = aCellOfNames{ ismember( aCellOfNames, inputmap( 1 ).DataSourceName ) };
return ;

end 


for kMap = 1:length( inputmap )


if isempty( inputmap( kMap ).DataSourceName )

appendStr = '[]';


elseif any( ismember( aCellOfNames, inputmap( kMap ).DataSourceName ) ) &&  ...
iofile.Util.isValidSignal(  ...
getVar( aCellOfNames{ ( ismember( aCellOfNames, inputmap( kMap ).DataSourceName ) ) } ) ) &&  ...
~isContainer( ismember( aCellOfNames, inputmap( kMap ).DataSourceName ) )


appendStr = aCellOfNames{ ( ismember( aCellOfNames, inputmap( kMap ).DataSourceName ) ) };

else 


appendStr = '[]';
end 


externalInputString = [ externalInputString, appendStr ];%#ok<AGROW>


if kMap ~= length( inputmap )
externalInputString = [ externalInputString, ',' ];%#ok<AGROW>
end 
end 




function isContainer = lIsContainerSignal( varNames )

isContainer = zeros( 1, length( varNames ) );


for kName = 1:length( varNames )


varOut = getVar( varNames{ kName } );


isContainer( kName ) = isContainerSignal( { varOut } );

end 
end 


function varOut = getVar( varName )

if USE_BASE_WORKSPACE


varOut = evalin( 'base', varName );

else 

dataOut = load( dataSource, varName );

varOut = dataOut.( varName );

end 
end 


function inputStr = buildInputStrDataset( dsName, elementNames, inputmapNames, inputMap )

inputStr = [  ];


for kMapName = 1:length( inputmapNames )


if any( ismember( elementNames, inputmapNames{ kMapName } ) )

matchedValues = elementNames{ strcmp( elementNames, inputmapNames{ kMapName } ) };

if ~isempty( matchedValues )
inputStr = [ inputStr, [ dsName, '.getElement(''', elementNames{ strcmp( elementNames, inputmapNames{ kMapName } ) }, ''')' ] ];%#ok<AGROW>
else 
inputStr = [ inputStr, getExternalInputString( inputMap( kMapName ) ) ];%#ok<AGROW>
end 
else 
inputStr = [ inputStr, '[]' ];%#ok<AGROW>

end 


if kMapName ~= length( inputmapNames )
inputStr = [ inputStr, ',' ];%#ok<AGROW>
end 

end 


end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpD9ZIrH.p.
% Please follow local copyright laws when handling this file.

