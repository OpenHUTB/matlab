function varargout = switchConfigSet( action, mdl, varargin )





varargout = {  };
preserveDirty = Simulink.PreserveDirtyFlag( mdl, 'blockDiagram' );

switch action
case 'ReplaceConfigSetRef'

assert( nargout == 1 );
assert( nargin == 3 );
origCS = varargin{ 1 };
newCS = origCS;

assert( origCS == getActiveConfigSet( mdl ) );

if isa( origCS, 'Simulink.ConfigSetRef' )





if strcmp( origCS.SourceResolved, 'off' )
DAStudio.error( 'Simulink:utility:ConfigSetRefSourceObjectUnresolved',  ...
origCS.WSVarName, origCS.Name );
elseif strcmp( origCS.UpToDate, 'off' )

origCS.refresh;
DAStudio.error( 'Simulink:utility:ConfigSetRefSourceObjectOutOfDate',  ...
origCS.Name, origCS.WSVarName );
end 

set_param( mdl, 'OriginalConfigSetName', origCS.Name );
set_param( mdl, 'OriginalConfigSetRefVarName', origCS.SourceName );
newCS = origCS.getResolvedConfigSetCopy;
attachConfigSet( mdl, newCS, true );
newCS.activate;
origCS.lock;
if strcmp( get_param( newCS, 'IsERTTarget' ), 'on' ) &&  ...
strcmp( get_param( newCS, 'AutosarCompliant' ), 'off' ) &&  ...
coder.internal.CoderDataStaticAPI.hasSharedDictionaryWithCoderDictionary( mdl )



Simulink.CodeMapping.migrateFromShared( mdl );
end 
end 
varargout{ 1 } = newCS;

case 'RestoreOrigConfigSet'

assert( nargout == 0 );
assert( nargin == 3 || nargin == 5 );
origCS = varargin{ 1 };
if nargin == 5
newCS = varargin{ 2 };
isProtected = varargin{ 3 };
assert( isProtected || newCS == getActiveConfigSet( mdl ) )
else 

newCS = getActiveConfigSet( mdl );
end 

if ( origCS ~= newCS )
origCS.unlock;
set_param( mdl, 'OriginalConfigSetName', '' );
set_param( mdl, 'OriginalConfigSetRefVarName', '' );
origCS.activate;
detachConfigSet( mdl, newCS.Name );
end 



set_param( mdl, 'TargetFcnLibHandle', [  ] );

end 

delete( preserveDirty );



% Decoded using De-pcode utility v1.2 from file /tmp/tmp0DJbIF.p.
% Please follow local copyright laws when handling this file.

