classdef View3D < rfpcb.internal.apps.transmissionLineDesigner.view.Document




properties 
View3DModel
end 

methods 

function obj = View3D( View3DModel )

R36
View3DModel( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.View3DModel{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.View3DModel;
end 
obj.View3DModel = View3DModel;
obj.DocumentGroupTag = 'visualizationGroup';

obj.Tag = 'view3dDocument';
obj.Title = getString( message( "rfpcb:transmissionlinedesigner:View3DDocument" ) );
obj.Tile = 2;

debug( obj.View3DModel.Logger, 'View3DDocument = matlab.ui.internal.FigureDocument("Tag", "view3dDocument", "DocumentGroupTag", "visualizationGroup");' );

create( obj );
end 


function create( obj )
obj.Figure.AutoResizeChildren = 'off';
bannerText = getString( message( 'rfpcb:transmissionlinedesigner:BannerText' ) );
bannerLength = length( bannerText );
if mod( bannerLength, 2 ) ~= 0
bannerLength = bannerLength + 1;
end 
bannerText = [ bannerText( 1:bannerLength / 2 ), newline, bannerText( bannerLength / 2 + 1:end  ) ];

l = uigridlayout( obj.Figure, 'RowHeight', { '1x', '6x', '1x' }, 'ColumnWidth', { '1x', '15x', '1x' }, 'Scrollable', 'on' );

bannerLabel = uilabel( l,  ...
'HorizontalAlignment', 'left',  ...
'Text', bannerText,  ...
'FontSize', 15 );
bannerLabel.Layout.Row = 2;
bannerLabel.Layout.Column = 2;
end 


function produce( obj )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.View3D{ mustBeNonempty }
end 

if isempty( obj.View3DModel.TransmissionLine )
clf( obj.Figure );
drawnow update;
create( obj );
else 

show( obj.View3DModel.TransmissionLine );
end 


log( obj.View3DModel.Logger, '% View3D plotted.' );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpMAZbQ5.p.
% Please follow local copyright laws when handling this file.

