classdef View3DModel < rfpcb.internal.apps.transmissionLineDesigner.model.Visualization




properties 
Geometry
end 

methods 

function obj = View3DModel( TransmissionLine, Logger )

R36
TransmissionLine{ mustBeA( TransmissionLine, [ "rfpcb.TxLine", "double" ] ) } = microstripLine;
Logger( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Logger = rfpcb.internal.apps.transmissionLineDesigner.model.Logger;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.model.Visualization( Logger );
obj.TransmissionLine = TransmissionLine;

log( obj.Logger, '% View3D object created.' )
end 


function update( obj )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.View3DModel{ mustBeNonempty }
end 

if ~isempty( obj.TransmissionLine )

createGeometry( obj.TransmissionLine );
obj.Geometry = getGeometry( obj.TransmissionLine );


log( obj.Logger, '% View3D plotted.' )
else 
obj.Geometry = [  ];
clear( obj );
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpiafTct.p.
% Please follow local copyright laws when handling this file.

