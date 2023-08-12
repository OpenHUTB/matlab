function simclock( varargin )









lock_status = get_param( bdroot( gcbh ), 'lock' );
if ( strcmp( lock_status, 'off' ) )
if ( strcmp( get_param( gcbh, 'LinkStatus' ), 'none' ) )



set_param( gcbh, 'DeleteFcn', '',  ...
'PostSaveFcn', '',  ...
'CloseFcn', '' );
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpKybaOz.p.
% Please follow local copyright laws when handling this file.

