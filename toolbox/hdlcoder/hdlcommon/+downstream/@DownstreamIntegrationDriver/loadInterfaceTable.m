function msg = loadInterfaceTable( obj, modelName )










savedLoadingState = obj.loadingFromModel;
obj.loadingFromModel = true;
msg = {  };

try 


if ~isempty( obj.hTurnkey.hTable )
obj.hTurnkey.hTable.hTableMap.initialTableMap;
end 

obj.hTurnkey.hTable.populateInterfaceTable( modelName );


msg = obj.hTurnkey.hTable.loadPortInterfacefromModel;
catch ME
obj.loadingFromModel = savedLoadingState;
rethrow( ME );
end 


obj.loadingFromModel = savedLoadingState;
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpwso18J.p.
% Please follow local copyright laws when handling this file.

