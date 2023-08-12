classdef NewController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller







methods 

function obj = NewController( Model, App )




R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% NewController is created.' )
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.NewController{ mustBeNonempty };
src( 1, 1 )matlab.ui.internal.toolstrip.Button = [  ];%#ok<INUSA> 
evt( 1, 1 )event.EventData = [  ];%#ok<INUSA> 
end 


if confirmClear( obj.App )

obj.Model.State = 'New';
end 


log( obj.Model.Logger, '% New Button Pressed.' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmp0t7wkR.p.
% Please follow local copyright laws when handling this file.

