classdef FeedCurrent < rfpcb.internal.apps.transmissionLineDesigner.model.Analysis




methods 

function obj = FeedCurrent( TransmissionLine, Logger )

R36
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( Logger );
obj.TransmissionLine = TransmissionLine;

log( obj.Logger, '% FeedCurrent object created.' )
end 


function compute( obj, SuppressOutput )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.FeedCurrent{ mustBeNonempty }
SuppressOutput = true;
end 


feedcurrentFcn = @(  )feedCurrent( obj.TransmissionLine, obj.Frequency );
compute@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( obj, feedcurrentFcn, SuppressOutput );


log( obj.Logger, '% Feed Current computed.' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp_rQPCE.p.
% Please follow local copyright laws when handling this file.

