classdef Visualization < matlab.mixin.SetGet




properties 
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
end 

properties 
Value
end 

properties ( Hidden )
Logger
end 

methods 

function obj = Visualization( Logger )

R36
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
end 
obj.Logger = Logger;
end 


function update( obj )

update( obj );
end 


function clear( obj )
obj.Value = [  ];
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpzLICOe.p.
% Please follow local copyright laws when handling this file.

