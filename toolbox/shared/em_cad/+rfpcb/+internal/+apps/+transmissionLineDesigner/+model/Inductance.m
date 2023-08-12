classdef Inductance < rfpcb.internal.apps.transmissionLineDesigner.model.Analysis




methods 

function obj = Inductance( TransmissionLine, Logger )

R36
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( Logger );
obj.TransmissionLine = TransmissionLine;

log( obj.Logger, '% Inductance object created.' )
end 


function compute( obj, SuppressOutput )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Inductance{ mustBeNonempty }
SuppressOutput = true;
end 








log( obj.Logger, '% Inductance computed.' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpvkH6jW.p.
% Please follow local copyright laws when handling this file.

