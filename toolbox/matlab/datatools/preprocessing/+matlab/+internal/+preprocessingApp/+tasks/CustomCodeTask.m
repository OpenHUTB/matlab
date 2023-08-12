classdef CustomCodeTask < handle


properties ( Constant )
VARNAME_TAG = "VariableName"
WSDD_DEFAULT = 'select variable';
Channel = '/preprocessingAppRtcChannel';
end 

properties 
UIFigure matlab.ui.Figure = matlab.ui.Figure.empty
Workspace = "base"
GridLayout matlab.ui.container.GridLayout
CodeLabel matlab.ui.control.Label
GridLayout2 matlab.ui.container.GridLayout
PreviewButton matlab.ui.control.Button
GridLayout3 matlab.ui.container.GridLayout
DescriptionEditFieldLabel matlab.ui.control.Label
DescriptionEditFieldErrorLabel matlab.ui.control.Label
DescriptionEditField matlab.ui.control.EditField
CodeTextAreaErrorBox matlab.internal.preprocessingApp.rtc.rtcErrorView
CodeTextArea matlab.internal.preprocessingApp.rtc.rtcView
GridLayout4 matlab.ui.container.GridLayout
GridLayout5 matlab.ui.container.GridLayout
VariableDropDownLabel matlab.ui.control.Label
VariableDropDown matlab.ui.control.internal.model.WorkspaceDropDown
end 

properties ( Dependent )
VariableName
Description
Code
Summary
State
end 
methods 
function varName = get.VariableName( obj )
varName = obj.VariableDropDown.Value;
if strcmp( varName, 'select' )
varName = "";
end 
end 

function set.VariableName( obj, varName )
if isempty( varName ) || strlength( varName ) == 0
obj.VariableDropDown.Value = obj.WSDD_DEFAULT;
else 
obj.VariableDropDown.Value = varName;
end 
end 

function code = get.Code( obj )
code = obj.CodeTextArea.Value;
end 

function set.Code( obj, code )
obj.CodeTextArea.Value = code;
message.publish( '/preprocessingAppRtcChannel/setCode', code );

end 

function enableRtc( obj, bool )
obj.CodeTextArea.Enable = bool;
message.publish( '/preprocessingAppRtcChannel/enableRtc', bool );
end 


function resizeRtc( obj )
obj.CodeTextArea.resize(  );
end 

function description = get.Description( obj )
description = obj.DescriptionEditField.Value;
description = strtrim( description );
end 

function set.Description( obj, description )
obj.DescriptionEditField.Value = description;
end 

function summary = get.Summary( obj )
summary = obj.Description;
end 

function state = get.State( obj )
state = struct(  );
state.VariableName = obj.VariableName;
state.Description = obj.Description;
state.Code = obj.Code;
end 

function set.State( obj, state )
setTaskState( obj, state );
end 
end 


methods 
function obj = CustomCodeTask( figToPlotTo, workspace, nvpairs )
R36
figToPlotTo = uifigure
workspace = "base"
nvpairs.Description( 1, 1 )string = ""
nvpairs.Code string = ""
nvpairs.State( 1, 1 )struct = struct
nvpairs.VariableName( 1, 1 )string = ""
end 

obj.UIFigure = figToPlotTo;
obj.Workspace = workspace;

obj.createUI;

obj.Description = nvpairs.Description;
obj.Code = nvpairs.Code;
obj.VariableName = nvpairs.VariableName;


state = nvpairs.State;
if isempty( state )
state = struct;
end 
obj.setTaskState( state );
end 

function [ script, varNames ] = generateScript( obj )
varNames = { obj.VariableName };
script = obj.Code;
end 

function vizScript = generateVisualizationScript( obj )
vizScript = string.empty;
end 

function setTaskState( obj, state )
if ~isempty( state ) && isfield( state, 'VariableName' )
obj.VariableName = state.VariableName;
obj.setCodeFromVarname;
else 
obj.VariableName = obj.WSDD_DEFAULT;
end 
if ~isempty( state ) && isfield( state, 'Description' )
obj.Description = state.Description;
obj.updateCodeCommentFromDescription( "" );
else 
obj.Description = "";
end 
if ~isempty( state ) && isfield( state, 'Code' )
obj.Code = state.Code;
else 
obj.Code = "";
end 


