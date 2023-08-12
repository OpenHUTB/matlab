classdef View2DController < handle





properties 
CADView
CADModel
CADController
end 

properties 
Model
App
end 

methods 

function obj = View2DController( Model, App )


R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj.Model = Model;
obj.App = App;

log( obj.Model.Logger, '% View2DController is created.' )

addViewModelAndController( obj );
end 


function addViewModelAndController( obj )
obj.CADView = [ cad.Cad2DCanvas( obj.App.View2DDocument.Figure ) ];
bannerText = getString( message( 'rfpcb:transmissionlinedesigner:BannerText' ) );
bannerLength = length( bannerText );
if mod( bannerLength, 2 ) ~= 0
bannerLength = bannerLength + 1;
end 
bannerText = [ bannerText( 1:bannerLength / 2 ), newline, bannerText( bannerLength / 2 + 1:end  ) ];
obj.CADView.InstructionalText.String = bannerText;
sf = cad.ShapeFactory;
of = cad.OperationsFactory;
obj.CADModel = cad.CADModel( sf, of );
obj.CADController = cad.Controller( obj.CADView, obj.CADModel );
end 


function process( obj, src, evt )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.View2DController{ mustBeNonempty };
src = [  ];%#ok<INUSA> 
evt = [  ];%#ok<INUSA> 
end 


log( obj.Model.Logger, '% View2D refreshed.' );
end 


function update( obj )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.View2DController{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.controller.View2DController;
end 
if ~obj.App.AppContainer.Visible
addComponent2Container( obj.App, 'Component', 'PropertyPanel' );
obj.App.AppContainer.Visible = true;
end 
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpyW5PLI.p.
% Please follow local copyright laws when handling this file.

