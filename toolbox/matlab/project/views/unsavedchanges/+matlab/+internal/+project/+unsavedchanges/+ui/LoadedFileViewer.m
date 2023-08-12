classdef LoadedFileViewer < handle




events ( NotifyAccess = private )
Close
end 

properties ( GetAccess = public, SetAccess = private, Hidden )
LoadedFileUIFigure matlab.ui.Figure
GridLayout matlab.ui.container.GridLayout
Tree matlab.ui.container.Tree
SaveAllChangesButton matlab.ui.control.Button
DiscardAllChangesButton matlab.ui.control.Button
CancelButton matlab.ui.control.Button
Label matlab.ui.control.Label
Image matlab.ui.control.Image
ProgressIndicator matlab.ui.control.internal.CircularProgressIndicator
end 

properties ( GetAccess = public, SetAccess = immutable )
Provider matlab.internal.project.unsavedchanges.LoadedFileProvider
Filter function_handle
Customization struct
end 

properties ( Access = private )
LoadedFiles matlab.internal.project.unsavedchanges.LoadedFile
Timer timer
ViewerContainsUnsavedFiles logical
end 

methods ( Access = public )
function this = LoadedFileViewer( provider, filter, customization )
R36
provider( 1, 1 )matlab.internal.project.unsavedchanges.LoadedFileProvider = matlab.internal.project.unsavedchanges.TrackingLoadedFileProvider
filter( 1, 1 )function_handle = @noFilter;

customization.FigureTitle( 1, 1 )string = "MATLAB:project:view_unsaved_changes:UnsavedChanges";

customization.SaveButtonAction( 1, 1 )string = "saveAllChanges";
customization.DiscardButtonAction( 1, 1 )string = "discardAllChanges";


customization.SaveButtonText( 1, 1 )string = "MATLAB:project:view_unsaved_changes:SaveAll";
customization.DiscardButtonText( 1, 1 )string = "MATLAB:project:view_unsaved_changes:DiscardAll";
customization.CancelButtonText( 1, 1 )string = "MATLAB:project:view_unsaved_changes:Close";

customization.DirtySaveButtonText( 1, 1 )string = "MATLAB:project:view_unsaved_changes:SaveAll";
customization.DirtyDiscardButtonText( 1, 1 )string = "MATLAB:project:view_unsaved_changes:DiscardAll"





customization.FileNodeActions( :, 2 )string = [ "MATLAB:project:view_unsaved_changes:Open", "openFile" ];
customization.GroupNodeActions( :, 2 )string = string.empty;
customization.DirtyFileNodeActions( :, 2 )string = [ 
"MATLAB:project:view_unsaved_changes:Open", "openFile";
"MATLAB:project:view_unsaved_changes:Save", "saveFile";
"MATLAB:project:view_unsaved_changes:Discard", "discardFile" ];
customization.DirtyGroupNodeActions( :, 2 )string = [ 
"MATLAB:project:view_unsaved_changes:SaveAll", "saveGroupFiles";
"MATLAB:project:view_unsaved_changes:DiscardAll", "discardGroupFiles" ];

customization.LabelNoProblem( 1, 1 )string = "MATLAB:project:view_unsaved_changes:AllProjectFilesSaved";
customization.LabelSingleProblem( 1, 1 )string = "MATLAB:project:view_unsaved_changes:SingleUnsavedProjectFile";
customization.LabelMultiProblem( 1, 1 )string = "MATLAB:project:view_unsaved_changes:MultipleUnsavedProjectFiles";
customization.InfoText( 1, 1 )string = "";

customization.AutoCloseUI( 1, 1 )logical = false;
customization.WindowStyle( 1, 1 )string = "default";
end 

this.Customization = customization;
this.Provider = provider;
this.Filter = filter;

this.createComponents(  );
this.createTimer(  );
end 

function delete( this )

this.close(  );
delete( this.Timer );
delete( this.LoadedFileUIFigure );
end 

function show( this )
if this.Timer.Running ~= "on"
start( this.Timer );
end 



if isvalid( this )
figure( this.LoadedFileUIFigure );
end 
end 

function close( this )
stop( this.Timer );
this.LoadedFileUIFigure.Visible = false;

eventData = matlab.internal.project.unsavedchanges.ui.CloseEventData( ~this.ViewerContainsUnsavedFiles );
notify( this, "Close", eventData );
end 
end 


methods ( Access = private )


function buttonAction( this, action )
oncleanup = enableProgressIndicator( this );%#ok<NASGU>
if ~isempty( this.LoadedFiles )
this.Provider.( action )( [ this.LoadedFiles.Path ] );
end 
refreshView( this );
end 

