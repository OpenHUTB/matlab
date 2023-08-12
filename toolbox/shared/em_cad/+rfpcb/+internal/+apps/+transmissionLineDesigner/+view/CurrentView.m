classdef CurrentView < rfpcb.internal.apps.transmissionLineDesigner.view.Document




properties 
Current
end 

methods 

function obj = CurrentView( Current )

R36
Current( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Current{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.Current;
end 
obj.Current = Current;
obj.DocumentGroupTag = 'analysisGroup';

obj.Tag = 'currentDocument';
obj.Title = getString( message( "rfpcb:transmissionlinedesigner:CurrentDocument" ) );
obj.Tile = 2;
obj.Visible = false;

debug( obj.Current.Logger, 'CurrentDocument = matlab.ui.internal.FigureDocument("Tag", "currentDocument", "DocumentGroupTag", "analysisGroup");' );
end 


function produce( obj )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.CurrentView
end 

if obj.Visible

compute( obj.Current, 'SuppressOutput', false );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpCuPR6O.p.
% Please follow local copyright laws when handling this file.

