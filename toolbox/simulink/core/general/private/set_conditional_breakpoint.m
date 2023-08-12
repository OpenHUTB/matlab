function out = set_conditional_breakpoint( path, mw_bp_operation )
if ~exist( 'mw_bp_operation', 'var' )
mw_bp_operation = 6;
end 
ph = get_param( path, 'PortHandles' );
set_param( ph.Outport, 'AddConditionalPause', struct( 'relation', mw_bp_operation, 'value', 0 ) );
out = 'OK';
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpMCAh3v.p.
% Please follow local copyright laws when handling this file.

