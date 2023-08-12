classdef SparametersView < rfpcb.internal.apps.transmissionLineDesigner.view.Document




properties 
Sparameters
end 

methods 

function obj = SparametersView( Sparameters )


R36
Sparameters( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Sparameters{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.Sparameters;
end 
obj.Sparameters = Sparameters;
obj.DocumentGroupTag = 'analysisGroup';

obj.Tag = 'sparametersDocument';
obj.Title = getString( message( "rfpcb:transmissionlinedesigner:SparametersDocument" ) );
obj.Tile = 2;
obj.Visible = false;

debug( obj.Sparameters.Logger, 'SparametersDocument = matlab.ui.internal.FigureDocument("Tag", "sparametersDocument", "DocumentGroupTag", "analysisGroup");' );
end 


function produce( obj )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.SparametersView
end 

if obj.Visible

compute( obj.Sparameters, 'SuppressOutput', false );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpMTCeV7.p.
% Please follow local copyright laws when handling this file.