function saveAllChanges( this )
buttonAction( this, "save" );
end 

function discardAllChanges( this )
buttonAction( this, "discard" );
end 

function saveChangesAndCloseAll( this )
oncleanup = enableProgressIndicator( this );%#ok<NASGU>
if ~isempty( this.LoadedFiles )
files = [ this.LoadedFiles.Path ];
this.Provider.save( files );

this.Provider.discard( files );
end 
refreshView( this );
end 

function cancelButtonAction( this )
close( this.LoadedFileUIFigure );
end 



function fileAction( this, action, fileNode )
if isvalid( fileNode )
oncleanup = enableProgressIndicator( this );%#ok<NASGU>
fileNodeAction( this, action, fileNode );
end 
end 

function openFile( this, fileNode )
fileAction( this, "open", fileNode );
end 

function saveFile( this, fileNode )
fileAction( this, "save", fileNode );
end 

function discardFile( this, fileNode )
fileAction( this, "discard", fileNode );
end 

function saveAndClose( this, fileNode )
if isvalid( fileNode )
oncleanup = enableProgressIndicator( this );%#ok<NASGU>
files = fileNodeAction( this, "save", fileNode );

this.Provider.discard( files );
end 
end 


function groupAction( this, action, tree )
if isvalid( tree )
oncleanup = enableProgressIndicator( this );%#ok<NASGU>
groupNodeAction( this, action, tree );
end 
end 

function saveGroupFiles( this, tree )
groupAction( this, "save", tree );
end 

function discardGroupFiles( this, tree )
groupAction( this, "discard", tree );
end 

function saveAndCloseGroupFiles( this, tree )
if isvalid( tree )
oncleanup = enableProgressIndicator( this );%#ok<NASGU>
files = groupNodeAction( this, "save", tree );

this.Provider.discard( files );
end 
end 






function files = groupNodeAction( this, method, tree )
selectedNodes = this.Tree.SelectedNodes;
if ismember( tree, selectedNodes )
files = string.empty;
for n = 1:length( selectedNodes )
if ~isempty( selectedNodes( n ).Children )
files = [ files, selectedNodes( n ).Children.NodeData ];%#ok<AGROW>
end 
end 
this.Provider.( method )( files );
else 
files = [ tree.Children.NodeData ];
this.Provider.( method )( files );
end 
this.refreshView(  );
end 

function files = fileNodeAction( this, method, fileNode )
selectedNodes = this.Tree.SelectedNodes;
if ismember( fileNode, selectedNodes )


files = [ selectedNodes.NodeData ];
if isempty( files )
return ;
end 
this.Provider.( method )( files )
else 
files = fileNode.NodeData;
this.Provider.( method )( files );
end 
this.refreshView(  );
end 
end 

methods ( Access = private )
function createComponents( this )

this.LoadedFileUIFigure = uifigure( 'Visible', 'off', "WindowStyle", this.Customization.WindowStyle );
this.LoadedFileUIFigure.Name = i_getMessage( this.Customization.FigureTitle );
this.LoadedFileUIFigure.Tag = "UnsavedChanges";
this.LoadedFileUIFigure.Position = [ 100, 100, 500, 480 ];
this.LoadedFileUIFigure.CloseRequestFcn = @( ~, ~ )this.close(  );
movegui( this.LoadedFileUIFigure, 'center' );


this.GridLayout = uigridlayout( this.LoadedFileUIFigure );
this.GridLayout.ColumnWidth = { 32, '1x', 'fit', 'fit', 'fit' };
this.GridLayout.RowHeight = { 30, '1x', 'fit' };


this.ProgressIndicator = matlab.ui.control.internal.CircularProgressIndicator( 'Parent', this.GridLayout );
this.ProgressIndicator.Layout.Row = 3;
this.ProgressIndicator.Layout.Column = 1;
this.ProgressIndicator.Indeterminate = true;
this.ProgressIndicator.Visible = false;


this.Tree = uitree( this.GridLayout, 'Tag', 'FileTree' );
this.Tree.Layout.Row = 2;
this.Tree.Layout.Column = [ 1, 5 ];
this.Tree.Multiselect = true;
this.Tree.DoubleClickedFcn = @( ~, data )this.openFile( data.InteractionInformation.Node );


this.SaveAllChangesButton = uibutton( this.GridLayout, 'push', 'Tag', 'SaveAllButton' );
this.SaveAllChangesButton.ButtonPushedFcn = @( btn, event )feval( this.Customization.SaveButtonAction, this );
this.SaveAllChangesButton.Layout.Row = 3;
this.SaveAllChangesButton.Layout.Column = 3;


