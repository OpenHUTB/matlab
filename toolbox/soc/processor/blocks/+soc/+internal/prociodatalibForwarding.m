function newData = prociodatalibForwarding( oldData )

switch oldData.ForwardingTableEntry.( '__slOldName__' )
case 'prociodatalib/IO Data Sink'
newData = IODataSinkForwarding( oldData );
case 'prociodatalib/IO Data Source'
newData = IODataSourceForwarding( oldData );
end 

end 

function newData = IODataSinkForwarding( oldData )
newData.NewBlockPath = '';
newData.NewInstanceData = [  ];


newData.NewInstanceData = oldData.InstanceData;

[ ~, idx1 ] = intersect( { newData.NewInstanceData.Name }, 'MessageType' );
if idx1
idx2 = numel( newData.NewInstanceData ) + 1;
newData.NewInstanceData( idx2 ).Name = 'DeviceType';
newData.NewInstanceData( idx2 ).Value = oldData.InstanceData( idx1 ).Value;
newData.NewInstanceData( idx1 ) = [  ];
end 
end 

function newData = IODataSourceForwarding( oldData )
newData.NewBlockPath = '';
newData.NewInstanceData = [  ];


newData.NewInstanceData = oldData.InstanceData;

[ ~, idx1 ] = intersect( { newData.NewInstanceData.Name }, 'ShowEventPort' );
if idx1
idx2 = numel( newData.NewInstanceData ) + 1;
newData.NewInstanceData( idx2 ).Name = 'EventDataPort';
if isequal( oldData.InstanceData( idx1 ).Value, 'on' )
newData.NewInstanceData( idx2 ).Value = 'Data and Event';
else 
newData.NewInstanceData( idx2 ).Value = 'Data';
end 
newData.NewInstanceData( idx1 ) = [  ];
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpUoGuql.p.
% Please follow local copyright laws when handling this file.

