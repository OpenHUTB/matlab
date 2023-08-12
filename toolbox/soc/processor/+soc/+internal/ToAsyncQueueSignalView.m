


classdef ToAsyncQueueSignalView
properties ( Hidden )
QueueH
SignalName
SignalPath
ModelName
InitialVal
StartTime
SignalID
end 

methods 
function h = ToAsyncQueueSignalView( modelName, sigName, sigPath, initialVal, startTime, disableThining )
h.ModelName = modelName;
h.SignalName = sigName;
h.SignalPath = sigPath;
h.InitialVal = initialVal;
h.StartTime = startTime;
h.SignalID = char( matlab.lang.internal.uuid );

aqSig = Simulink.AsyncQueue.Signal.create( Simulink.AsyncQueue.DataType( class( h.InitialVal ) ), int32( 1 ), false, false );
aqSigSource = Simulink.AsyncQueue.SignalSource;
aqSigSource.Path = [ h.ModelName, '/', h.SignalPath ];
aqSigSource.ID = h.SignalID;
aqSigSource.Name = h.SignalName;
aqSigSource.Index = 1;
aqSig.setSource( aqSigSource );

h.QueueH = Simulink.AsyncQueue.Queue( aqSig );
if ( disableThining )
h.QueueH.disableDataThinning;
end 
end 

function update( h, val, time )
assert( isvalid( h.QueueH ) );
assert( isequal( class( val ), class( h.InitialVal ) ) );
h.QueueH.write( time, val );
end 

function clear( h )
delete( h.QueueH );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpuX_X3O.p.
% Please follow local copyright laws when handling this file.

