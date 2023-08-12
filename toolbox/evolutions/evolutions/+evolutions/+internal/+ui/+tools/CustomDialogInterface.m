classdef ( Abstract )CustomDialogInterface < handle




properties ( Hidden, Access = ?evolutions.internal.app.dialogs.DialogManager )
TestMode logical
end 

properties ( Access = protected )
Figure
WorkingGrid


Label


Output

UserData
end 

methods 
function obj = CustomDialogInterface( userData )
R36
userData = [  ]
end 
obj.UserData = userData;
obj.createFigure;
obj.setDialogTitle( 'Default Title' );
mainPanel = obj.createMainPanel;
obj.createWorkingGrid( mainPanel );
obj.createDialogComponents;


obj.installCallbacks;
end 

function output = run( obj )
if ~obj.TestMode
obj.Figure.Visible = 'on';
waitfor( obj.Figure );
output = obj.Output;
else 

output = obj.Figure;
end 
end 
end 



methods ( Abstract )
end 

methods ( Abstract, Access = protected )
setDialogSize( obj );
setWorkingGridDimensions( obj );
createDialogComponents( obj );
installCallbacks( obj );
end 

methods ( Access = protected )
function createFigure( obj )
obj.Figure = uifigure( 'Resize', 'off', 'Visible', 'off', 'WindowStyle', 'modal' );
obj.setDialogSize;
obj.Figure.Position( 3 ) = obj.DialogWidth;
obj.Figure.Position( 4 ) = obj.DialogHeight;
end 

function mainPanel = createMainPanel( obj )
gridRows = { '1x' };
gridCols = { '1x' };
mainGrid = uigridlayout ...
( obj.Figure, 'RowHeight', gridRows, 'ColumnWidth', gridCols );
mainPanel = uipanel( mainGrid, 'Visible', 1 );
end 

function createWorkingGrid( obj, mainPanel )
obj.setWorkingGridDimensions;
obj.WorkingGrid = uigridlayout ...
( mainPanel, 'RowHeight', obj.WorkingGridRows, 'ColumnWidth', obj.WorkingGridCols );
end 

function setDialogTitle( obj, title )
obj.Figure.Name = title;
end 

function createLabel( obj, prompt )
obj.Label = uilabel( obj.WorkingGrid, 'Text', prompt );
obj.Label.Layout.Row = 1;
end 

end 

methods ( Access = public )
function setDialogPosition( obj, position )
obj.Figure.Position( 1 ) = position( 1 ) + position( 3 ) / 3;
obj.Figure.Position( 2 ) = position( 2 ) + position( 4 ) / 3;
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpI8spFd.p.
% Please follow local copyright laws when handling this file.

