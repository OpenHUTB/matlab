function varargout = subsystemConfig_impl( pth, action, value )





R36
pth{ validatePathArg }
action( 1, 1 )string
value( 1, 1 )string = ""
end 


h = get_param( pth, 'Handle' );
pth = string( pth );


switch get_param( h, 'Type' )
case "block"
fcn = processBlock( h, pth );
case "block_diagram"
if get_param( h, 'BlockDiagramType' ) ~= "subsystem"
throw( mkerr( 'NotSupportedSubsystem', pth ) );
end 

fcn = @( varargin )subsysRef( h, varargin{ : } );
otherwise 
throw( mkerr( 'NotSupportedSubsystem', pth ) );
end 


switch action
case 'get'
narginchk( 2, 2 );
nargoutchk( 0, 1 );
varargout{ 1 } = fcn( action );
case 'set'
narginchk( 3, 3 );
nargoutchk( 0, 0 );
if ~any( strcmp( value, { 'auto', 'off' } ) )
throw( mkerr( 'InvalidSetting', value ) );
end 
fcn( action, value );
otherwise 
throw( mkerr( 'InvalidAction', action ) );
end 

end 

function fcn = processBlock( h, pth )
if get_param( h, 'BlockType' ) ~= "SubSystem"
throw( mkerr( 'NotSupportedSubsystem', pth ) );
end 


rSys = get_param( h, 'ReferencedSubsystem' );
if strlength( rSys ) ~= 0
fcn = @( varargin )subsysRef( rSys, varargin{ : } );
return ;
end 




if get_param( bdroot( h ), "BlockDiagramType" ) == "library"
fcn = @( varargin )linkedLib( h, varargin{ : } );
return 
end 

rBlk = get_param( h, 'ReferenceBlock' );
if strlength( rBlk ) ~= 0
load_system( extractBefore( rBlk, '/' ) );
fcn = processBlock( get_param( rBlk, 'handle' ), pth );
return ;
end 

throw( mkerr( 'NotSupportedSubsystem', pth ) );
end 


function out = subsysRef( h, action, value )
h = get_param( h, 'Handle' );
switch action
case 'get'
out = getParamValue( h, 'SscReferenceScalableBuild' );
case 'set'
pluginId = 'SscScalablePlugin';
mgr = Simulink.PluginMgr;
mgr.attach( h, pluginId );
set_param( h, 'SscReferenceScalableBuild', value );
end 

end 

function out = linkedLib( h, action, value )
switch action
case 'get'
out = getParamValue( h, 'SscLibraryScalableBuild' );
case 'set'
pluginId = 'SscScalablePlugin';
bdrooth = get_param( bdroot( h ), 'Handle' );
mgr = Simulink.PluginMgr;
mgr.attach( bdrooth, pluginId );
mgr.addParam( pluginId, h );
set_param( bdrooth, 'Lock', 'off' );
set_param( h, 'SscLibraryScalableBuild', value );
end 

end 

function v = getParamValue( h, param )


try 
v = get_param( h, param );
catch 


v = 'auto';
end 
end 

function validatePathArg( arg )
if ischar( arg ) ||  ...
( ( isstring( arg ) || isa( arg, 'double' ) ) && numel( arg ) == 1 )
return 
end 
throw( mkerr( 'InvalidSubsystemPathArg' ) );
end 

function exe = mkerr( id, varargin )
prefix = 'physmod:simscape:simscape:scalable:';
exe = MException( message( [ prefix, id ], varargin{ : } ) );
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmppx75EB.p.
% Please follow local copyright laws when handling this file.

