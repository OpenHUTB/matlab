function output = sldrop( varargin )




















if ( nargin > 3 )
dropFcn = varargin{ 1 };
model = varargin{ 2 };
dragVector = varargin{ 3 };
acceptSF = varargin{ 4 };
if ( nargin > 4 )
optionalArg = varargin{ 5 };
end 

if ( isempty( dragVector ) )
output = false;
return ;
end 


[ slVec, sfVec, other ] = split_stateflow_simulink_and_other_l( dragVector );

if ( ~isempty( other ) )
output = false;
switch ( dropFcn )
case { 'canAcceptDrop',  ...
'acceptDrop',  ...
'canAcceptMouseDrop',  ...
'doDropOperation' }

case 'getDropOperations'
output = {  };
end 
return ;
end 
output = true;

if ( ~isempty( slVec ) )
switch ( dropFcn )
case 'canAcceptDrop'
output = can_accept_drop_l( model, slVec );
case 'acceptDrop'
output = accept_drop_l( model, slVec );
case 'canAcceptMouseDrop'
output = can_accept_mouse_drop_l( model, slVec, optionalArg );
case 'doDropOperation'
output = do_drop_operation_l( model, slVec, optionalArg );
case 'getDropOperations'
output = get_drop_operations_l( model, slVec, optionalArg );
end 
end 

if ( ~isempty( sfVec ) )
machine = find( model, '-isa', 'Stateflow.Machine' );
if ( isempty( machine ) || ~acceptSF )
output = false;
else 
switch ( dropFcn )
case 'canAcceptDrop'
output = output & canAcceptDrop( machine, sfVec );
case 'acceptDrop'
output = output & acceptDrop( machine, sfVec );
case 'canAcceptMouseDrop'
try 
output = output & canAcceptMouseDrop( machine, sfVec, optionalArg );
catch 
output = output & canAcceptDrop( machine, sfVec );
end 
case 'doDropOperation'
try 
output = output & doDropOperation( machine, sfVec, optionalArg );
catch 
output = output & acceptDrop( machine, sfVec );
end 

case 'getDropOperations'
try 
sfOutput = getDropOperations( machine, sfVec, optionalArg );
if ( ~isempty( slVec ) )
output = intersect( output, sfOutput );
else 
output = sfOutput;
end 
catch 
if ( canAcceptDrop( machine, sfVec ) )
if ( ~isempty( slVec ) )
output = intersect( output, { 'Move' } );
else 
output = { 'Move' };
end 
end 
end 

end 
end 
end 

else 
output = false;
end 



function [ slVec, sfVec, otherVec ] = split_stateflow_simulink_and_other_l( vec )
slVec = [  ];
sfVec = [  ];
otherVec = [  ];

for i = 1:length( vec )
item = vec( i );


if isa( item, 'Simulink.Object' )
slVec = [ slVec, item ];%#ok
elseif isa( item, 'Stateflow.internal.DDObject' )
sfVec = [ sfVec, item ];%#ok
else 
pkgName = '';
if isa( item, "handle.handle" )

classH = classhandle( item );
if ~isempty( classH )
pkgName = classH.Package.Name;
end 
else 

classH = metaclass( item );
if ~isempty( classH )
pkgName = classH.ContainingPackage.Name;
dotIdx = findstr( pkgName, '.' );
if ~isempty( dotIdx )
pkgName = pkgName( 1:dotIdx( 1 ) - 1 );
end 
end 
end 

if ( isequal( pkgName, 'Simulink' ) )
slVec = [ slVec, item ];%#ok
elseif ( isequal( pkgName, 'Stateflow' ) )
sfVec = [ sfVec, item ];%#ok
elseif ( isa( item, 'DAStudio.WSOAdapter' ) &&  ...
isa( item.getForwardedObject, 'Simulink.ConfigSetRoot' ) )
slVec = [ slVec, item ];%#ok
else 
otherVec = [ otherVec, item ];%#ok
end 
end 
end 



function canAccept = can_accept_drop_l( model, slVector )
canAccept = sl_is_movable_l( model, slVector );



function success = accept_drop_l( model, dragVector )
success = false;
if ( can_accept_drop_l( model, dragVector ) )
success = sl_copy_or_move_l( model, dragVector, true );
end 



function canAccept = can_accept_mouse_drop_l( model, slVector, mouseState )
wantsToMove = true;
if ( isfield( mouseState, 'Right' ) )
if ( mouseState.Right )
wantsToMove = false;
end 
end 

if ( wantsToMove )
canAccept = sl_is_movable_l( model, slVector );
else 
canAccept = sl_is_copyable_l( model, slVector );
end 



function success = do_drop_operation_l( model, slVector, operation )
if ( isequal( operation, 'Copy' ) )
success = sl_copy_or_move_l( model, slVector, false );
else 
success = sl_copy_or_move_l( model, slVector, true );
end 



function operations = get_drop_operations_l( model, slVector, mouseState )
operations = {  };
if ( isfield( mouseState, 'Right' ) )
if ( mouseState.Right )
if ( sl_is_copyable_l( model, slVector ) )
operations = { 'Copy' };
end 
end 
end 

if ( sl_is_movable_l( model, slVector ) )
operations = [ operations;{ 'Move' } ];
end 



function success = sl_copy_or_move_l( model, vec, moveNotCopy )
success = true;
for i = 1:length( vec )
item = vec( i );
cs = sl_get_actual_object_l( item );
assert( isa( cs, 'Simulink.ConfigSetRoot' ) );
try 
attachConfigSetCopy( model, cs, true );
if ( moveNotCopy )
csModel = cs.up;
if isempty( csModel )

item.remove(  );
else 

csModel.detachConfigSet( cs.Name );
end 
end 
catch 
success = false;
return ;
end 
end 



function movable = sl_is_movable_l( model, vec )


movable = false;
if ( sl_is_copyable_l( model, vec ) )
for i = 1:length( vec )
item = vec( i );
cs = sl_get_actual_object_l( item );
assert( isa( cs, 'Simulink.ConfigSetRoot' ) );
try 
currentModel = cs.getParent;
if isa( currentModel, "DAStudio.DAObjectProxy" )
currentModel = currentModel.getMCOSObjectReference;
end 
if isempty( currentModel )

else 


if ( isequal( currentModel, model ) || cs.isActive )
return ;
end 
end 
catch 
return ;
end 
end 
movable = true;
end 



function copyable = sl_is_copyable_l( model, vec )


if ( isequal( get( model, 'lock' ), 'on' ) ) || model.isLibrary
copyable = false;
return ;
end 

copyable = true;
for i = 1:length( vec )
item = vec( i );
item = sl_get_actual_object_l( item );
if ( ~( isa( item, 'Simulink.ConfigSetRoot' ) ) )
copyable = false;
return ;
end 
end 



function cs = sl_get_actual_object_l( item )
if ( isa( item, 'DAStudio.WSOAdapter' ) )
assert( isa( item.getParent, 'DAStudio.WorkspaceNode' ) );
cs = item.getForwardedObject;
elseif ( isa( item, 'Simulink.DDEAdapter' ) )
cs = item.getForwardedObject;
else 
cs = item;
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpg_MxNh.p.
% Please follow local copyright laws when handling this file.

