function s_row = simrfV2_sparams3d_to_1d( sparams )












[ nport, ~, nfreqs ] = size( sparams );
validateattributes( sparams, { 'numeric' }, { 'nonempty', 'size',  ...
[ nport, nport, nfreqs ] }, mfilename, 'S-parameter data' )


s_dc = sparams( :, :, 1 );
validateattributes( abs( imag( s_dc ) ), { 'numeric' }, { '<=', 1e-10 },  ...
mfilename, 'S-parameters must be real for zero frequency' )
sparams( :, :, 1 ) = real( s_dc );

x = permute( sparams, [ 2, 1, 3 ] );
x = x( : ).';

s_row = [ real( x ), imag( x ) ];
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpbPcA1i.p.
% Please follow local copyright laws when handling this file.

