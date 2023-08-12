classdef PropertiesController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller






methods 

function obj = PropertiesController( Model, App )


R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 

obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% PropertiesController is created.' )
end 


function process( obj, ~, ~ )
update( obj );
end 


function update( obj )
R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.PropertiesController{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.controller.PropertiesController;
end 
if ~obj.App.AppContainer.Visible
addComponent2Container( obj.App, 'Component', 'PropertyPanel' );
obj.App.AppContainer.Visible = true;
end 
if isempty( obj.Model.Properties.TransmissionLine )

else 


end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpfZxQR6.p.
% Please follow local copyright laws when handling this file.

