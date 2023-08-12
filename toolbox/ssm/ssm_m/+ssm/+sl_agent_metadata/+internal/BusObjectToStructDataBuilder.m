classdef BusObjectToStructDataBuilder < handle






properties ( Access = public )
OutputFileName
end 

properties ( Access = public, Hidden )
BusName( 1, : )char
StructuredData
BusDefinition
end 

methods 
function obj = BusObjectToStructDataBuilder( BusName, options )
R36
BusName
options.outputFileName = strcat( baseModelName( BusName ), '.seaction' )
end 

obj.BusName = baseModelName( BusName );
obj.OutputFileName = options.outputFileName;
obj.BusDefinition = containers.Map;
end 

function buildData( obj )
busObj = evalin( 'base', obj.BusName );
obj.StructuredData = obj.genStructDataFromBusDeepCopy( busObj );


obj.BusDefinition( obj.BusName ) = ssm.sl_agent_metadata.internal.utils.genStructDataFromBus( busObj );
end 

function writeToFile( obj, protoObj )
[ pfolder, ~, ~ ] = fileparts( obj.OutputFileName );


tempFileName = [ obj.OutputFileName, '.temp' ];
[ fid, ~ ] = fopen( tempFileName, 'w' );
if fid ==  - 1
errMsg = message( 'ssm:actorMetadata:FailedToCreateBehaviorOutputFile', pwd );
error( errMsg );
else 
fclose( fid );
delete( tempFileName );
end 


if ( ~isempty( obj.OutputFileName ) ) && ( exist( pfolder, 'dir' ) == 7 || isempty( pfolder ) )
protoObj.serializeToFile( obj.OutputFileName )
else 
errMsg = message( 'ssm:actorMetadata:InvalidBehaviorOutputFile', obj.OutputFileName );
error( errMsg );
end 
end 
end 

methods ( Access = private )
function structBus = genStructDataFromBusDeepCopy( obj, objBus )
structBus = [  ];
if isempty( objBus )
return ;
end 

structBus = struct(  );


for idx = length( objBus.Elements ): - 1:1

currentElem.Name = objBus.Elements( idx ).Name;
currentElem.Value = 0;
ElementType = objBus.Elements( idx ).DataType;



if startsWith( ElementType, 'Bus:' )

strBusSplit = strsplit( ElementType, 'Bus:' );
strBusSplit( ~cellfun( 'isempty', strBusSplit ) );
subBusName = strtrim( [ strBusSplit{ : } ] );


subBusObj = evalin( 'base', subBusName );
subBusStructData = obj.genStructDataFromBusDeepCopy( subBusObj );
currentElem.Value = subBusStructData;


obj.BusDefinition( subBusName ) = ssm.sl_agent_metadata.internal.utils.genStructDataFromBus( subBusObj );
end 

structBus.( currentElem.Name ) = currentElem.Value;
end 
end 
end 
end 

function ModelName = baseModelName( ModelName )
[ ~, ModelName, ~ ] = fileparts( ModelName );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpJXfKH5.p.
% Please follow local copyright laws when handling this file.

