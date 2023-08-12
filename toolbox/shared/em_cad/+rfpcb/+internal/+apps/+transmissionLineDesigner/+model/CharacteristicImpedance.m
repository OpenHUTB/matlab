classdef CharacteristicImpedance < rfpcb.internal.apps.transmissionLineDesigner.model.Analysis







properties 

DesignImpedance( 1, 1 )double{ mustBeNonempty, mustBeScalarOrEmpty, mustBeNonNan, mustBeFinite, mustBeReal, mustBePositive } = 50;

Impedance( 1, 1 )double{ mustBeNonempty, mustBeScalarOrEmpty, mustBeNonNan, mustBeFinite, mustBeReal, mustBePositive } = 50;
end 

methods 

function obj = CharacteristicImpedance( TransmissionLine, Logger )




R36
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( Logger );
obj.TransmissionLine = TransmissionLine;

log( obj.Logger, '% CharacteristicImpedance object created.' )
end 


function compute( obj, SuppressOutput )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.CharacteristicImpedance{ mustBeNonempty }
SuppressOutput = true;
end 


impedanceFcn = @(  )getZ0( obj.TransmissionLine );
compute@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( obj, impedanceFcn, SuppressOutput );


log( obj.Logger, '% Characteristic Impedance computed.' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpdeseh3.p.
% Please follow local copyright laws when handling this file.

