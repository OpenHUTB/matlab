function cacheBlkStructInMap( obj, dataLoggingName, datasetType, portType, gotoname, inputBlkName, options )









R36
obj;
dataLoggingName;
datasetType;
portType;
gotoname;
inputBlkName;
options.PortIndex( 1, : ){  } = 1;
options.ComponentIndex( 1, 1 ){  } = 1;
end 

result = struct(  ...
'DatasetType', datasetType,  ...
'PortType', portType,  ...
'PortIndex', options.PortIndex,  ...
'ComponentIndex', options.ComponentIndex,  ...
'GotoBlockName', gotoname,  ...
'InputBlockName', inputBlkName,  ...
'sigBlkNameMap', containers.Map );

if strcmp( datasetType, 'inputs' )
result.sigBlkNameMap( dataLoggingName ) = inputBlkName;
end 

keysOldValue = [  ];






if obj.sigNameBlkInfoMap.isKey( dataLoggingName )

keysOldValue = obj.sigNameBlkInfoMap( dataLoggingName );
end 

newValue = [ keysOldValue, result ];

obj.sigNameBlkInfoMap( dataLoggingName ) = newValue;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpGGxMwi.p.
% Please follow local copyright laws when handling this file.

