classdef ( Sealed )StateTracker < handle





properties ( Dependent, SetAccess = immutable )
State
HasNext
HasPrevious
end 

properties ( Transient )
ManagedStatusObject coderapp.internal.undo.UndoRedoStatus
end 

properties ( SetAccess = private, Transient )
IsRestoring( 1, 1 )logical = false
end 

properties ( Dependent, GetAccess = protected, SetAccess = private )
NumFrames
end 

properties ( SetAccess = immutable )
MaxFrames{ mustBeGreaterThan( MaxFrames, 0 ) }
end 

properties ( Dependent, Access = private )
CurrentFrame
end 

properties ( Access = private, Transient )
StateOwners = {  }
SubStates = struct( 'owner', {  }, 'id', {  }, 'count', {  }, 'states', {  } )
FrameMembership = false( 0, 1 )
Frames = { zeros( 0, 3 ) }
Pointer = 1
Locked = false
end 

events ( NotifyAccess = private )
StateChanged
end 

methods 
function this = StateTracker( varargin )
ip = inputParser(  );
ip.addParameter( 'MaxFrames', 1000, @( v )validateattributes( v,  ...
{ 'numeric' }, { 'scalar', 'finite', 'positive' } ) );
ip.parse( varargin{ : } );

this.MaxFrames = ip.Results.MaxFrames;
end 

function addStateOwner( this, stateOwner )
R36
this( 1, 1 )
stateOwner( 1, 1 )coderapp.internal.undo.StateOwner
end 
if ~isempty( stateOwner.BoundStateTracker )
if isequal( stateOwner.BoundStateTracker, this )
return 
else 
error( 'StateOwner already bound to a StateTracker' );
end 
end 
if any( cellfun( @( s )isequal( s, stateOwner ), this.StateOwners ) )
return 
end 

this.StateOwners{ end  + 1 } = stateOwner;
ownerIdx = numel( this.StateOwners );
stateOwner.BoundStateTracker = this;
this.FrameMembership( end  + 1, : ) = false;
this.FrameMembership( end , this.Pointer ) = true;


cleanup = this.lock(  );%#ok<NASGU>
initialState = stateOwner.getTrackableState( true );
clearvars cleanup;
if ~isempty( initialState )
trackedIds = vertcat( initialState.trackableId );
subIndices = this.getIndices( [ repmat( ownerIdx, numel( trackedIds ), 1 ), trackedIds ], true );
this.Frames{ this.Pointer }( end  + 1:end  + numel( subIndices ), : ) =  ...
[ repmat( ownerIdx, numel( subIndices ), 1 ), trackedIds, ones( size( subIndices ) ) ];
for i = 1:numel( subIndices )
this.SubStates( subIndices( i ) ).count = 1;
this.SubStates( subIndices( i ) ).states{ 1 } = initialState( i ).state;
end 
end 
end 

function removeStateOwner( this, stateOwner )
R36
this( 1, 1 )
stateOwner( 1, 1 )coderapp.internal.undo.StateOwner
end 
this.doRemoveStateOwner( stateOwner, true );
end 

function snapshot( this, invalidatePrior )
R36
this( 1, 1 )
invalidatePrior( 1, 1 )logical = false
end 
this.assertUnlocked(  );

allIdPairs = cell( 1, numel( this.StateOwners ) );
allStates = allIdPairs;
allUnchanged = allIdPairs;

for i = 1:numel( this.StateOwners )
[ trackables, unchanged ] = this.StateOwners{ i }.getTrackableState( false );
if ~isempty( trackables )
ownerIdx = repmat( i, numel( trackables ), 1 );
allIdPairs{ i } = [ ownerIdx, vertcat( trackables.trackableId ) ];
allStates{ i } = { trackables.state };
end 
if ~isempty( unchanged )
allUnchanged{ i } = [ repmat( i, numel( unchanged ), 1 ), reshape( unchanged, numel( unchanged ), 1 ) ];
end 
end 

allIdPairs = vertcat( allIdPairs{ : } );
allStates = [ allStates{ : } ];
allUnchanged = vertcat( allUnchanged{ : } );

if isempty( allIdPairs )
allIdPairs = zeros( 0, 2 );
end 

this.doSnapshot( allIdPairs, allStates, allUnchanged, invalidatePrior );
this.fireChangeEvent(  );
end 

function success = next( this, n )
R36
this( 1, 1 )
n( 1, 1 ){ mustBeGreaterThanOrEqual( n, 1 ) } = 1
end 
this.assertUnlocked(  );
if this.HasNext
this.applyState( min( this.Pointer + n, this.NumFrames ) );
this.fireChangeEvent(  );
success = true;
else 
success = false;
end 
end 

function success = previous( this, n )
R36
this( 1, 1 )
n( 1, 1 ){ mustBeGreaterThanOrEqual( n, 1 ) } = 1
end 
this.assertUnlocked(  );
if this.HasPrevious
this.applyState( max( this.Pointer - n, 1 ) );
this.fireChangeEvent(  );
success = true;
else 
success = false;
end 
end 

function invalidate( this )

