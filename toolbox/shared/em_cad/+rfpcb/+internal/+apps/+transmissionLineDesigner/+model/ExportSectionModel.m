classdef ExportSectionModel < matlab.mixin.SetGet




properties 
TransmissionLine
Logger
end 

methods 

function obj = ExportSectionModel( TransmissionLine, Logger )

R36
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
end 
obj.TransmissionLine = TransmissionLine;
obj.Logger = Logger;

log( obj.Logger, '% ExportSectionModel object created.' )
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp7OOsRn.p.
% Please follow local copyright laws when handling this file.