this.DiscardAllChangesButton = uibutton( this.GridLayout, 'push', 'Tag', 'DiscardAllButton' );
this.DiscardAllChangesButton.ButtonPushedFcn = @( btn, event )feval( this.Customization.DiscardButtonAction, this );
this.DiscardAllChangesButton.Layout.Row = 3;
this.DiscardAllChangesButton.Layout.Column = 4;


this.CancelButton = uibutton( this.GridLayout, 'push', 'Tag', 'CancelButton' );
this.CancelButton.ButtonPushedFcn = @( btn, event )cancelButtonAction( this );
this.CancelButton.Layout.Row = 3;
this.CancelButton.Layout.Column = 5;
this.CancelButton.Text = i_getMessage( this.Customization.CancelButtonText );


this.Label = uilabel( this.GridLayout, 'Tag', 'Instruction' );
this.Label.Layout.Row = 1;
if this.Customization.InfoText ~= ""
this.Label.Layout.Column = [ 2, 5 ];
this.Image = uiimage( this.GridLayout );
this.Image.ImageSource = fullfile( matlabroot, "toolbox", "matlab", "project", "views", "unsavedchanges", "icons", "dialog_warning_32.png" );
this.Image.Layout.Row = 1;
this.Image.Layout.Column = 1;
else 
this.Label.Layout.Column = [ 1, 5 ];
end 
end 

function createGroupedTree( this, group )
groupNode = uitreenode( this.Tree, 'Text', group.name );
groupContextMenu = uicontextmenu( this.LoadedFileUIFigure );
groupNode.ContextMenu = groupContextMenu;
groupNode.Icon = fullfile( matlabroot, "toolbox", "matlab", "project", "views", "unsavedchanges", "icons", "project_undecorated.png" );

groupContainsUnsavedFiles = createFileNodesAndGetDirtyFlag( this, group.files, groupNode );
expand( this.Tree );

if groupContainsUnsavedFiles
actions = this.Customization.DirtyGroupNodeActions;
else 
actions = this.Customization.GroupNodeActions;
end 
addContextMenuActions( this, groupNode, actions );
end 

function groupContainsUnsavedFiles = createFileNodesAndGetDirtyFlag( this, files, parentNode )
groupContainsUnsavedFiles = false;
for n = 1:length( files )
[ ~, fileName, ext ] = fileparts( files( n ).Path );
name = strcat( fileName, ext );

if files( n ).hasProperty( matlab.internal.project.unsavedchanges.Property.Unsaved )
unsaved = "*";
fileIsUnsaved = true;
this.ViewerContainsUnsavedFiles = true;
groupContainsUnsavedFiles = true;
else 
unsaved = "";
fileIsUnsaved = false;
end 

propsMeta = ?matlab.internal.project.unsavedchanges.Property;
props = { propsMeta.EnumerationMemberList.Name };

props( props == "Unsaved" ) = [  ];
tagStrings = intersect( files( n ).Properties, props );
if ~isempty( tagStrings )
tags = " (" + strjoin( arrayfun( @( tag )i_getMessage( "MATLAB:project:view_unsaved_changes:" + tag ), tagStrings ), ', ' ) + ")";
else 
tags = "";
end 

fileNode = uitreenode( parentNode, 'Text', name + unsaved + tags );
fileNode.NodeData = files( n ).Path;

if fileIsUnsaved
actions = this.Customization.DirtyFileNodeActions;
else 
actions = this.Customization.FileNodeActions;
end 
addContextMenuActions( this, fileNode, actions );
end 
end 

function addContextMenuActions( this, node, actions )
contextMenu = uicontextmenu( this.LoadedFileUIFigure );
node.ContextMenu = contextMenu;

[ rows, columns ] = size( actions );
if columns ~= 2
return ;
end 

for m = 1:rows
cm = uimenu( node.ContextMenu, 'Text', i_getMessage( actions( m, 1 ) ) );
cm.MenuSelectedFcn = @( src, event )feval( actions( m, 2 ), this, node );
end 
end 

function updateGroupedTree( this, fileGroups )
if isempty( fileGroups )
this.Label.Text = i_getMessage( this.Customization.LabelNoProblem );
this.Tree.Children.delete;
setButtonsEnabled( this, false );
this.ViewerContainsUnsavedFiles = false;
this.LoadedFiles = matlab.internal.project.unsavedchanges.LoadedFile.empty;
return ;
end 
setButtonsEnabled( this, true );

