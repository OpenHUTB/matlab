classdef OpenController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller





methods 

function obj = OpenController( Model, App )


R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% OpenController is created.' )
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.OpenController{ mustBeNonempty };
src( 1, 1 )matlab.ui.internal.toolstrip.Button = [  ];%#ok<INUSA> 
evt( 1, 1 )event.EventData = [  ];%#ok<INUSA> 
end 












bringToFront( obj.App.AppContainer );


log( obj.Model.Logger, '% Charge Button Pressed.' );
end 
end 

methods ( Access = private )
function setCurrentAppState( obj, AppSession )



setCurrentState( obj.Model, AppSession.Model );
setCurrentState( obj.App, AppSession.App );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpQETYic.p.
% Please follow local copyright laws when handling this file.

