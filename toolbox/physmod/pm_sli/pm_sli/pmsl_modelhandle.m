function hModel = pmsl_modelhandle( mdl )





clsName = class( mdl );
hModel = 0;
switch ( clsName )
case 'double'
hModel = mdl;
case { 'Simulink.BlockDiagram' }
hModel = mdl.Handle;
case 'char'
hModel = get_param( mdl, 'Handle' );
otherwise 
error( 'Unrecognized class' );
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppTdZl0.p.
% Please follow local copyright laws when handling this file.

