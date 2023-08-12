function HasMaskDlg = hasmaskdlg( SysHandles )
















switch class( SysHandles ), 
case 'char', 
SysHandles = { SysHandles };

case 'double', 
case 'cell', 


otherwise , 
error( message( 'Simulink:Masking:SysWrongType' ) );

end 




HasMaskDlg = zeros( size( SysHandles ) );





bIndices = find( strcmp( get_param( SysHandles, 'Type' ), 'block' ) );
maskIndices = find( strcmp( get_param( SysHandles( bIndices ), 'Mask' ), 'off' ) );
bIndices( maskIndices ) = [  ];





maskIndices = find( ~strcmp( get_param( SysHandles( bIndices ), 'MaskDescription' ), '' ) );
HasMaskDlg( bIndices( maskIndices ) ) = 1;
bIndices( maskIndices ) = [  ];
maskIndices = find( ~strcmp( get_param( SysHandles( bIndices ), 'MaskHelp' ), '' ) );
HasMaskDlg( bIndices( maskIndices ) ) = 1;
bIndices( maskIndices ) = [  ];
maskIndices = find( ~strcmp( get_param( SysHandles( bIndices ), 'MaskPromptString' ), '' ) );
HasMaskDlg( bIndices( maskIndices ) ) = 1;
bIndices( maskIndices ) = [  ];

HasMaskDlg = logical( HasMaskDlg );



% Decoded using De-pcode utility v1.2 from file /tmp/tmp5w9Ky4.p.
% Please follow local copyright laws when handling this file.

