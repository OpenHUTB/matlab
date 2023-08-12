classdef UnknownDataSource < lutdesigner.data.source.DataSource

properties ( SetAccess = immutable )
Reason
end 

methods 
function this = UnknownDataSource( reason )
R36
reason( 1, 1 )message = 'lutdesigner:data:unspecifiedDataSource'
end 
this = this@lutdesigner.data.source.DataSource( 'unknown source', '', '' );
this.Reason = reason;
end 

function registerPeerLockUnlockHandler( this, ~ )
error( this.Reason );
end 

function unregisterPeerLockUnlockHandler( ~ )
end 

function registerPeerWriteHandler( this, ~ )
error( this.Reason );
end 

function unregisterPeerWriteHandler( ~ )
end 

function tf = isequal( this, that )
tf = isequal@lutdesigner.data.source.DataSource( this, that ) && isequal( this.Reason, that.Reason );
end 
end 

methods ( Access = protected )
function restrictions = getReadRestrictionsImpl( this )
restrictions = lutdesigner.data.restriction.ReadRestriction( this.Reason );
end 

function restrictions = getWriteRestrictionsImpl( this )
restrictions = lutdesigner.data.restriction.WriteRestriction( this.Reason );
end 

function data = readImpl( ~ )%#ok
end 

function writeImpl( ~, ~ )
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnmYWSk.p.
% Please follow local copyright laws when handling this file.

