classdef NumberOfAgressorsController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller








methods 

function obj = NumberOfAgressorsController( Model, App )





R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% NumberOfAgressorsController is created.' )
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.NumberOfAgressorsController{ mustBeNonempty };
src = [  ];%#ok<INUSA> 
evt = [  ];%#ok<INUSA> 
end 


log( obj.Model.Logger, '% Number of aggressors changed.' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpj0Fj_l.p.
% Please follow local copyright laws when handling this file.

