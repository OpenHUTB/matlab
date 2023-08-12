function validateCompatibleBoard( sys )
cs = getActiveConfigSet( sys );
board = get_param( cs, 'HardwareBoard' );
if ~( codertarget.targethardware.isESBCompatible( cs, 2 ) ||  ...
codertarget.targethardware.isESBCompatible( cs, 1 ) ) ...
 || strcmpi( board, 'Custom Hardware Board' )
error( message( 'soc:scheduler:UnsupportedBoard', sys, board ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpMAeVzf.p.
% Please follow local copyright laws when handling this file.

