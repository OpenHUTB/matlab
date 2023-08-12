function [ success, val ] = safeGetResolvedCSParam( bd, param )









narginchk( 2, 2 );
nargoutchk( 2, 2 );
val = [  ];
cs = getActiveConfigSet( bd );
isSourceResolved = true;
if isa( cs, 'Simulink.ConfigSetRef' )
isSourceResolved = strcmp( cs.SourceResolved, 'on' );
end 

if isSourceResolved
val = cs.get_param( param );
end 
success = isSourceResolved;
% Decoded using De-pcode utility v1.2 from file /tmp/tmpV52qcd.p.
% Please follow local copyright laws when handling this file.