enableValue = ~isempty( obj.Code ) && strlength( obj.Code ) > 0;
obj.enableRtc( enableValue );
end 

function reset( obj )
obj.setTaskState( struct );
end 
end 

methods ( Access = protected )
function createUI( obj )

obj.GridLayout = uigridlayout( obj.UIFigure );
obj.GridLayout.ColumnWidth = { '1x' };
obj.GridLayout.RowHeight = { 25, 20, 20, '1x', 20 };
obj.GridLayout.RowSpacing = 2;
obj.GridLayout.Padding = [ 1, 1, 1, 1 ];


obj.CodeLabel = uilabel( obj.GridLayout );
obj.CodeLabel.Layout.Row = 3;
obj.CodeLabel.Layout.Column = 1;
obj.CodeLabel.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_CODE_TASK_CODE' ) );


obj.GridLayout2 = uigridlayout( obj.GridLayout );
obj.GridLayout2.ColumnWidth = { '1x', 150 };
obj.GridLayout2.RowHeight = { '1x' };
obj.GridLayout2.Padding = [ 0, 0, 0, 0 ];
obj.GridLayout2.Layout.Row = 5;
obj.GridLayout2.Layout.Column = 1;


obj.PreviewButton = uibutton( obj.GridLayout2, 'push' );
obj.PreviewButton.Layout.Row = 1;
obj.PreviewButton.Layout.Column = 2;
obj.PreviewButton.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_CODE_TASK_PREVIEW' ) );
obj.PreviewButton.ButtonPushedFcn = @( ~, ~ )obj.PreviewButtonPushed(  );


obj.GridLayout3 = uigridlayout( obj.GridLayout );
obj.GridLayout3.ColumnWidth = { 150, '1x' };
obj.GridLayout3.RowHeight = { '1x' };
obj.GridLayout3.Padding = [ 0, 0, 0, 0 ];
obj.GridLayout3.Layout.Row = 2;
obj.GridLayout3.Layout.Column = 1;


obj.DescriptionEditFieldLabel = uilabel( obj.GridLayout3 );
obj.DescriptionEditFieldLabel.Layout.Row = 1;
obj.DescriptionEditFieldLabel.Layout.Column = 1;
obj.DescriptionEditFieldLabel.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_CODE_TASK_DESCRIPTION' ) );


obj.DescriptionEditField = uieditfield( obj.GridLayout3, 'text' );
obj.DescriptionEditField.Tag = 'Description';
obj.DescriptionEditField.Layout.Row = 1;
obj.DescriptionEditField.Layout.Column = 2;
obj.DescriptionEditField.Value = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_CODE_TASK_DEFAULT_DESCRIPTION' ) );
obj.DescriptionEditField.ValueChangedFcn = @( e, d )obj.updateCodeCommentFromDescription( d.PreviousValue );


obj.DescriptionEditFieldErrorLabel = uilabel( obj.GridLayout3 );
obj.DescriptionEditFieldErrorLabel.Layout.Row = 1;
obj.DescriptionEditFieldErrorLabel.Layout.Column = 3;
obj.DescriptionEditFieldErrorLabel.FontColor = 'red';
obj.DescriptionEditFieldErrorLabel.Visible = "off";
obj.DescriptionEditFieldErrorLabel.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_CODE_TASK_REQUIRED_DESCRIPTION' ) );



obj.GridLayout5 = uigridlayout( obj.GridLayout );
obj.GridLayout5.ColumnWidth = { '3x', '1x' };
obj.GridLayout5.RowHeight = { '1x' };
obj.GridLayout5.Padding = [ 0, 0, 0, 0 ];
obj.GridLayout5.Layout.Row = 4;
obj.GridLayout5.Layout.Column = 1;


obj.CodeTextArea = matlab.internal.preprocessingApp.rtc.rtcView( obj.GridLayout5 );


obj.CodeTextAreaErrorBox = matlab.internal.preprocessingApp.rtc.rtcErrorView( obj.GridLayout5 );


