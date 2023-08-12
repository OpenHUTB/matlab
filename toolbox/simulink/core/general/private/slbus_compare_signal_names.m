function [ status, msg, indicesIO ] = slbus_compare_signal_names(  ...
busObjName, busStruct, indicesIO, scope )


























status = true;
msg = '';

if nargin < 3
indicesIO = [  ];
end 

if nargin < 4
scope = Simulink.data.DataAccessor.createWithNoContext(  );
end 

busObj = getBusObjectByScope( busObjName, true, scope );
numEl1 = length( busObj.Elements );
numEl2 = length( busStruct.signals );

if numEl1 ~= numEl2
status = false;
[ msg, messageId ] =  ...
DAStudio.message( 'Simulink:utility:slUtilityBusCompareSigNamesNumElementsMismatch',  ...
busObjName );%#ok
return ;
end 

numElem = numEl1;
for eIdx = 1:numElem
name1 = busObj.Elements( eIdx ).Name;
name2 = busStruct.signals( eIdx ).name;

if ~strcmp( name1, name2 )
status = false;
[ msg, messageId ] =  ...
DAStudio.message( 'Simulink:utility:slUtilityBusCompareSigNamesMismatch',  ...
getfullname( busStruct.src ), busObjName, eIdx, name1, name2 );%#ok
indicesIO = [ indicesIO, eIdx ];%#ok
return ;
end 

dtype1 = busObj.Elements( eIdx ).DataType;
tempObj = getBusObjectByScope( dtype1, false, scope );
dtype1IsABus = ~isempty( tempObj );

if dtype1IsABus
newIndices = [ indicesIO, eIdx ];
[ status, msg, tmpIndices ] = slbus_compare_signal_names( dtype1,  ...
busStruct.signals( eIdx ),  ...
newIndices, scope );
if ~status
indicesIO = tmpIndices;
return ;
end 
end 
end 


function busObj = getBusObjectByScope( busObjName, okToError, scope )



if isa( scope, 'Simulink.data.DataAccessor' )
busObj = slbus_get_object_from_name_withDataAccessor( busObjName, okToError, scope );
else 
busObj = slbus_get_object_from_name( busObjName, okToError, scope );
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpdDpL59.p.
% Please follow local copyright laws when handling this file.

