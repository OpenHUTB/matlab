classdef ( Abstract )StateOwner < handle




properties ( SetAccess = ?coderapp.internal.undo.StateTracker, Hidden, SetObservable )
IsRestoring logical = false
end 

properties ( SetAccess = ?coderapp.internal.undo.StateTracker, SetObservable, Hidden )
BoundStateTracker coderapp.internal.undo.StateTracker = coderapp.internal.undo.StateTracker.empty(  )
end 

methods 
function set.BoundStateTracker( this, tracker )
if ~isempty( tracker )
this.onStateTrackerAttach( tracker );
end 
this.BoundStateTracker = tracker;
end 
end 

methods ( Abstract, Access = { ?coderapp.internal.undo.StateOwner, ?coderapp.internal.undo.StateTracker } )




[ state, unchangedIds ] = getTrackableState( this, full )








applyTrackedState( this, enteredStates, changedStates, exitedIds )
end 

methods ( Access = protected )
function requestStateSnapshot( this, invalidatePrior )
R36
this( 1, 1 )
invalidatePrior( 1, 1 )logical = false
end 
if ~isempty( this.BoundStateTracker )
this.BoundStateTracker.snapshot( invalidatePrior );
end 
end 

function onStateTrackerAttach( this, tracker )%#ok<INUSD>            
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpmvbU4b.p.
% Please follow local copyright laws when handling this file.

