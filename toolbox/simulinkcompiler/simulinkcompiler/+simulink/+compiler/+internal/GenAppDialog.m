classdef GenAppDialog < handle




properties 
ModelName = ""
end 

properties ( Constant, Access = private )
TagPrefix = 'genapp_'
Templates = [ { 'MultiPaneSimApp' };{ 'Custom' }; ]
end 

properties ( Access = private )
CustomTemplateSelected( 1, 1 )logical = false
end 

methods 
function obj = GenAppDialog( modelName )
R36
modelName( 1, 1 )string
end 

obj.ModelName = modelName;
end 

function schema = getDialogSchema( obj )

labelDescription.Type = 'text';
labelDescription.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogDescriptionContent' );
labelDescription.RowSpan = [ 1, 1 ];
labelDescription.ColSpan = [ 1, 1 ];
labelDescription.Tag = [ obj.TagPrefix, 'Description' ];
labelDescription.WordWrap = true;

grpDescription.Type = 'group';
grpDescription.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogDescriptionLabel' );
grpDescription.LayoutGrid = [ 1, 1 ];
grpDescription.Items = { labelDescription };


items = {  };
rowCounter = 1;


templateChoice.Type = 'combobox';
templateChoice.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogTemplateChoiceLabel' );
templateChoice.Entries = obj.Templates;
templateChoice.RowSpan = [ rowCounter, rowCounter ];
templateChoice.ColSpan = [ 1, 3 ];
templateChoice.Visible = 1;
templateChoice.Mode = 1;
templateChoice.Graphical = 1;
templateChoice.Source = obj;
templateChoice.ObjectMethod = 'templateChoiceChangedCB';
templateChoice.MethodArgs = { '%dialog' };
templateChoice.ArgDataTypes = { 'handle' };
templateChoice.Tag = [ obj.TagPrefix, 'Template' ];
templateChoice.ToolTip = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogTemplateChoiceTooltip' );
templateChoice.DialogRefresh = true;

items = [ items, { templateChoice } ];
rowCounter = rowCounter + 1;


customTemplatePath.Type = 'edit';
customTemplatePath.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogCustomTemplateEditLabel' );
customTemplatePath.RowSpan = [ rowCounter, rowCounter ];
customTemplatePath.ColSpan = [ 1, 4 ];
customTemplatePath.Mode = 1;
customTemplatePath.Graphical = 1;
customTemplatePath.Visible = obj.CustomTemplateSelected;
customTemplatePath.Value = '';
customTemplatePath.Tag = [ obj.TagPrefix, 'CustomTemplatePath' ];
customTemplatePath.MinimumSize = [ 300, 0 ];


customTemplateBrowse.Type = 'pushbutton';
customTemplateBrowse.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogBrowseButtonLabel' );
customTemplateBrowse.RowSpan = [ rowCounter, rowCounter ];
customTemplateBrowse.ColSpan = [ 5, 5 ];
customTemplateBrowse.Mode = 1;
customTemplateBrowse.Graphical = 1;
customTemplateBrowse.Visible = obj.CustomTemplateSelected;
customTemplateBrowse.Source = obj;
customTemplateBrowse.ObjectMethod = 'browseCustomTemplate';
customTemplateBrowse.MethodArgs = { '%dialog' };
customTemplateBrowse.ArgDataTypes = { 'handle' };
customTemplateBrowse.Tag = [ obj.TagPrefix, 'BrowseTemplatePathButton' ];

items = [ items, { customTemplatePath, customTemplateBrowse } ];
rowCounter = rowCounter + 1;


editAppName.Type = 'edit';
editAppName.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogAppNameLabel' );
editAppName.RowSpan = [ rowCounter, rowCounter ];
editAppName.ColSpan = [ 1, 4 ];
editAppName.Value = strcat( obj.ModelName, '_SLSimApp' );
editAppName.Mode = 1;
editAppName.Graphical = 1;
editAppName.Tag = [ obj.TagPrefix, 'AppName' ];

items = [ items, { editAppName } ];
rowCounter = rowCounter + 1;


editAppPath.Type = 'edit';
editAppPath.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogPathEditLabel' );
editAppPath.RowSpan = [ rowCounter, rowCounter ];
editAppPath.ColSpan = [ 1, 4 ];
editAppPath.Mode = 1;
editAppPath.Graphical = 1;
editAppPath.Value = pwd;
editAppPath.Tag = [ obj.TagPrefix, 'AppPath' ];
editAppPath.MinimumSize = [ 300, 0 ];


appPathBrowse.Type = 'pushbutton';
appPathBrowse.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogBrowseButtonLabel' );
appPathBrowse.RowSpan = [ rowCounter, rowCounter ];
appPathBrowse.ColSpan = [ 5, 5 ];
appPathBrowse.Mode = 1;
appPathBrowse.Graphical = 1;
appPathBrowse.Source = obj;
appPathBrowse.ObjectMethod = 'browseAppPath';
appPathBrowse.MethodArgs = { '%dialog' };
appPathBrowse.ArgDataTypes = { 'handle' };
appPathBrowse.Tag = [ obj.TagPrefix, 'BrowseOutputDirButton' ];
appPathBrowse.ToolTip = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogBrowseButtonTooltip' );

