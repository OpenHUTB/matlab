classdef ImportController < rfpcb.internal.apps.transmissionLineDesigner.controller.Controller






methods 

function obj = ImportController( Model, App )




R36
Model( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.AppModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.AppModel;
App( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.AppView{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.view.AppView;
end 
obj@rfpcb.internal.apps.transmissionLineDesigner.controller.Controller( Model, App );

log( obj.Model.Logger, '% ImportController is created.' )
end 


function process( obj, src, evt )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.controller.ImportController{ mustBeNonempty };
src = [  ];%#ok<INUSA>
evt = [  ];%#ok<INUSA>
end 


[ filename, pathname ] = uigetfile( '*.mat', 'Open a saved session' );


if ~( isequal( filename, 0 ) || isequal( pathname, 0 ) )
importedTLine = load( fullfile( pathname, filename ) );
names = fieldnames( importedTLine );
for i = 1:length( names )
if any( strcmpi( class( importedTLine.( names{ i } ) ), obj.Model.Names ) )

obj.Model.TransmissionLine = importedTLine.( names{ i } );
end 
end 
end 


bringToFront( obj.App.AppContainer );


log( obj.Model.Logger, '% Import Button Pressed.' );
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpAZSuZs.p.
% Please follow local copyright laws when handling this file.

