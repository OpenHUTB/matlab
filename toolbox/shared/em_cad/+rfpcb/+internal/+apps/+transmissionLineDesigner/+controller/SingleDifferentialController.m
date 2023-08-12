classdef SingleDifferentialController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller







methods 

function obj = SingleDifferentialController( Model, App )





R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% SingleDifferentialController is created.' )
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SingleDifferentialController{ mustBeNonempty };
src = [  ];%#ok<INUSA>
evt = [  ];%#ok<INUSA>
end 


log( obj.Model.Logger, '% Single differential radio button pressed.' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpP3wAU7.p.
% Please follow local copyright laws when handling this file.