this.assertUnlocked(  );
indices = 1:this.Pointer - 1;
if ~isempty( indices )
this.doInvalidate( 1:this.Pointer - 1 );
this.updateManagedStatus(  );
end 
end 

function has = get.HasNext( this )
has = this.Pointer < this.NumFrames;
end 

function has = get.HasPrevious( this )
has = this.Pointer > 1;
end 

function state = get.State( this )
frame = this.CurrentFrame;
indices = this.getIndices( frame );
states = cell( size( frame, 1 ), 1 );
for i = 1:numel( indices )
states{ i } = this.SubStates( indices( i ) ).states{ frame( i, 3 ) };
end 
if isempty( states )
states = {  };
end 
state = struct( 'owner', num2cell( frame( :, 1 ) ), 'trackableId', num2cell( frame( :, 2 ) ), 'state', states );
end 

function frame = get.CurrentFrame( this )
frame = this.Frames{ this.Pointer };
end 

function numFrames = get.NumFrames( this )
numFrames = numel( this.Frames );
end 

function set.IsRestoring( this, restoring )
this.IsRestoring = restoring;
this.updateManagedStatus(  );
end 

function set.ManagedStatusObject( this, status )
this.ManagedStatusObject = status;
this.updateManagedStatus(  );
end 

function delete( this )
for i = 1:numel( this.StateOwners )
if ~isvalid( this.StateOwners{ i } )
continue 
end 
try 
this.StateOwners{ i }.BoundStateTracker = coderapp.internal.undo.StateTracker.empty(  );
catch 
end 
end 
end 
end 

methods ( Access = private )
function doRemoveStateOwner( this, stateOwner, notifyChange )
idx = find( cellfun( @( s )isequal( s, stateOwner ), this.StateOwners ), 1 );
if isempty( idx )
return 
end 
this.StateOwners( idx ) = [  ];
stateOwner.BoundStateTracker = coderapp.internal.undo.StateTracker.empty(  );


this.SubStates( [ this.SubStates.owner ] == idx ) = [  ];
inFrame = this.FrameMembership( idx, : );
for i = find( inFrame )
frame = this.Frames{ i };
frame( frame( :, 1 ) == i, : ) = [  ];
this.Frames{ i } = frame;
end 


this.FrameMembership( idx, : ) = [  ];
emptied = ~any( this.FrameMembership, 1 );
emptiedCount = nnz( emptied );
if emptiedCount > 0
this.Frames( emptied ) = [  ];
oldHasNext = this.HasNext;
oldHasPrev = this.HasPrevious;
this.Pointer = this.Pointer - emptiedCount;
if notifyChange && ( oldHasNext ~= this.HasNext || oldHasPrev ~= this.HasPrevious )
this.fireChangeEvent(  );
end 
end 
end 

function doSnapshot( this, idPairs, states, unchangedIdPairs, invalidatePrior )

indices = this.getIndices( idPairs, true );
newCounts = vertcat( this.SubStates( indices ).count ) + 1;
for i = 1:numel( indices )
this.SubStates( indices( i ) ).count = newCounts( i );
this.SubStates( indices( i ) ).states{ end  + 1 } = states{ i };
end 


frame = this.CurrentFrame;

frame( ~ismember( frame( :, 1:2 ), [ idPairs;unchangedIdPairs ], 'rows' ), : ) = [  ];

knownSelect = ismember( frame( :, 1:2 ), idPairs, 'rows' );
frame( knownSelect, 3 ) = frame( knownSelect, 3 ) + 1;

newMask = ~ismember( idPairs, frame( :, 1:2 ), 'rows' );
frame( end  + 1:end  + nnz( newMask ), : ) = [ idPairs( newMask, : ), newCounts( newMask ) ];

this.Pointer = this.Pointer + 1;
this.Frames{ this.Pointer } = frame;
this.FrameMembership( :, this.Pointer ) = true;


if invalidatePrior

invalidationRanges = 1:this.Pointer - 1;
elseif this.NumFrames > this.MaxFrames

invalidationRanges = 1;
else 
invalidationRanges = [  ];
end 

invalidationRanges = [ invalidationRanges, this.Pointer + 1:this.NumFrames ];

this.doInvalidate( invalidationRanges );
this.updateManagedStatus(  );
end 

function doInvalidate( this, frameIdx )
if isempty( frameIdx )
return 
end 

remaining = this.Frames;
purged = remaining( frameIdx );
purged = unique( vertcat( purged{ : } ), 'rows' );
remaining( frameIdx ) = [  ];
frameDivs = cellfun( 'size', remaining, 1 );
remaining = vertcat( remaining{ : } );

purgedIdPairs = purged( :, 1:2 );
remIdPairs = remaining( :, 1:2 );


isDefunct = ~ismember( purgedIdPairs, remIdPairs, 'rows' );

this.SubStates( this.getIndices( unique( purgedIdPairs( isDefunct, : ), 'rows' ) ) ) = [  ];


