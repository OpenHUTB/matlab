function slmaskprmdispcntrl( block )








maskVariables = get_param( block, 'MaskVariables' );
[ ~, ~, t ] = regexp( maskVariables, 'prm_to_disp=@(\d)' );
startIndex = str2double( maskVariables( t{ 1 }( 1 ):t{ 1 }( 2 ) ) );

mask_visibilities = get_param( block, 'MaskVisibilities' );
prm_to_disp = [ 2, length( mask_visibilities ) ];
mask_visibilities( startIndex + 1:end  ) = { 'off' };
mask_visibilities( prm_to_disp( 1 ):prm_to_disp( 2 ) ) = { 'on' };
set_param( block, 'MaskVisibilities', mask_visibilities );




% Decoded using De-pcode utility v1.2 from file /tmp/tmpMGYQ9P.p.
% Please follow local copyright laws when handling this file.

