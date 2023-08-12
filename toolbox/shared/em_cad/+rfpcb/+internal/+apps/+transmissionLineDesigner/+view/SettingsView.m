classdef SettingsView < handle





properties 
Figure
Settings
end 

properties 
SettingsSection
SettingsButton
end 

properties 
Layout
UnitsLabel
UnitsDropdown
SnapToGridLabel
SnapToGridCheckbox
GridResolutionLabel
GridResolutionEditField
ResultsPerUnitLengthLabel
ResultsPerUnitLengthcheckbox
OkButton
CancelButton
end 

properties ( Constant, Access = private )
Width = 340;
Height = 250;
end 

methods 

function obj = SettingsView( Settings, options )



R36
Settings( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.model.Settings = rfpcb.internal.apps.transmissionLineDesigner.model.Settings;
options.Parent( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty } = matlab.ui.internal.toolstrip.Tab( 'Design' );
end 
obj.Settings = Settings;
obj.Figure = uifigure( Visible = "off", Resize = "off", NumberTitle = "off", HandleVisibility = "off" );
obj.Figure.Position( 3:4 ) = [ obj.Width, obj.Height ];
obj.Figure.Tag = 'settingsFigure';


create( obj, options.Parent )
end 


function show( obj, options )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.SettingsView;
options.Center = get( 0, "PointerLocation" );
end 
obj.Figure.Position( 1:2 ) = options.Center;
obj.Figure.Visible = 'on';

end 


function delete( obj )
obj.Figure.CloseRequestFcn = [  ];
obj.Figure.DeleteFcn = [  ];
delete( obj.Figure );
end 
end 

methods ( Access = private )

function create( obj, options )



createToolstripItems( obj, options );
log( obj.Settings.Logger, '% Settings section created.' );


createDialogItems( obj );
end 

function createToolstripItems( obj, Tab )


R36
obj( 1, 1 )rfpcb.internal.apps.transmissionLineDesigner.view.SettingsView{ mustBeNonempty };
Tab( 1, 1 )matlab.ui.internal.toolstrip.Tab{ mustBeNonempty };
end 

import matlab.ui.internal.toolstrip.*;


obj.SettingsSection = Section( 'Settings' );
obj.SettingsSection.Tag = 'settingsSection';
Tab.add( obj.SettingsSection );

settingsColumn = obj.SettingsSection.addColumn(  );
settingsColumn.Tag = 'settingsColumn';
obj.SettingsButton = Button( 'Settings', Icon.SETTINGS_24 );
obj.SettingsButton.Tag = 'settingsButton';
obj.SettingsButton.Description = getString( message( 'rfpcb:transmissionlinedesigner:SettingsButton' ) );
settingsColumn.add( obj.SettingsButton );
end 

function createDialogItems( obj )


obj.Figure.Name = 'Settings';


obj.Layout = uigridlayout( obj.Figure, RowHeight = { 25, 25, 25, 25, 30, 25, 30 }, ColumnWidth = { '1x', '1x', '1x', '1x' } );


obj.UnitsLabel = uilabel( obj.Layout, Text = 'Units', HorizontalAlignment = 'right', Tag = 'unitsLabel' );
obj.UnitsLabel.Layout.Column = [ 1, 2 ];
obj.UnitsDropdown = uidropdown( obj.Layout, Items = { 'm', 'cm', 'mm', 'inch', 'mil' }, Tag = 'units' );
obj.UnitsDropdown.Layout.Column = [ 3, 4 ];


obj.SnapToGridLabel = uilabel( obj.Layout, Text = 'Snap to Grid', HorizontalAlignment = 'right', Tag = 'snapToGridLabel' );
obj.SnapToGridLabel.Layout.Column = [ 1, 2 ];
obj.SnapToGridCheckbox = uicheckbox( obj.Layout, Text = '', Tag = 'snapToGrid' );
obj.SnapToGridCheckbox.Layout.Column = [ 3, 4 ];


obj.GridResolutionLabel = uilabel( obj.Layout, Text = 'Grid Resolution', HorizontalAlignment = 'right', Tag = 'gridResolutionLabel' );
obj.GridResolutionLabel.Layout.Column = [ 1, 2 ];
obj.GridResolutionEditField = uieditfield( obj.Layout, Tag = 'gridResolution' );
obj.GridResolutionEditField.Layout.Column = [ 3, 4 ];


obj.ResultsPerUnitLengthLabel = uilabel( obj.Layout, Text = 'Show Results per unit length', HorizontalAlignment = 'right', Tag = 'resultsPerUnitLengthLabel' );
obj.ResultsPerUnitLengthLabel.Layout.Column = [ 1, 2 ];
obj.ResultsPerUnitLengthcheckbox = uicheckbox( obj.Layout, Text = '', Tag = 'resultsPerUnitLength' );
obj.ResultsPerUnitLengthcheckbox.Layout.Column = [ 3, 4 ];


obj.OkButton = uibutton( obj.Layout, Text = 'Ok', Tag = 'okButton' );
obj.OkButton.Layout.Column = 2;
obj.OkButton.Layout.Row = 6;
obj.CancelButton = uibutton( obj.Layout, Text = 'Cancel', Tag = 'cancelButton' );
obj.CancelButton.Layout.Column = 3;
obj.CancelButton.Layout.Row = 6;

end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmpUS8bC0.p.
% Please follow local copyright laws when handling this file.

