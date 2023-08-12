classdef CommandWriter < handle




properties 
Writer = [  ];
SampleTime( 1, 1 )single{ mustBeFinite } = single(  - 1 );
State = int32(  - 1 );
end 
properties ( Constant = true )
Topic = 'Simulation3DEngineCommand';
LeaseDuration = 0
end 
methods 
function self = CommandWriter(  )
command = struct( 'state', self.getState(  ), 'sampleTime', self.getSampleTime(  ) );
self.Writer = sim3d.io.Publisher( sim3d.io.CommandWriter.Topic,  ...
'Packet', command,  ...
'LeaseDuration', sim3d.io.CommandWriter.LeaseDuration );
end 

function setSampleTime( self, sampleTime )
R36
self sim3d.io.CommandWriter
sampleTime( 1, 1 )single{ mustBePositive }
end 
self.SampleTime = sampleTime;
end 

function sampleTime = getSampleTime( self )
sampleTime = self.SampleTime;
end 

function setState( self, state )
R36
self sim3d.io.CommandWriter
state( 1, 1 )int32
end 
self.State = state;
end 

function state = getState( self )
state = self.State;
end 

function delete( self )
if ~isempty( self.Writer )
self.Writer.delete(  );
end 
end 

function write( self )
if ~isempty( self.Writer )
command = struct( 'state', self.getState(  ), 'sampleTime', self.getSampleTime(  ) );
self.Writer.send( command );
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpj7Hbn1.p.
% Please follow local copyright laws when handling this file.

