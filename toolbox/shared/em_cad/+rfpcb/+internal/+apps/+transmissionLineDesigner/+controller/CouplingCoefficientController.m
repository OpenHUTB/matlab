classdef CouplingCoefficientController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller





methods 
function obj = CouplingCoefficientController( Model, App )


R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% CouplingCoefficientController is created.' )
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp84z0mz.p.
% Please follow local copyright laws when handling this file.

