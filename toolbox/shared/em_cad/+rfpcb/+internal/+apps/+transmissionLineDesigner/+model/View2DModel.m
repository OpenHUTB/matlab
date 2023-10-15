classdef View2DModel < rfpcb.internal.apps.transmissionLineDesigner.model.Visualization




methods 

function obj = View2DModel( TransmissionLine, Logger )

arguments
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.model.Visualization( Logger );
obj.TransmissionLine = TransmissionLine;

log( obj.Logger, '% View2D object created.' )
end 


function update( obj )

arguments
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.View2DModel{ mustBeNonempty }
end 

if ~isempty( obj.TransmissionLine )

else 
clear( obj );
end 


log( obj.Logger, '% View2D plot computed.' )
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpGzgrfU.p.
% Please follow local copyright laws when handling this file.