newLoadedFiles = matlab.internal.project.unsavedchanges.LoadedFile.empty;
for n = 1:length( fileGroups )
newLoadedFiles = [ newLoadedFiles, fileGroups( n ).files ];%#ok<AGROW>
end 

updateResult = updateLoadedFiles( this, newLoadedFiles );
if ~updateResult
return ;
end 

this.ViewerContainsUnsavedFiles = false;
this.Tree.Children.delete;
for n = 1:length( fileGroups )
createGroupedTree( this, fileGroups( n ) );
end 

this.LoadedFiles = newLoadedFiles;
addLabel( this );
end 

function updateFileNodes( this, files )
if isempty( files )
this.Label.Text = i_getMessage( this.Customization.LabelNoProblem );
this.Tree.Children.delete;
setButtonsEnabled( this, false );
this.ViewerContainsUnsavedFiles = false;
this.LoadedFiles = matlab.internal.project.unsavedchanges.LoadedFile.empty;
return ;
end 
setButtonsEnabled( this, true );

updateResult = updateLoadedFiles( this, files );
if ~updateResult
return ;
end 

this.ViewerContainsUnsavedFiles = false;
this.Tree.Children.delete;
this.LoadedFiles = files;
createFileNodesAndGetDirtyFlag( this, this.LoadedFiles, this.Tree );

addLabel( this );
end 

function addLabel( this )
switch length( this.LoadedFiles )
case 0
text = i_getMessage( this.Customization.LabelNoProblem );
case 1
text = i_getMessage( this.Customization.LabelSingleProblem );
otherwise 
text = i_getMessage( this.Customization.LabelMultiProblem, length( this.LoadedFiles ) );
end 

if this.Customization.InfoText ~= ""
this.Label.Text = text + newline + i_getMessage( this.Customization.InfoText );
else 
this.Label.Text = text;
end 
end 

function refreshView( this )
try 
files = this.Provider.getLoadedFiles(  );
filteredFiles = this.Filter( files );

if isa( filteredFiles, "struct" )
updateGroupedTree( this, filteredFiles );
else 
updateFileNodes( this, filteredFiles );
end 

if this.ViewerContainsUnsavedFiles
setButtonText( this, "SaveAllChangesButton", this.Customization.DirtySaveButtonText );
setButtonText( this, "DiscardAllChangesButton", this.Customization.DirtyDiscardButtonText );
else 
setButtonText( this, "SaveAllChangesButton", this.Customization.SaveButtonText );
setButtonText( this, "DiscardAllChangesButton", this.Customization.DiscardButtonText );
end 

if this.Customization.AutoCloseUI && isempty( filteredFiles )
close( this.LoadedFileUIFigure );
end 





catch 
end 
end 

function createTimer( this )
this.Timer = timer;
this.Timer.Period = 5;
this.Timer.ExecutionMode = 'fixedSpacing';
this.Timer.TimerFcn = @( ~, ~ )refreshView( this );
end 

function updateResult = updateLoadedFiles( this, newLoadedFiles )
[ ~, idx ] = sort( [ newLoadedFiles.Path ] );
sortedLoadedFiles = newLoadedFiles( idx );
if length( sortedLoadedFiles ) ~= length( this.LoadedFiles )
this.LoadedFiles = sortedLoadedFiles;
updateResult = true;
return ;
end 

for n = 1:length( sortedLoadedFiles )
if sortedLoadedFiles( n ) ~= this.LoadedFiles( n )
this.LoadedFiles = sortedLoadedFiles;
updateResult = true;
return ;
end 
end 

updateResult = false;
end 

function setButtonsEnabled( this, state )
this.DiscardAllChangesButton.Enable = state;
this.SaveAllChangesButton.Enable = state;
end 

function setButtonText( this, button, text )
if text == ""
this.( button ).Visible = false;
else 
this.( button ).Visible = true;
this.( button ).Text = i_getMessage( text );
end 
end 

function oncleanup = enableProgressIndicator( this )
setProgressIndicator( this, "on" );
oncleanup = onCleanup( @(  )progressBarCleanup( this ) );
end 

function setProgressIndicator( this, state )
this.ProgressIndicator.Visible = state;
drawnow;
end 


function progressBarCleanup( this )
if isvalid( this ) && isvalid( this.ProgressIndicator )
setProgressIndicator( this, "off" );
end 
end 
end 
end 

function value = i_getMessage( resource, varargin )
value = string( message( resource, varargin{ : } ) );
end 

function files = noFilter( files )
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpcWALLL.p.
% Please follow local copyright laws when handling this file.

