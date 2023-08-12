function outBlockData = udpSoClibForwarding( inBlockData )

outBlockData.NewBlockPath = '';
outBlockData.NewInstanceData = [  ];

instanceData = inBlockData.InstanceData;


outBlockData.NewInstanceData = inBlockData.InstanceData;


[ ~, idx ] = intersect( { outBlockData.NewInstanceData.Name }, 'LocalIPPort' );
if idx

val = outBlockData.NewInstanceData( idx ).Value;
outBlockData.NewInstanceData( idx ) = [  ];
outBlockData.NewInstanceData( end  + 1 ).Name = 'LocalPort';
if isequal( val, '0' )
outBlockData.NewInstanceData( end  ).Value = '-1';
else 
outBlockData.NewInstanceData( end  ).Value = instanceData( idx ).Value;
end 
end 

[ ~, idx ] = intersect( { outBlockData.NewInstanceData.Name }, 'DataSize' );
if idx

val = outBlockData.NewInstanceData( idx ).Value;
outBlockData.NewInstanceData( idx ) = [  ];
outBlockData.NewInstanceData( end  + 1 ).Name = 'DataLength';
outBlockData.NewInstanceData( end  ).Value = val;
end 


if ~ismember( 'ByteOrder', { outBlockData.NewInstanceData.Name } )
outBlockData.NewInstanceData( end  + 1 ).Name = 'ByteOrder';
outBlockData.NewInstanceData( end  ).Value = 'LittleEndian';
end 


if ~ismember( 'OutputStatus', { outBlockData.NewInstanceData.Name } )
outBlockData.NewInstanceData( end  + 1 ).Name = 'OutputStatus';
outBlockData.NewInstanceData( end  ).Value = 'off';
end 


[ ~, idx ] = intersect( { outBlockData.NewInstanceData.Name }, 'RemoteIPAddress' );
if idx

val = outBlockData.NewInstanceData( idx ).Value;
outBlockData.NewInstanceData( idx ) = [  ];
outBlockData.NewInstanceData( end  + 1 ).Name = 'RemoteAddress';
outBlockData.NewInstanceData( end  ).Value = val;
end 

[ ~, idx ] = intersect( { outBlockData.NewInstanceData.Name }, 'RemoteIPPort' );
if idx

val = outBlockData.NewInstanceData( idx ).Value;

outBlockData.NewInstanceData( idx ) = [  ];
outBlockData.NewInstanceData( end  + 1 ).Name = 'RemotePort';
outBlockData.NewInstanceData( end  ).Value = val;
end 

[ ~, idx ] = intersect( { outBlockData.NewInstanceData.Name }, 'LocalIPAddress' );
if idx

val = outBlockData.NewInstanceData( idx ).Value;

outBlockData.NewInstanceData( idx ) = [  ];
outBlockData.NewInstanceData( end  + 1 ).Name = 'LocalAddress';
outBlockData.NewInstanceData( end  ).Value = val;
end 


[ ~, idx ] = intersect( { outBlockData.NewInstanceData.Name }, 'LocalIPPortSource' );
if idx
outBlockData.NewInstanceData( idx ) = [  ];
end 

end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpr2vaUg.p.
% Please follow local copyright laws when handling this file.