purgedRefs = setdiff( purged( ~isDefunct, : ), remaining, 'rows' );
sIdx = this.getIndices( purgedRefs );
[ ~, rIdx ] = ismember( remIdPairs, purgedRefs( :, 1:2 ), 'rows' );
rIdx( rIdx ~= 0 ) = sIdx( rIdx( rIdx ~= 0 ) );
for idx = unique( reshape( sIdx, 1, [  ] ) )

purgedPointers = purgedRefs( sIdx == idx, 3 );
this.SubStates( idx ).count = this.SubStates( idx ).count - numel( purgedPointers );
this.SubStates( idx ).states( purgedPointers ) = [  ];

rSelect = rIdx == idx;
remaining( rSelect, 3 ) = remaining( rSelect, 3 ) - sum( remaining( rSelect, 3 ) > purgedPointers', 2 );
end 
this.Frames = mat2cell( remaining, frameDivs, 3 )';


this.Pointer = this.Pointer - nnz( frameIdx <= this.Pointer );
this.FrameMembership( :, frameIdx ) = [  ];
end 

function indices = getIndices( this, ownerIdPairs, append )
if size( ownerIdPairs, 2 ) > 2
ownerIdPairs = ownerIdPairs( :, 1:2 );
end 
if ~isempty( this.SubStates )
[ tracked, indices ] = ismember( ownerIdPairs, [ vertcat( this.SubStates.owner ), vertcat( this.SubStates.id ) ], 'rows' );
else 
tracked = false( size( ownerIdPairs, 1 ), 1 );
indices = zeros( size( ownerIdPairs, 1 ), 1 );
end 
untracked = ownerIdPairs( ~tracked, : );
append = nargin > 2 && append;

if isempty( untracked )
return 
elseif ~append
error( 'Unrecognized tracking ID pairs: %s', strjoin( cellstr( num2str( untracked ) ), ', ' ) );
end 

range = numel( this.SubStates ) + 1:numel( this.SubStates ) + size( untracked, 1 );
this.SubStates( range ) = cell2struct(  ...
[ num2cell( untracked ), repmat( { 0, {  } }, size( untracked, 1 ), 1 ) ],  ...
{ 'owner', 'id', 'count', 'states' }, 2 );
indices( ~tracked ) = range;
end 

function applyState( this, pointer )
frame = this.Frames{ pointer };
oldFrame = this.Frames{ this.Pointer };
this.Pointer = pointer;
frameIdPairs = frame( :, 1:2 );
oldIdPairs = oldFrame( :, 1:2 );



[ ~, enterIdx, exitIdx ] = setxor( frameIdPairs, oldIdPairs, 'rows' );
[ ~, fShareIdx, oShareIdx ] = intersect( frameIdPairs, oldIdPairs, 'rows' );
changed = frame( frame( fShareIdx, 3 ) ~= oldFrame( oShareIdx, 3 ), : );


entered = frame( enterIdx, : );
enteredState = this.composeSubStates( entered );
changedState = this.composeSubStates( changed );
exited = this.composeSubStates( oldFrame( exitIdx, : ) );
exited = [ exited.trackableId ];


exitedOwners = oldFrame( exitIdx, 1 );
cleanup = this.lock( true );%#ok<NASGU>
for i = reshape( find( this.FrameMembership( :, pointer ) ), 1, [  ] )
this.StateOwners{ i }.applyTrackedState( enteredState( entered( :, 1 ) == i ),  ...
changedState( changed( :, 1 ) == i ), exited( exitedOwners == i ) );
end 

this.updateManagedStatus(  );
end 

function states = composeSubStates( this, frame )
raw = this.SubStates( this.getIndices( frame ) );
states = cell( numel( raw ), 1 );
for i = 1:numel( raw )
states{ i } = raw( i ).states{ frame( i, 3 ) };
end 
states = struct( 'trackableId', num2cell( frame( :, 2 ) ), 'state', states );
end 

function recoverFromError( this, badOwner )



this.doRemoveStateOwner( badOwner, false );
this.addStateOwner( badOwner );
end 

function fireChangeEvent( this )
this.notify( 'StateChanged' );
end 

function unlockHandle = lock( this, restoring )
this.assertUnlocked(  );
if nargin < 2
restoring = false;
end 

this.Locked = true;
unlockHandle = onCleanup( @(  )this.clearLocked( restoring ) );

if restoring
this.IsRestoring = true;
for i = 1:numel( this.StateOwners )
this.StateOwners{ i }.IsRestoring = true;
end 
end 
end 

function clearLocked( this, restoring )
this.Locked = false;
if restoring && this.IsRestoring
this.IsRestoring = false;
for i = 1:numel( this.StateOwners )
this.StateOwners{ i }.IsRestoring = false;
end 
end 
end 

function assertUnlocked( this )
if this.Locked
error( 'StateTracker is currently locked for processing a prior request' );
end 
end 

function updateManagedStatus( this )
if ~isempty( this.ManagedStatusObject ) && isvalid( this.ManagedStatusObject )
this.ManagedStatusObject.CanUndo = this.HasPrevious;
this.ManagedStatusObject.CanRedo = this.HasNext;
end 
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmphc59vc.p.
% Please follow local copyright laws when handling this file.

