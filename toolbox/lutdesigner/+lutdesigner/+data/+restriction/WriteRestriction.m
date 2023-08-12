classdef WriteRestriction < lutdesigner.data.restriction.AccessRestriction

properties ( SetAccess = immutable )
Reason
end 

methods 
function this = WriteRestriction( reason )
R36
reason( 1, 1 )message = 'lutdesigner:data:unspecifiedDataSource'
end 
this.Reason = reason;
end 

function tf = isequalExceptPeerLock( wr1, wr2 )
R36
wr1 lutdesigner.data.restriction.WriteRestriction
wr2 lutdesigner.data.restriction.WriteRestriction
end 

wr1( arrayfun( @( wr )strcmp( wr.Reason.Identifier, 'lutdesigner:data:peerLocked' ), wr1 ) ) = [  ];
wr2( arrayfun( @( wr )strcmp( wr.Reason.Identifier, 'lutdesigner:data:peerLocked' ), wr2 ) ) = [  ];
tf = isequal( wr1, wr2 );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpCjzaHH.p.
% Please follow local copyright laws when handling this file.