obj.GridLayout4 = uigridlayout( obj.GridLayout );
obj.GridLayout4.ColumnWidth = { 150, 150, '1x' };
obj.GridLayout4.RowHeight = { '1x' };
obj.GridLayout4.Padding = [ 0, 0, 0, 0 ];
obj.GridLayout4.Layout.Row = 1;
obj.GridLayout4.Layout.Column = 1;


obj.VariableDropDownLabel = uilabel( obj.GridLayout4 );
obj.VariableDropDownLabel.Layout.Row = 1;
obj.VariableDropDownLabel.Layout.Column = 1;
obj.VariableDropDownLabel.Text = getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_CODE_TASK_VARIABLENAME' ) );


obj.VariableDropDown = matlab.ui.control.internal.model.WorkspaceDropDown( 'Parent', obj.GridLayout4, 'Workspace', obj.Workspace );
obj.VariableDropDown.Layout.Row = 1;
obj.VariableDropDown.Layout.Column = 2;
obj.VariableDropDown.Tag = obj.VARNAME_TAG;
obj.VariableDropDown.ValueChangedFcn = @( e, d )obj.setCodeFromVarname(  );
end 

function updateCodeCommentFromDescription( obj, prevValue )
code = obj.Code;
if isempty( code ) || strlength( code ) == 0 && ~strcmp( obj.VariableDropDown.Value, obj.WSDD_DEFAULT )
obj.setCodeFromVarname;
code = obj.Code;
end 
code = replace( code, "% " + prevValue + newline, "% " + obj.DescriptionEditField.Value + newline );
obj.Code = code;

if ~strcmp( obj.VariableDropDown.Value, obj.WSDD_DEFAULT ) ...
 && ~isempty( obj.DescriptionEditField.Value )
obj.enableRtc( true );
obj.DescriptionEditFieldErrorLabel.Visible = "off";
end 

end 

function PreviewButtonPushed( this )
message.publish( this.Channel + "/getCode", "" );
end 

function setCodeFromVarname( obj )
if ~strcmp( obj.VariableDropDown.Value, obj.WSDD_DEFAULT )
obj.enableRtc( true );
obj.DescriptionEditFieldErrorLabel.Visible = "off";
if isempty( obj.Code ) || strlength( strtrim( obj.Code ) ) == 0
code = "% " + obj.DescriptionEditField.Value + newline;
code = code + obj.VariableDropDown.Value + " =  " + obj.VariableDropDown.Value + ";" +  ...
" % " + getString( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_CODE_TASK_MODIFY_COMMENT' ) );
obj.Code = code;
end 
else 
obj.enableRtc( false );
obj.DescriptionEditFieldErrorLabel.Visible = "on";
end 
if isempty( obj.DescriptionEditField.Value )
obj.enableRtc( false );
obj.DescriptionEditFieldErrorLabel.Visible = "on";
end 
end 
end 

methods ( Static )
function task = getTask(  )
task = struct(  );
task.Name = string( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_CODE_TASK_TASKNAME' ) );
task.Description = string( message( 'MATLAB:datatools:preprocessing:tasks:tasks:CUSTOM_CODE_TASK_TASKDESCRIPTION' ) );
task.Group = string( getString( message( 'MATLAB:datatools:preprocessing:app:TASK_GROUP_USER' ) ) );
task.Path = "matlab.internal.preprocessingApp.tasks.CustomCodeTask";
task.Icon = matlab.ui.internal.toolstrip.Icon.ADD_24;
task.InputProperty = "VariableName";
task.TableVariableProperty = '';
task.TableVariableNamesProperty = '';
task.TableVariableVisibleProperty = '';
task.HasVisualization = false;
task.ReshapeOutputVariable = [  ];
task.IsTimetableProperty = '';
task.HasRowLabelsProperty = '';
task.NumberOfTableVariablesProperty = '';
task.DocFunctions = [  ];
end 
end 
end 


% Decoded using De-pcode utility v1.2 from file /tmp/tmpGN1yJl.p.
% Please follow local copyright laws when handling this file.

