function newData = prociolibForwarding( oldData )

switch oldData.ForwardingTableEntry.( '__slOldName__' )
case 'prociolib/Register Write'
newData = RegisterWriteForwarding( oldData );
case 'prociolib/Stream Write'
newData = StreamWriteForwarding( oldData );
case 'prociolib/Stream Read'
newData = StreamReadForwarding( oldData );
case 'prociolib/UDP Write'
newData = UDPWriteForwarding( oldData );
case 'prociolib/TCP Write'
newData = TCPWriteForwarding( oldData );
end 

end 

function newData = RegisterWriteForwarding( oldData )

newData.NewBlockPath = '';
newData.NewInstanceData = [  ];


newData.NewInstanceData = oldData.InstanceData;

[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'InDataTypeStr' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 
[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'InputVectorSize' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 

end 

function newData = StreamWriteForwarding( oldData )

newData.NewBlockPath = '';
newData.NewInstanceData = [  ];


newData.NewInstanceData = oldData.InstanceData;

[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'InDataTypeStr' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 
[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'SamplesPerFrame' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 
[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'Dummy' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 

end 
function newData = StreamReadForwarding( oldData )

newData.NewBlockPath = '';
newData.NewInstanceData = [  ];


newData.NewInstanceData = oldData.InstanceData;

[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'Dummy' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 

end 

function newData = UDPWriteForwarding( oldData )

newData.NewBlockPath = '';
newData.NewInstanceData = [  ];


newData.NewInstanceData = oldData.InstanceData;

[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'DataType' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 
[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'DataLength' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 

end 

function newData = TCPWriteForwarding( oldData )

newData.NewBlockPath = '';
newData.NewInstanceData = [  ];


newData.NewInstanceData = oldData.InstanceData;

[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'DataType' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 
[ ~, idx ] = intersect( { newData.NewInstanceData.Name }, 'DataLength' );
if idx
newData.NewInstanceData( idx ) = [  ];
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpZbkihT.p.
% Please follow local copyright laws when handling this file.

