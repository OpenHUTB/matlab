classdef ExportController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller








methods 

function obj = ExportController( Model, App )





R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% ExportController is created.' )
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.ExportController{ mustBeNonempty };
src( 1, 1 ){ mustBeA( src, [ 'matlab.ui.internal.toolstrip.ListItem', 'matlab.ui.internal.toolstrip.SplitButton' ] ) } = [  ];
evt( 1, 1 )event.EventData = [  ];%#ok<INUSA>
end 


switch src.Tag
case { 'exportSplitButton', 'exportWorkspaceButton' }
case 'exportScriptButton'
case 'exportModel'
case 'exportFileS2P'
end 


log( obj.Model.Logger, '% Charge Button Pressed.' );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpv0LOt_.p.
% Please follow local copyright laws when handling this file.

