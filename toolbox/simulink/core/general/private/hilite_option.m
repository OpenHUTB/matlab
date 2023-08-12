function option = hilite_option( set )
persistent setOption;
if isempty( setOption )
setOption = 'none';
end 

option = setOption;

if nargin == 1
switch set
case 'none'
case 'fixedpt'
case 'integer'
case 'boolean'
case 'single'
case 'production'
otherwise 
me = MException( 'Simulink:utility:invalidHiliteOption', '%s', getString( message( 'Simulink:utility:invalidHiliteOption' ) ) );
throw( me );
end 
setOption = set;
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpDnyTri.p.
% Please follow local copyright laws when handling this file.

