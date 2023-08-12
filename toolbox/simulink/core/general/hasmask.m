function HasMask = hasmask( SysHandles )




















switch class( SysHandles ), 
case 'char', 
SysHandles = { SysHandles };

case 'double', 
case 'cell', 


otherwise , 
error( message( 'Simulink:Masking:SysWrongType' ) );

end 




HasMask = zeros( size( SysHandles ) );




bIndices = find( strcmp( get_param( SysHandles, 'Type' ), 'block' ) );
maskIndices = find( strcmp( get_param( SysHandles( bIndices ), 'Mask' ), 'off' ) );
bIndices( maskIndices ) = [  ];

HasMask( bIndices ) = 1;






maskIndices = find( ~strcmp( get_param( SysHandles( bIndices ), 'MaskVariables' ), '' ) );
HasMask( bIndices( maskIndices ) ) = 2;
bIndices( maskIndices ) = [  ];
maskIndices = find( ~strcmp( get_param( SysHandles( bIndices ), 'MaskInitialization' ), '' ) );
HasMask( bIndices( maskIndices ) ) = 2;



% Decoded using De-pcode utility v1.2 from file /tmp/tmpIvJ808.p.
% Please follow local copyright laws when handling this file.

