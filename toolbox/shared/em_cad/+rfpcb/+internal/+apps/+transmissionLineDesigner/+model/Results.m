classdef Results < rfpcb.internal.apps.transmissionLineDesigner.model.Analysis



properties 
IsAutoCalculate( 1, 1 ){ mustBeNumericOrLogical } = true;
end 

properties ( Constant, Hidden )
Entities = { 'Resistance',  ...
'Inductance',  ...
'Capacitance',  ...
'PropagationDelay',  ...
'CharacteristicImpedance',  ...
'FeedCurrent' };
end 

properties ( Dependent, SetAccess = private )
Capacitance
PropagationDelay
CharacteristicImpedance
FeedCurrent
Inductance
Resistance
end 

properties ( Access = private )
pCapacitance
pPropagationDelay
pCharacteristicImpedance
pFeedCurrent
pInductance
pResistance
end 

methods 

function obj = Results( TransmissionLine, Logger, options )

R36
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
options.Capacitance( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Capacitance = rfpcb.internal.apps.transmissionLineDesigner.model.Capacitance;
options.PropagationDelay( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.PropagationDelay = rfpcb.internal.apps.transmissionLineDesigner.model.PropagationDelay;
options.CharacteristicImpedance( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.CharacteristicImpedance = rfpcb.internal.apps.transmissionLineDesigner.model.CharacteristicImpedance;
options.FeedCurrent( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.FeedCurrent = rfpcb.internal.apps.transmissionLineDesigner.model.FeedCurrent;
options.Inductance( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Inductance = rfpcb.internal.apps.transmissionLineDesigner.model.Inductance;
options.Resistance( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Resistance = rfpcb.internal.apps.transmissionLineDesigner.model.Resistance;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( Logger );


obj.TransmissionLine = TransmissionLine;
obj.pCapacitance = options.Capacitance;
obj.pPropagationDelay = options.PropagationDelay;
obj.pCharacteristicImpedance = options.CharacteristicImpedance;
obj.pFeedCurrent = options.FeedCurrent;
obj.pInductance = options.Inductance;
obj.pResistance = options.Resistance;


log( obj.Logger, '% Results object created.' )
end 



function set.Capacitance( obj, newValue )
obj.pCapacitance.Value = newValue;
end 

function rtn = get.Capacitance( obj )
rtn = obj.pCapacitance.Value;
end 

function set.PropagationDelay( obj, newValue )
obj.pPropagationDelay.Value = newValue;
end 

function rtn = get.PropagationDelay( obj )
rtn = obj.pPropagationDelay.Value;
end 

function set.CharacteristicImpedance( obj, newValue )
obj.pCharacteristicImpedance.Value = newValue;
end 

function rtn = get.CharacteristicImpedance( obj )
rtn = obj.pCharacteristicImpedance.Value;
end 

function set.FeedCurrent( obj, newValue )
obj.pFeedCurrent.Value = newValue;
end 

function rtn = get.FeedCurrent( obj )
rtn = obj.pFeedCurrent.Value;
end 

function set.Inductance( obj, newValue )
obj.pInductance.Value = newValue;
end 

function rtn = get.Inductance( obj )
rtn = obj.pInductance.Value;
end 

function set.Resistance( obj, newValue )
obj.pResistance.Value = newValue;
end 

function rtn = get.Resistance( obj )
rtn = obj.pResistance.Value;
end 


function compute( obj )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Results{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.Results;
end 


resultsFcn = @(  )randi( 5, 1, length( obj.Entities ) );
compute@rfpcb.internal.apps.transmissionLineDesigner.model.Analysis( obj, resultsFcn, true );

setResultValues( obj );


log( obj.Logger, '% Results computed.' )
end 
end 

methods ( Access = private )
function setResultValues( obj )
for i = 1:length( obj.Entities )
obj.( obj.Entities{ i } ) = obj.Value( i );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpPLijHf.p.
% Please follow local copyright laws when handling this file.

