classdef ResultsView < rfpcb.internal.apps.transmissionLineDesigner.view.Document





properties 

Results
end 

properties 

Layout

Table


AutoCalculateCheckbox

CalculateResultsButton

ViewModelButton
end 

properties ( Constant, Access = private )
CellHeight = 50;
end 

methods 

function obj = ResultsView( Results )


R36
Results( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Results{ mustBeNonempty } = rfpcb.internal.apps.transmissionLineDesigner.model.Results;
end 
obj.Results = Results;
obj.DocumentGroupTag = 'analysisGroup';


obj.Tag = 'resultsDocument';
obj.Title = getString( message( "rfpcb:transmissionlinedesigner:ResultsDocument" ) );
obj.Tile = 3;


debug( obj.Results.Logger, 'ResultsDocument = matlab.ui.internal.FigureDocument("Tag", "resultsDocument", "DocumentGroupTag", "analysisGroup");' );


createUIComponents( obj );
end 


function createUIComponents( obj )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.ResultsView = rfpcb.internal.apps.transmissionLineDesigner.view.ResultsView;
end 


obj.Layout = uigridlayout( obj.Figure, RowHeight = { '2x', obj.CellHeight, '1x' }, ColumnWidth = { '1x', '1x', '4x', '1x' } );


obj.AutoCalculateCheckbox = uicheckbox( obj.Layout, Text = 'Auto-Calculate', Value = true );
obj.AutoCalculateCheckbox.Layout.Row = 1;
obj.AutoCalculateCheckbox.Layout.Column = 1;


obj.CalculateResultsButton = uibutton( obj.Layout, Text = 'Calculate Results', Enable = 'off' );
obj.CalculateResultsButton.Layout.Row = 1;
obj.CalculateResultsButton.Layout.Column = 2;
obj.ViewModelButton = uibutton( obj.Layout, Text = 'View Model' );
obj.ViewModelButton.Layout.Row = 1;
obj.ViewModelButton.Layout.Column = 4;


obj.Table = uitable( obj.Layout,  ...
ColumnName = obj.Results.Entities,  ...
RowName = '',  ...
Data = { [  ], [  ], [  ], [  ], [  ], [  ] } );
obj.Table.Layout.Row = 2;
obj.Table.Layout.Column = [ 1, 4 ];
end 


function produce( obj )

R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.ResultsView
end 


fillResults( obj );
end 
end 

methods ( Access = private )

function fillResults( obj )


obj.Table.Data = cellfun( @( x )obj.Results.( x ), obj.Results.Entities, 'UniformOutput', false );
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpB8NA4v.p.
% Please follow local copyright laws when handling this file.

