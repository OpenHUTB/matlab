function varargout = blockConfig_impl( path, action, value )




R36
path{ validatePathArg }
action( 1, 1 )string
value( 1, 1 )string = ""
end 


h = get_param( path, 'Handle' );
path = getfullname( h );


if ~strcmp( get_param( h, 'Type' ), 'block' ) ||  ...
~any( strcmp( get_param( h, 'BlockType' ), { 'SimscapeBlock', 'SimscapeComponentBlock' } ) )
pm_error( 'physmod:simscape:simscape:scalable:NotSimscapeBlock', path );
end 


switch action
case 'get'
narginchk( 2, 2 );
nargoutchk( 0, 1 );
varargout{ 1 } = get_param( h, 'SscBlockScalableBuild' );
case 'set'
narginchk( 3, 3 );
nargoutchk( 0, 0 );
if ~any( strcmp( value, { 'on', 'off' } ) )
pm_error( 'physmod:simscape:simscape:scalable:InvalidSetting', value );
end 
set_param( h, 'SscBlockScalableBuild', value );
otherwise 
pm_error( 'physmod:simscape:simscape:scalable:InvalidAction', action );
end 

end 

function validatePathArg( arg )
if ischar( arg ) ||  ...
( ( isstring( arg ) || isa( arg, 'double' ) ) && numel( arg ) == 1 )
return 
end 
pm_error( 'physmod:simscape:simscape:scalable:InvalidBlockPathArg' );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpuqt7Z5.p.
% Please follow local copyright laws when handling this file.

