classdef CurrentController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller




methods 

function obj = CurrentController( Model, App )


R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% CurrentController is created.' )
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.CurrentController{ mustBeNonempty };
src( 1, 1 )matlab.ui.internal.toolstrip.ToggleGalleryItem = [  ];
evt( 1, 1 )matlab.ui.internal.toolstrip.base.ToolstripEventData = [  ];
end 


produce( obj, 'Current', src, evt );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpGxIih7.p.
% Please follow local copyright laws when handling this file.