items = [ items, { editAppPath, appPathBrowse } ];
rowCounter = rowCounter + 1;


grpContentsOptions.Type = 'group';
grpContentsOptions.Visible = true;
grpContentsOptions.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogOptionsLabel' );
grpContentsOptions.Tag = [ obj.TagPrefix, 'GenAppOptions' ];
grpContentsOptions.ColStretch = [ 4, 11, 7 ];
grpContentsOptions.LayoutGrid = [ rowCounter, 3 ];

grpContentsOptions.Items = items;


btnGenerate.Type = 'pushbutton';
btnGenerate.RowSpan = [ 1, 1 ];
btnGenerate.ColSpan = [ 3, 3 ];
btnGenerate.Mode = 1;
btnGenerate.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogCreateButtonLabel' );
btnGenerate.ObjectMethod = 'generateApp';
btnGenerate.Source = obj;
btnGenerate.MethodArgs = { '%dialog' };
btnGenerate.ArgDataTypes = { 'handle' };
btnGenerate.Tag = [ obj.TagPrefix, 'generateAppButton' ];
btnGenerate.ToolTip = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogCreateButtonTooltip' );


btnCancel.Type = 'pushbutton';
btnCancel.Mode = 1;
btnCancel.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogCancelButtonLabel' );
btnCancel.RowSpan = [ 1, 1 ];
btnCancel.ColSpan = [ 4, 4 ];
btnCancel.ObjectMethod = 'cancel';
btnCancel.MethodArgs = { '%dialog' };
btnCancel.Source = obj;
btnCancel.ArgDataTypes = { 'handle' };
btnCancel.Tag = [ obj.TagPrefix, 'cancelButton' ];
btnCancel.ToolTip = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogCancelButtonTooltip' );


btnHelp.Type = 'pushbutton';
btnHelp.Mode = 1;
btnHelp.Graphical = 1;
btnHelp.Name = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogHelpButtonLabel' );
btnHelp.RowSpan = [ 1, 1 ];
btnHelp.ColSpan = [ 5, 5 ];
btnHelp.ObjectMethod = 'help';
btnHelp.Source = obj;
btnHelp.Tag = [ obj.TagPrefix, 'helpButton' ];
btnHelp.ToolTip = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogHelpButtonTooltip' );


pnlButton.Type = 'panel';
pnlButton.LayoutGrid = [ 1, 5 ];
pnlButton.ColStretch = [ 0, 0, 0, 0, 0 ];
pnlButton.Items = { btnGenerate, btnHelp, btnCancel };


schema.DialogTitle = DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogTitle' );
schema.DialogTag = [ obj.TagPrefix, 'dialog' ];

schema.StandaloneButtonSet = pnlButton;
schema.IsScrollable = true;
schema.Items = { grpDescription, grpContentsOptions };
end 

function browseAppPath( obj, dlg )
saveDirectory = uigetdir( '', DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogBrowseDialogTitle' ) );
if saveDirectory ~= 0
dlg.setWidgetValue( [ obj.TagPrefix, 'AppPath' ], saveDirectory );
end 
end 

function browseCustomTemplate( obj, dlg )
[ templateFile, tempatePath ] = uigetfile( '*.mlapp', DAStudio.message( 'simulinkcompiler:genapp:GenAppDialogBrowseCustomTemplateTitle' ) );
if tempatePath ~= 0
dlg.setWidgetValue( [ obj.TagPrefix, 'CustomTemplatePath' ], fullfile( tempatePath, templateFile ) );
end 
end 

function help( ~ )
helpview( fullfile( docroot, 'slcompiler', 'helptargets.map' ), 'genapp_dialog' );
end 

function cancel( ~, dlg )
delete( dlg );
end 

function generateApp( obj, dlg )
templateChoice = dlg.getWidgetValue( [ obj.TagPrefix, 'Template' ] );
templateName = obj.Templates{ templateChoice + 1 };
appName = dlg.getWidgetValue( [ obj.TagPrefix, 'AppName' ] );
outputDir = dlg.getWidgetValue( [ obj.TagPrefix, 'AppPath' ] );
delete( dlg );

stage = sldiagviewer.createStage( getString( message( 'simulinkcompiler:genapp:GenAppDialogDVStageName' ) ), 'ModelName', string( obj.ModelName ) );
try 
simulink.compiler.genapp( obj.ModelName, "Template", templateName, "AppName", appName, "OutputDir", outputDir );
addpath( outputDir );
catch ME
sldiagviewer.reportError( ME );
end 
delete( stage );
end 

function templateChoiceChangedCB( obj, dlg )
templateChoice = dlg.getWidgetValue( [ obj.TagPrefix, 'Template' ] );
templateName = obj.Templates{ templateChoice + 1 };
obj.CustomTemplateSelected = strcmp( templateName, 'Custom' );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp88RNZx.p.
% Please follow local copyright laws when handling this file.

