classdef Sparameters < rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots




properties 

Impedance( 1, : )double{ mustBeNonempty, mustBeNonzero, mustBeNumeric } = 50;
end 

methods 

function obj = Sparameters( TransmissionLine, Logger )

R36
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.model.AnalysisPlots( TransmissionLine, Logger );
obj.TransmissionLine = TransmissionLine;

log( obj.Logger, '% Sparameters object created.' )
end 


function compute( obj, options )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Sparameters{ mustBeNonempty }
options.SuppressOutput = true;
end 


obj.Value = sparameters( obj.TransmissionLine, obj.FrequencyRange, obj.Impedance );
sparamFcn = @(  )rfplot( obj.Value );
if ~options.SuppressOutput
drawnow update
compute@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( obj, sparamFcn, options.SuppressOutput );
end 


log( obj.Logger, '% Sparameters computed.' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpomeSYQ.p.
% Please follow local copyright laws when handling this file.

