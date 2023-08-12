function HasMaskIcon = hasmaskicon( SysHandles )















switch class( SysHandles ), 
case 'char', 
SysHandles = { SysHandles };

case 'double', 
case 'cell', 


otherwise , 
error( message( 'Simulink:Masking:SysWrongType' ) );

end 




HasMaskIcon = zeros( size( SysHandles ) );





bIndices = find( strcmp( get_param( SysHandles, 'Type' ), 'block' ) );
maskIndices = find( strcmp( get_param( SysHandles( bIndices ), 'Mask' ), 'off' ) );
bIndices( maskIndices ) = [  ];





maskIndices = find( strcmp( get_param( SysHandles( bIndices ), 'MaskDisplay' ), '' ) );
bIndices( maskIndices ) = [  ];




HasMaskIcon( bIndices ) = 1;

HasMaskIcon = logical( HasMaskIcon );


% Decoded using De-pcode utility v1.2 from file /tmp/tmpMai6sH.p.
% Please follow local copyright laws when handling this file.

