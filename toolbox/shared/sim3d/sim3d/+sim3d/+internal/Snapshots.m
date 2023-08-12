classdef Snapshots < handle


properties 
States = [  ];
end 

methods 
function self = Snapshots(  )

self.States = [  ];
end 

function takeSnapshot( self, Actor, Name, Properties, IncludeChildren )





















R36
self( 1, 1 )sim3d.internal.Snapshots;
Actor( 1, 1 )sim3d.AbstractActor
Name( 1, : )char = ''
Properties( 1, : )cell = { 'Location', 'Rotation' }
IncludeChildren( 1, 1 )logical = true
end 

if isempty( Name )
Name = [ 'Snapshot', num2str( size( self.States, 1 ) + 1 ) ];
end 

Time = now;



data = Actor.gather( Properties, IncludeChildren );


hash = char( Properties );
hash = [ hash( :, 1 )', num2str( size( data, 1 ) ) ];


if ~isempty( self.States ) && ( Time < self.States{ end , 1 } )
self.States = sortrows( [ self.States;{ Time, Name, Properties, data, hash } ], 1 );
else 
self.States = [ self.States;{ Time, Name, Properties, data, hash } ];
end 


end 

function found = restoreSnapshot( self, SnapID )










found = 1;

if ischar( SnapID )
id = strcmpi( self.States( :, 2 ), SnapID );
else 
[ ~, id ] = min( abs( [ self.States{ :, 1 } ] - SnapID ) );
end 
states = self.States( id, : );


if ~isempty( states )
props = states{ end , 3 };
data = states{ end , 4 };
for a = 1:size( data, 1 )
for p = 1:numel( props )
if ( isprop( data{ a, 1 }, props{ p } ) )
data{ a, 1 }.( props{ p } ) = data{ a, p + 1 };
end 
end 
end 
else 
found = 0;
end 

end 


function removeSnapshot( self, SnapID )










R36
self( 1, 1 )sim3d.internal.Snapshots
SnapID
end 

if ischar( SnapID )
id = strcmpi( self.States( :, 2 ), SnapID );
else 
timeAxis = [ self.States{ :, 1 } ];
if numel( SnapID ) == 2
id = and( timeAxis >= SnapID( 1 ), timeAxis <= SnapID( 2 ) );
else 
id = ( timeAxis == SnapID );
end 
end 
self.States( id, : ) = [  ];
end 

function States = getStates( self )
States = self.States;
end 

function setStates( self, States )
self.States = States;
end 

function reset( self )
self.States = [  ];
end 

end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpITs7TX.p.
% Please follow local copyright laws when handling this file.

