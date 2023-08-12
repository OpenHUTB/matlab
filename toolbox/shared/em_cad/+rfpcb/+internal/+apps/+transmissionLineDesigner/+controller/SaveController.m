classdef SaveController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller





properties 
IgnorePropsToSave = {  };
end 

methods 

function obj = SaveController( Model, App )


R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% SaveController is created.' )
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.SaveController{ mustBeNonempty };
src( 1, 1 )matlab.ui.internal.toolstrip.SplitButton = [  ];%#ok<INUSA> 
evt( 1, 1 )event.EventData = [  ];%#ok<INUSA> 
end 









bringToFront( obj.App.AppContainer );


update( obj.App.FileSectionView );


log( obj.Model.Logger, '% Save Button Pressed.' );
end 
end 

methods ( Access = private )
function rtn = getCurrentAppState( obj )



rtn = struct(  );
rtn.Model = getCurrentState( obj.Model );
rtn.App = getCurrentState( obj.App );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpN_IF5M.p.
% Please follow local copyright laws when handling this file.

