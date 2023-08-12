classdef View3DController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller





methods 

function obj = View3DController( Model, App )


R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% View3DController is created.' )
end 


function process( obj, src, evt )



R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.View3DController{ mustBeNonempty };
src = [  ];%#ok<INUSA>
evt = [  ];%#ok<INUSA>
end 


update( obj.App.View3DDocument );


log( obj.Model.Logger, '% View3D refreshed.' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp3Dh9No.p.
% Please follow local copyright laws when handling this file.

