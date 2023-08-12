classdef PreprocessingApp < handle





properties ( Constant )


APPCONTAINER_TAG = "preprocessing_app";


HOME_DOCUMENT_GROUP = "defaultGroup";


VARIABLEBROWSER_PANEL_TAG = "variable_browser_panel";
HISTORY_PANEL_TAG = "history_panel";
PANELTAGS_SHOWN_ONLY_HOME = [ "history_panel", "variable_browser_panel" ];
MODE_CONTROLPANEL_TAG_INSPECTOR = "preprocessingModePanel_Inspector";

MODE_TOOLSTRIP_TAG = "preprocessingTaskContextGroup";


STARTUP_LAYOUT_TAG = "startup_layout";
HOME_LAYOUT_TAG = "home_layout";


INSPECTOR_TITLE = getString( message( 'MATLAB:datatools:preprocessing:app:TASK_PANEL_TITLE' ) );
INSPECTOR_PANEL_ROWHEIGHTS = { '1x', 20, 22, 25 };
INSPECTOR_PANEL_COLWIDTHS = { '1x', '1x', 50, 25, 25 };
end 

properties 
AppContainer
ColumnTransformationDialog
end 

properties 

AppToolstrip
HOME_TOOLSTRIP_TAG = "home_toolstrip_tab_group";
ExportConfirmDialog


VariableBrowserPanel


HistoryPanel
ViewHistoryChangedFcn
ViewHistoryRequestedFcn
ViewOpenModeCallbackFcn
HistoryChangedFcn


PlotsDisplay = [ 1, 1 ]


DataModel
CurrentStepIDString


StartupDocument
CurrentTabularDocument
TabularDocuments
TabularInteractionIndex = 0
LastChangeSourceForDoc


InspectorControlPanel
TaskInspector
EditStep = false;


CurrentTask
TaskAddedListener
TaskRemovedListener
TaskModifiedListener

CurrentInsertTask




LastChangeSource

SelectionThrottler
Selection
end 

properties ( Hidden = true )
UsePropertyInspector = true;
AutoRunOn = true;
TableSupportOn = true;
end 

properties ( Dependent, Hidden = true )
SelectedVariable

SelectedTableVariables string = string.empty
end 

methods 

function this = PreprocessingApp(  )
this.setupAppContainer(  );
this.initializeAppLayout(  );
this.setPanelSizes(  );
this.showAppStartupScreen(  );

this.TabularDocuments = containers.Map;
end 

function initializeAppLayout( this )

this.buildToolstrip(  );


this.createTabularViewDocumentGroup(  );
this.createInspectorModePanels(  );


this.createVariableBrowserPanel(  );
this.createHistoryPanel(  );


this.createAppDataModel(  );


this.makeAppVisible(  );
addlistener( this.AppContainer, 'StateChanged', @( app, ~ )this.setPanelStates( app ) );

this.disableAppInterations;
end 

function setupAppContainer( this )
import matlab.ui.container.internal.AppContainer;
import matlab.ui.container.internal.appcontainer.*;
import matlab.ui.internal.*;


appOptions.Tag = this.APPCONTAINER_TAG;
appOptions.Title = getString( message( 'MATLAB:datatools:preprocessing:app:Tool_dataCleaner_Label' ) );
appOptions.ShowSingleDocumentTab = false;


appOptions.WindowBounds = getScreenCenterLocation(  );
appOptions.Product = "MATLAB";
appOptions.Scope = "Data Cleaner";





this.AppContainer = AppContainer( appOptions );
this.setPanelSizes(  );

this.AppContainer.CanCloseFcn = @( ~ )this.closeAndDelete;
end 

function setPanelStates( this, app )
if strcmp( app.State, 'RUNNING' )
app.ActiveContexts = [ this.STARTUP_LAYOUT_TAG ];
this.InspectorControlPanel.Opened = false;
end 
end 

function showAppStartupScreen( this )
import matlab.ui.internal.FigureDocument;
import matlab.internal.preprocessingApp.images.*;

docOptions.Title = 'StartupScreen';
docOptions.Tag = 'StartupScreen';
docOptions.DocumentGroupTag = "defaultGroup";
this.StartupDocument = FigureDocument( docOptions );

gridlayout = uigridlayout( this.StartupDocument.Figure, [ 1, 1 ] );
gridlayout.ColumnWidth = { '1x' };
gridlayout.RowHeight = { '1x' };

u = uilabel( gridlayout );
u.Text = getString( message( 'MATLAB:datatools:preprocessing:app:IMPORT_START_SCREEN' ) );
u.HorizontalAlignment = 'center';
u.FontColor = [ 0.56, 0.54, 0.54 ];
u.FontSize = 18;

this.AppContainer.add( this.StartupDocument );
end 

function buildToolstrip( this )
import matlab.internal.preprocessingApp.toolstrip.*;
import matlab.internal.preprocessingApp.tasks.*;



atf = AppTaskFactory.getInstance;
galleryTasks = atf.PreprocessingLiveTasks;
this.AppToolstrip = Toolstrip( this.HOME_TOOLSTRIP_TAG, this.MODE_TOOLSTRIP_TAG, galleryTasks );


items = this.AppToolstrip.PreprocessingGalleryItems.keys;
for i = 1:length( items )
this.addCallbackGalleryItem( this.AppToolstrip.PreprocessingGalleryItems( items{ i } ),  ...
galleryTasks( i ) );
end 






this.addImportCallbacks(  );
this.addSummaryCallbacks(  );
this.addLegendCallbacks(  );
this.addToolbarCallbacks(  );
this.addExportCallbacks(  );

this.AppToolstrip.FeedbackButton.ButtonPushedFcn = @( es, ed )this.sendFeedback;



this.AppToolstrip.QuickAccessBar.ButtonPushedFcn = @( ~, d )this.openPPModeHelp(  );
this.AppContainer.add( this.AppToolstrip.QuickAccessBar );


this.AppToolstrip.AddCustomFunctionButton.ItemPushedFcn = @( ~, ~ )this.openCustomPPDialog;
this.AppToolstrip.EditCustomFunctionButton.ItemPushedFcn = @( ~, ~ )this.openEditCustomPPDialog;


this.TaskAddedListener = addlistener( atf, 'TaskAdded', @( ~, ed )this.taskAdded( ed.Task ) );
this.TaskRemovedListener = addlistener( atf, 'TaskRemoved', @( ~, ed )this.taskRemoved( ed.Task ) );
this.TaskModifiedListener = addlistener( atf, 'TaskModified', @( ~, ed )this.taskModified( ed.Task ) );


this.AppContainer.add( this.AppToolstrip.HomeTabGroup );
end 

function createVariableBrowserPanel( this )
import matlab.internal.preprocessingApp.variableBrowser.*;


panelOptions.Title = getString( message( 'MATLAB:datatools:preprocessing:app:VARIABLE_PANEL_TITLE' ) );
panelOptions.Region = "left";
panelOptions.ParentSize = this.AppContainer.WindowBounds;
panelOptions.Tag = this.VARIABLEBROWSER_PANEL_TAG;
this.VariableBrowserPanel = VariableBrowserPanel( panelOptions );
this.VariableBrowserPanel.Contextual = false;
this.VariableBrowserPanel.Index = 1;
this.VariableBrowserPanel.VariablePanelSelectionChangedFcn = @( srcObject, eventData )this.handleClientSelectionChanged( srcObject, eventData );
this.VariableBrowserPanel.VariablePanelUserInteractionCallFcn = @( codeObj )this.updateAppAfterUserInteractions( codeObj );
end 

function createHistoryPanel( this )
import matlab.internal.preprocessingApp.history.*;


panelOptions.Title = getString( message( 'MATLAB:datatools:preprocessing:app:HISTORY_PANEL_TITLE' ) );
panelOptions.Region = "right";
panelOptions.ParentSize = this.AppContainer.WindowBounds;
panelOptions.Tag = this.HISTORY_PANEL_TAG;
this.HistoryPanel = HistoryPanel( panelOptions );
this.HistoryPanel.Contextual = false;
this.HistoryPanel.Index = 1;
this.HistoryPanel.ViewHistoryChangedFcn = @( steps )this.historyChanged( steps );
this.HistoryPanel.ViewHistoryRequestedFcn = @( msg )this.historyRequested(  );
this.HistoryPanel.ViewOpenModeCallbackFcn = @( data )this.openModeFromHistory( data );
this.HistoryPanel.ViewDeleteStepCallbackFcn = @( data )this.deleteStep( data );
this.HistoryPanel.ViewInsertCallbackFcn = @( type, step, task )this.insertStep( type, step, task );
end 

function createAppDataModel( this )
this.DataModel = matlab.internal.preprocessingApp.state.PreprocessingDataModel(  );


this.DataModel.StateChangedFcn = @( t, v )this.notifyDataChanged(  );
end 

function createTabularViewDocumentGroup( this )
import matlab.ui.container.internal.AppContainer;
import matlab.ui.container.internal.appcontainer.*;
import matlab.ui.internal.*;

if ~this.AppContainer.hasDocumentGroup( this.HOME_DOCUMENT_GROUP )

homeGroupOptions.Tag = "defaultGroup";
homeGroupOptions.Title = getString( message( 'MATLAB:datatools:preprocessing:app:TABULAR_DOC_GROUP_TITLE' ) );

homeGroup = FigureDocumentGroup( homeGroupOptions );
homeGroup.Title = getString( message( 'MATLAB:datatools:preprocessing:app:TABULAR_DOC_GROUP_TITLE' ) );
this.AppContainer.add( homeGroup );
end 
end 

function taskAdded( this, task )
this.AppToolstrip.addGalleryItem( task );
currentItem = this.getItemFromGallery( task.Name );
this.addCallbackGalleryItem( currentItem, task );
this.setTasksInHistory;
end 

function taskRemoved( this, task )
this.AppToolstrip.removeGalleryItem( task );
end 

function taskModified( this, task )
this.taskRemoved( task.PreviousTaskData );
this.taskAdded( task );
end 

function setPanelSizes( this )
appSize = this.AppContainer.WindowBounds;
leftPanelWidth = round( ( 1 / 6 ) * appSize( 3 ) );
rightPanelWidth = round( ( 1 / 5 ) * appSize( 3 ) );
this.AppContainer.RightWidth = rightPanelWidth;
this.AppContainer.LeftWidth = leftPanelWidth;
end 

function disableAppInterations( this )
this.HistoryPanel.disableUpdateInteractions(  );
this.setEnabledState( false );
end 

function enableAppInterations( this )
this.HistoryPanel.enableUpdateInteractions(  );
this.setEnabledState( true );
end 

function setEnabledState( this, state )
this.AppToolstrip.State = state;
end 

function makeAppVisible( this )
this.AppContainer.Visible = true;
end 

function addCallbackGalleryItem( this, item, task )
item.ItemPushedFcn =  ...
@( ~, ~ )this.openTask(  ...
task ...
, this.DataModel.CurrentWorkspace ...
, this.Selection.SelectedVariable ...
, this.Selection.SelectedTableVariables );
end 

function createInspectorModePanels( this )

panelOptions.Title = getString( message( 'MATLAB:datatools:preprocessing:app:TASK_PANEL_TITLE' ) );
panelOptions.Region = "right";
panelOptions.Tag = this.MODE_CONTROLPANEL_TAG_INSPECTOR;
panelOptions.ParentSize = this.AppContainer.WindowBounds;
this.InspectorControlPanel =  ...
matlab.internal.preprocessingApp.tasks.InspectorTaskPanel( panelOptions );
this.InspectorControlPanel.Index = 2;
appSize = this.AppContainer.WindowBounds;
this.InspectorControlPanel.PreferredHeight = 3 / 5 * ( appSize( 4 ) );
this.InspectorControlPanel.Opened = false;
grid = uigridlayout( this.InspectorControlPanel.Figure, [ 4, 3 ],  ...
'padding', [ 8, 3, 8, 3 ], 'backgroundColor', [ 0.9400, 0.9400, 0.9400, 0.9400 ] );
grid.RowHeight = this.INSPECTOR_PANEL_ROWHEIGHTS;
grid.ColumnWidth = this.INSPECTOR_PANEL_COLWIDTHS;
this.TaskInspector = matlab.internal.datatools.uicomponents.uiinspector.UIInspector( 'Parent', grid,  ...
'Tag', 'DataCleanerTaskPanel', 'ShowInspectorToolstrip', false );
this.TaskInspector.Layout.Row = 1;
this.TaskInspector.Layout.Column = [ 1, 5 ];
end 

function resetToDefault( this, ~ )
this.InspectorControlPanel.Collapsed = true;
this.InspectorControlPanel.Title = this.INSPECTOR_TITLE;

newData = this.DataModel.CurrentWorkspace.( this.SelectedVariable );

selectionInstersection =  ...
intersect( this.Selection.SelectedTableVariables, getTableVariables( newData ) );
this.Selection.setSelection( struct( 'SelectedVariable', this.SelectedVariable,  ...
'SelectedTableVariables', selectionInstersection,  ...
'LastChangeSource', [  ] ), false );


this.CurrentTabularDocument.VizScript = [  ];
this.CurrentTabularDocument.TableView.PlotDirty = true;
this.CurrentTabularDocument.Data = newData;

this.VariableBrowserPanel.setSelection(  ...
struct( 'Variable', { string( this.Selection.SelectedVariable ) },  ...
'Columns', string( this.Selection.SelectedTableVariables ) ) );
this.VariableBrowserPanel.hideDisableLabel(  );


if ~isempty( this.CurrentTask )
this.TaskInspector = this.CurrentTask.TaskInspector;
this.AutoRunOn = this.CurrentTask.AutoRunOn;
end 
this.CurrentTask = [  ];
this.CurrentStepIDString = [  ];

this.HistoryPanel.setSelection( [  ] );
end 



function value = get.SelectedVariable( this )
value = [  ];
if ~isempty( fieldnames( this.VariableBrowserPanel.SelectedVariables ) )
value = this.VariableBrowserPanel.SelectedVariables.Variable;
end 
end 

function value = get.SelectedTableVariables( this )
value = [  ];
if ~isempty( fieldnames( this.VariableBrowserPanel.SelectedVariables ) )
value = this.VariableBrowserPanel.SelectedVariables.Columns;
end 
end 


function addImportCallbacks( this )
this.AppToolstrip.getImportWorkspaceButton.ItemPushedFcn = @( ~, ~ )this.importVariable;
this.AppToolstrip.getImportFileButton.ItemPushedFcn = @( ~, ~ )this.importFromFile;
end 

function addSummaryCallbacks( this )
this.AppToolstrip.SummaryButton.ValueChangedFcn = @( ~, ~ )this.toggleSummaryVisibility;
end 

function addLegendCallbacks( this )
this.AppToolstrip.LegendButton.ValueChangedFcn = @( ~, ~ )this.toggleLegendVisibility;
end 

function addToolbarCallbacks( this )
this.AppToolstrip.AxToolBarButton.ValueChangedFcn = @( ~, ~ )this.toggleAxToolbarVisibility;
end 

function addExportCallbacks( this )
this.AppToolstrip.ExportButton.ButtonPushedFcn = @( ~, ~ )this.exportData;
this.AppToolstrip.getExportWorkspaceButton.ItemPushedFcn = @( ~, ~ )this.exportData;
this.AppToolstrip.getExportScriptButton.ItemPushedFcn = @( ~, ~ )this.exportScript;
this.AppToolstrip.getExportFunctionButton.ItemPushedFcn = @( ~, ~ )this.exportFunction;
end 

function toggleSummaryVisibility( this )
if this.AppToolstrip.SummaryButton.Value
this.CurrentTabularDocument.TableView.Plots.showAnnotations(  );
else 
this.CurrentTabularDocument.TableView.Plots.hideAnnotations(  );
end 
end 

function toggleLegendVisibility( this )
if this.AppToolstrip.LegendButton.Value
this.CurrentTabularDocument.TableView.Plots.showLegends(  );
else 
this.CurrentTabularDocument.TableView.Plots.hideLegends(  );
end 
end 

function toggleAxToolbarVisibility( this )
if this.AppToolstrip.AxToolBarButton.Value
this.CurrentTabularDocument.TableView.Plots.showAxToolbar(  );
else 
this.CurrentTabularDocument.TableView.Plots.hideAxToolbar(  );
end 
end 

function openPPModeHelp( ~ )
helpview( fullfile( docroot, 'matlab', 'ref/datacleaner-app.html' ) );
end 

function importFromFile( this )
[ file, path ] = uigetfile( { '*.xls;*.xlsx;*.txt;*.csv', 'Text or Spreadsheet Files';'*.xls;*.xlsx', 'Spreadsheet Files';'*.txt;*.csv', 'Text Files' } );


this.AppContainer.bringToFront;


if isempty( file ) || isequal( file, 0 )
return ;
end 

if endsWith( file, ".xls", 'IgnoreCase', true ) || endsWith( file, ".xlsx", 'IgnoreCase', true )
type = 'spreadsheet';
else 
type = 'text';
end 
try 
internal.matlab.importtool.peer.uiimportFile( fullfile( path, file ),  ...
'ImportType', type,  ...
'SupportedOutputTypes', [ "table", "timetable" ],  ...
"SupportedOutputActions", "importdata",  ...
"AppName", "ppApp",  ...
'DataImportedFcn', @this.DataImportedCallback,  ...
'CloseOnImport', true );
catch ex
if startsWith( ex.identifier, "MATLAB:codetools" )


uiconfirm( this.AppContainer, ex.message, getString( message( "MATLAB:codetools:uiimport:ErrorTitle" ) ),  ...
"Icon", "error", "Options", getString( message( 'MATLAB:datatools:preprocessing:app:OK_BUTTON_TEXT' ) ) );
else 


rethrow( ex )
end 
end 
end 

function importRecipe( this )
[ file, path ] = uigetfile( '*.json' );
if isfile( [ path, file ] )
stepList = jsondecode( fileread( [ path, file ] ) );
end 

for i = 1:length( stepList )
try 
tName = stepList( i ).VariableName;
tVarName = stepList( i ).TableVariableName;
if iscell( tVarName )
tVarName = tVarName{ : };
end 
[ result ] = evalin( this.DataModel.CurrentWorkspace, [ tName, tVarName ] );
this.DataModel.addCodeAt(  ...
'Code', stepList( i ).Code ...
, 'DisplayName', stepList( i ).DisplayName ...
, 'VariableName', stepList( i ).VariableName ...
, 'TableVariableName', stepList( i ).TableVariableName );
catch e
errorTitle = getString( message( 'MATLAB:datatools:preprocessing:app:USR_ACTION_ERROR_TITLE' ) );
if isempty( tVarName )
errorMsg = getString( message( 'MATLAB:datatools:preprocessing:app:IMPORT_RECIPE_MISSING_TABLE', i, tName ) );
else 
errorMsg = getString( message( 'MATLAB:datatools:preprocessing:app:IMPORT_RECIPE_MISSING_TABLE_WITH_VAR', i, tName, tVarName ) );
end 
uialert( this.AppContainer, errorMsg, errorTitle );
break ;
end 
end 
end 

function importButton_Callback( this )
persistent check


if isempty( check )
check = 1;

this.importVariable;



else 


return 
end 


check = [  ];
end 

function DataImportedCallback( this, event )
varData = { event.vars{ 1 } };
if ~isempty( varData )
this.loadData( event.varNames, varData );
end 
end 






function importVariable( this )
if ~this.isSupportedVarsInWorkspace(  )
uialert( this.AppContainer,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:NO_VAR_WARNING' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:NO_VAR_WARNING_TITLE' ) ) );
else 
importDataSelector = this.getImportDataSelector(  );
this.centerUIToApp( importDataSelector );
selectedVarNames = importDataSelector.import(  );
this.AppContainer.bringToFront;
if ~isempty( selectedVarNames )
if ~isempty( this.CurrentTabularDocument )
this.appResetWarningDialog( selectedVarNames );
else 
this.loadData( selectedVarNames, [  ] );
end 
end 
end 
end 

function answer = appDataTooLargeWarningDialog( this )


this.AppContainer.bringToFront;
answer = uiconfirm( this.AppContainer,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_TEXT' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_TITLE' ) ),  ...
'Options', { getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_OK' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_CANCEL' ) ) },  ...
'CancelOption', 2,  ...
'DefaultOption', 2 );
end 

function answer = appContainsGroupedColumnsWarningDialog( this )



this.AppContainer.bringToFront;
answer = uiconfirm( this.AppContainer,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:DATA_GROUPEDCOLUMNS_WARNING_TEXT' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_TITLE' ) ),  ...
'Options', { getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_OK' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_CANCEL' ) ) },  ...
'CancelOption', 2,  ...
'DefaultOption', 2 );
end 

function answer = appContainsUnsupportedColumnsWarningDialog( this, className )



this.AppContainer.bringToFront;
answer = uiconfirm( this.AppContainer,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:DATA_UNSUPPORTEDCOLUMNS_WARNING_TEXT', className ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_TITLE' ) ),  ...
'Options', { getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_OK' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:DATA_LARGE_WARNING_CANCEL' ) ) },  ...
'CancelOption', 2,  ...
'DefaultOption', 2 );
end 

function answer = appResetWarningDialog( this, selectedVarNames )


this.AppContainer.bringToFront;
answer = uiconfirm( this.AppContainer,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:STEP_RESET_WARNING_TEXT' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:STEP_RESET_WARNING_PANEL_TITLE' ) ),  ...
'Options', { getString( message( 'MATLAB:datatools:preprocessing:app:STEP_RESET_WARNING_OK' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:STEP_RESET_WARNING_CANCEL' ) ) },  ...
'CancelOption', 2,  ...
'DefaultOption', 2 );

switch answer
case getString( message( 'MATLAB:datatools:preprocessing:app:STEP_RESET_WARNING_OK' ) )
this.AppContainer.bringToFront;
this.loadData( selectedVarNames, [  ] );
case getString( message( 'MATLAB:datatools:preprocessing:app:STEP_RESET_WARNING_CANCEL' ) )
this.AppContainer.bringToFront;
return ;
end 
end 




function load( this, variableNames )
this.loadData( variableNames, [  ] );
end 




function loadData( this, variableNames, variableData )
R36
this
variableNames( 1, : )string
variableData
end 

if ~isempty( this.CurrentTabularDocument )
this.resetAppState(  );
else 
sd = this.AppContainer.getDocument( 'defaultGroup', 'StartupScreen' );
if ~isempty( sd )
sd.Visible = true;
this.AppContainer.closeDocument( "defaultGroup", "StartupScreen", true );
end 
end 


try 
if isempty( variableData ) && ~isempty( variableNames )
variableData = cell( 1, length( variableNames ) );
for i = 1:length( variableNames )
variableData{ i } = evalin( 'base', variableNames( i ) );
end 
end 
catch ME
warning( getString( message( 'MATLAB:datatools:preprocessing:app:STEP_RESET_WARNING_TEXT' ) ) );
end 

if isSizeGreaterThanLimit( variableData{ 1 } )

response = this.appDataTooLargeWarningDialog(  );
if strcmp( response,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:STEP_RESET_WARNING_CANCEL' ) ) )
this.closeAndDelete(  );
return ;
else 
this.AutoRunOn = false;
end 
end 

[ isUnsupported, unsupportedType, unsupportedClass, unsupportedVariables ] = containsUnsupportedColumns( variableData{ 1 } );
if isUnsupported

switch unsupportedType
case 'GroupedColumns'
response = this.appContainsGroupedColumnsWarningDialog(  );
otherwise 
response = this.appContainsUnsupportedColumnsWarningDialog( unsupportedClass );
end 
if strcmp( response,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:STEP_RESET_WARNING_CANCEL' ) ) )
this.closeAndDelete(  );
return ;
end 
variableData{ 1 } = removevars( variableData{ 1 }, unsupportedVariables );
end 

this.AppContainer.bringToFront;
this.initializeAppWithData( variableData, variableNames );




this.updateCleaningTasksList( variableData{ 1 } );
this.AppToolstrip.SummaryButton.Value = true;
this.AppToolstrip.LegendButton.Value = true;
end 

function resetAppState( this )
if ~isempty( this.CurrentTask )
this.CurrentTask.clearInspector( [  ], [  ], false );
end 
this.resetToDefault(  );

delete( this.DataModel );
this.VariableBrowserPanel.removeData( this.SelectedVariable );
this.VariableBrowserPanel.Interactive = 1;

this.closeTabularDocument(  );
this.createAppDataModel(  );
end 


function initializeVariableBrowser( this, varData, variableNames )
R36
this
varData( 1, : )cell
variableNames( 1, : )string
end 

for i = 1:length( variableNames )
this.VariableBrowserPanel.addData( varData{ i }, variableNames( i ) );
end 
end 

function refreshVariableBrowser( this )


workspace = this.DataModel.CurrentWorkspace;
workspaceProps = fieldnames( workspace.getVariables );
if isempty( workspace.( this.SelectedVariable ) )
this.VariableBrowserPanel.removeData( this.SelectedVariable );
return ;
end 

for i = 1:length( workspaceProps )
this.VariableBrowserPanel.removeData( workspaceProps{ i } );
this.VariableBrowserPanel.addData( workspace.( workspaceProps{ i } ), workspaceProps{ i } );
end 


if ~isempty( this.CurrentTabularDocument )
this.VariableBrowserPanel.setSelection(  ...
struct( 'Variable', { string( this.Selection.SelectedVariable ) },  ...
'Columns', string( this.Selection.SelectedTableVariables ) ) );
end 
end 


function openSelectedVariables( this )
import matlab.ui.container.internal.AppContainer;
import matlab.ui.container.internal.appcontainer.*;
import matlab.ui.internal.*;


data = evalin( this.DataModel.CurrentWorkspace, this.SelectedVariable );

if ~isempty( this.AppContainer.getDocument( "defaultGroup", this.SelectedVariable ) )
this.AppContainer.SelectedChild = struct( 'title', this.SelectedVariable,  ...
'tag', this.SelectedVariable,  ...
'documentGroupTag', "defaultGroup" );
this.CurrentTabularDocument = this.AppContainer.getDocument( "defaultGroup", this.SelectedVariable );
else 

this.CurrentTabularDocument = this.createTabularDocument( this.SelectedVariable, data );
this.CurrentTabularDocument.Closable = false;
this.AppContainer.add( this.CurrentTabularDocument );
end 

this.CurrentTabularDocument.VariableSelectionChangedFcn =  ...
@( srcObject, eventData )this.handleClientSelectionChanged( srcObject, eventData );

this.CurrentTabularDocument.DocumentDataChangedFcn = @( data )this.documentDataChanged( data );

this.enableAppInterations;
end 

function tabularDocument = createTabularDocument( this, varName, varData )
docOptions.Title = getString( message( 'MATLAB:datatools:preprocessing:app:TABULAR_DOC_TITLE', varName ) );
docOptions.Tag = varName;
docOptions.DocumentGroupTag = "defaultGroup";
tabularDocument = matlab.internal.preprocessingApp.tabular.TabularVariableDocument ...
( docOptions );
tabularDocument.VariableName = varName;
tabularDocument.Workspace = this.DataModel.CurrentWorkspace.clone;
tabularDocument.Data = varData;
this.AppContainer.DocumentTabPosition = "bottom";
end 



function initializeAppWithData( this, varData, variableNames )
R36
this
varData( 1, : )cell
variableNames( 1, : )string
end 

this.AppContainer.Busy = true;
if ~isempty( varData )
for i = 1:length( variableNames )
this.DataModel.CurrentWorkspace.assignin( variableNames( i ), varData{ i } );
this.DataModel.OriginalWorkspace.assignin( variableNames( i ), varData{ i } );
end 

this.AppContainer.ActiveContexts = [ this.HOME_LAYOUT_TAG ];
this.addPanels(  );

this.initializeVariableBrowser( varData, variableNames );
drawnow nocallbacks;
this.Selection = matlab.internal.preprocessingApp.selection.Selection.getInstance(  );
this.Selection.setSelection( struct( 'SelectedVariable', variableNames,  ...
'SelectedTableVariables', getDefaultTableVariable( varData{ 1 } ),  ...
'LastChangeSource', this.VariableBrowserPanel ), false );
this.openSelectedVariables(  );
this.HistoryPanel.Index = 1;
this.InspectorControlPanel.Index = 2;
drawnow nocallbacks;
this.VariableBrowserPanel.setSelection(  ...
struct( 'Variable', variableNames,  ...
'Columns', getDefaultTableVariable( varData{ 1 } ) ) );
end 

this.InspectorControlPanel.Collapsed = true;
this.AppContainer.bringToFront;
this.AppContainer.Busy = false;
end 

function addPanels( this )
if ~this.AppContainer.hasPanel( this.InspectorControlPanel.Tag )
this.AppContainer.addPanel( this.InspectorControlPanel );
this.InspectorControlPanel.Opened = true;
end 

if ~this.AppContainer.hasPanel( this.HistoryPanel.Tag )
this.AppContainer.addPanel( this.HistoryPanel );
end 

if ~this.AppContainer.hasPanel( this.VariableBrowserPanel.Tag )
this.AppContainer.addPanel( this.VariableBrowserPanel );
end 
end 

function historyChanged( this, steps )
this.AppContainer.Busy = true;
this.EditStep = false;
this.LastChangeSource = this.HistoryPanel;

this.setDataModelSteps( steps );

this.AppContainer.Busy = false;
end 

function openModeFromHistory( this, data )
this.LastChangeSource = this.HistoryPanel;
currentStep = data.currentStep;
if ~isempty( currentStep.OperationType ) &&  ...
isNonEditableOperation( currentStep.OperationType )
return ;
end 

steps = data.steps;

currentStepIndex = this.DataModel.getIndexWithID( string( currentStep.ID ) );
if currentStepIndex > 1
workspace = this.DataModel.getWorkspaceAt( currentStepIndex - 1 );
else 
workspace = this.DataModel.getWorkspaceAt( 0 );
end 




state = this.DataModel.getStateWithStepID( string( currentStep.ID ) );
currStepIndex = this.DataModel.getIndexWithID( currentStep.ID );
if ~isequal( steps( currStepIndex ).Enabled,  ...
this.DataModel.Steps( currStepIndex ).Enabled )
this.setDataModelSteps( steps );
end 


this.EditStep = true;
this.openTask( struct(  ), workspace, string( this.Selection.SelectedVariable ),  ...
string( this.Selection.SelectedTableVariables ), state );


if steps( currStepIndex ).Enabled
this.CurrentTask.enableView(  );
else 
this.CurrentTask.disableView(  );
end 

this.AppContainer.Busy = false;
end 

function historyRequested( this )
if ~isempty( this.DataModel.Steps )
this.HistoryPanel.setHistory( this.DataModel.Steps );
end 
this.setTasksInHistory;
end 

function setTasksInHistory( this )
import matlab.internal.preprocessingApp.tasks.*;
atf = AppTaskFactory.getInstance;
galleryTasks = atf.PreprocessingLiveTasks;
this.HistoryPanel.setTasks( [ galleryTasks.Name ] );
end 

function deleteStep( this, data )
step = data.currentStep;
newSteps = data.steps;

this.LastChangeSource = this.HistoryPanel;



stepIndex = this.DataModel.getIndexWithID( string( step.ID ) );

if ~isempty( this.CurrentTask ) && ~isempty( this.CurrentStepIDString )
currentStepIndex = this.DataModel.getIndexWithID( string( this.CurrentStepIDString ) );
if isequal( stepIndex, currentStepIndex )

this.CurrentTask.clearInspector( [  ], [  ], false );
end 
end 



this.DataModel.Steps = newSteps;

end 

function insertStep( this, type, step, task )
import matlab.internal.preprocessingApp.tasks.*;

stepIndex = this.DataModel.getIndexWithID( string( step.ID ) );
atf = AppTaskFactory.getInstance;
galleryTasks = atf.PreprocessingLiveTasks;
taskIndex = find( strcmp( [ galleryTasks.Name ], task ) );
state = struct(  );
state.Task = galleryTasks( taskIndex );
state.Name = task;
state.Path = galleryTasks( taskIndex ).Path;


if stepIndex == 1 && strcmp( type, 'above' )
workspace = this.DataModel.getWorkspaceAt( 0 );
else 
if strcmp( type, 'below' )
workspace = this.DataModel.getWorkspaceAt( stepIndex );
else 
workspace = this.DataModel.getWorkspaceAt( stepIndex - 1 );
end 
end 

if strcmp( type, 'below' )
stepIndex = stepIndex + 1;
end 
this.DataModel.addCodeAt( "StepIndex", stepIndex, "Code", "" );
state.stepID = "" + this.DataModel.Steps( stepIndex ).ID;

this.CurrentInsertTask = stepIndex;
this.openTask( galleryTasks( taskIndex ), workspace, this.SelectedVariable, this.SelectedTableVariable, state );

end 

function notifyDataChanged( this )
this.updateSelectionOnDateChange(  );


if ~isequal( this.LastChangeSource, this.HistoryPanel )
this.HistoryPanel.setHistory( this.DataModel.Steps );
end 
if ~isempty( this.CurrentTask )
this.enableAppInterations(  );
end 


if ~isequal( this.LastChangeSource, this.VariableBrowserPanel )
this.refreshVariableBrowser(  );
end 




if ~isempty( this.CurrentTask )
if isempty( this.CurrentStepIDString ) ||  ...
this.isCurrentStepEnabled(  )
this.CurrentTask.enableView(  );
else 
this.CurrentTask.disableView(  );
end 
end 
this.CurrentTabularDocument.VizScript = [  ];
this.CurrentTabularDocument.Data =  ...
this.DataModel.CurrentWorkspace.( this.SelectedVariable );

this.LastChangeSource = [  ];
this.enableAppInterations(  );
end 

function isEnabled = isCurrentStepEnabled( this )
isEnabled = false;
index = this.DataModel.getIndexWithID( this.CurrentStepIDString );
if ~isempty( index )
isEnabled = this.DataModel.Steps( index ).Enabled;
end 
end 

function updateSelectionOnDateChange( this )
validSelectedVariables = intersect( getTableVariables( this.DataModel. ...
CurrentWorkspace.( this.SelectedVariable ) ),  ...
this.Selection.SelectedTableVariables );

selection = struct(  );
selection.SelectedVariable = this.SelectedVariable;
selection.LastChangeSource = [  ];


selection.SelectedTableVariables = validSelectedVariables;

this.Selection.setSelection( selection, false );
end 

function setDataModelSteps( this, steps )
oldSteps = this.DataModel.Steps;
try 
this.DataModel.Steps = steps;
catch e
errorTitle = getString( message( 'MATLAB:datatools:preprocessing:app:USR_ACTION_ERROR_TITLE' ) );
errorMsg = sprintf( 'History Error: %s \nReverting user action', e.message );
uialert( this.AppContainer, errorMsg, errorTitle );
this.LastChangeSource = [  ];
this.DataModel.Steps = oldSteps;
end 
end 

function updateCleaningSteps( this, addNewCodeLine )
currentTaskName = this.CurrentTask.Task.Name;
currentTaskCode = this.CurrentTask.Code;
currentTaskSummary = this.CurrentTask.Summary;
currentTaskVariable = this.CurrentTask.VariableName;
currentTaskTableVariableName = this.CurrentTask.TableVariableName;
currentTaskState = this.CurrentTask.State;
currentTaskState.Name = currentTaskName;
currentTaskState.Path = this.CurrentTask.Task.Path;
currentTaskState.Task = this.CurrentTask.Task;
currentTaskUI = this.CurrentTask.TaskUI;
currentStep = this.CurrentStepIDString;
currentVizScript = this.CurrentTask.VizScript;

this.disableAppInterations(  );

taskDescription = getTaskDescription( currentTaskName,  ...
currentTaskTableVariableName,  ...
currentTaskVariable );

if isa( currentTaskUI, 'matlab.internal.preprocessingApp.tasks.CustomCodeTask' )
taskDescription = currentTaskSummary +  ...
": " + currentTaskVariable + currentTaskTableVariableName;
end 

this.AppContainer.Busy = true;
if ~isempty( currentStep ) || ~addNewCodeLine
stepIndex = this.DataModel.getIndexWithID( currentStep );
this.DataModel.replaceCodeAt(  ...
'Code', string( strrep( strjoin( currentTaskCode, sprintf( ";\n" ) ), ";;", ";" ) ) ...
, 'DisplayName', taskDescription ...
, 'VariableName', currentTaskVariable ...
, 'TableVariableName', currentTaskTableVariableName ...
, 'StepIndex', stepIndex );

currentTaskState.stepID = currentStep;
this.DataModel.updateStateMap( currentStep, currentTaskState );
else 
this.DataModel.addCodeAt(  ...
'Code', string( strrep( strjoin( currentTaskCode, sprintf( ";\n" ) ), ";;", ";" ) ) ...
, 'DisplayName', taskDescription ...
, 'VariableName', currentTaskVariable ...
, 'TableVariableName', currentTaskTableVariableName );

currentTaskState.stepID = string( this.DataModel.Steps( end  ).ID );
this.DataModel.updateStateMap( string( this.DataModel.Steps( end  ).ID ), currentTaskState );



this.TabularInteractionIndex = length( this.DataModel.Steps );
this.CurrentStepIDString = string( this.DataModel.Steps( this.TabularInteractionIndex ).ID );
end 
this.AppContainer.Busy = false;
end 

function updateWithTaskPreview( this, varName, vizScript, workspace )
if isempty( varName )
varName = this.SelectedVariable;
end 



if isempty( this.CurrentStepIDString ) || this.isCurrentStepLastEnabled(  )
this.CurrentTabularDocument.VizScript = vizScript;
this.CurrentTabularDocument.TableView.PlotDirty = true;


this.CurrentTabularDocument.Data = workspace.( varName );
else 


this.CurrentTabularDocument.VizScript = [  ];
if isequal( this.LastChangeSource, this.CurrentTask )
if isfield( workspace.getVariables, 'newTable' )
data = workspace.( 'newTable' );
assignin( workspace, this.Selection.SelectedVariable, data );
end 

currIndex = this.DataModel.getIndexWithID( this.CurrentStepIDString );
for i = currIndex + 1:length( this.DataModel.Steps )
this.DataModel.evalCodeAtStep( i, workspace );
end 
this.CurrentTabularDocument.Data =  ...
workspace.( this.Selection.SelectedVariable );
else 
this.CurrentTabularDocument.Data =  ...
this.DataModel.CurrentWorkspace.( this.Selection.SelectedVariable );
end 
end 
end 

function result = isCurrentStepLastEnabled( this )
result = false;
if ~isempty( this.CurrentStepIDString )
currStepIndex = this.DataModel.getIndexWithID( this.CurrentStepIDString );
result = isequal( currStepIndex, getLastEnabledStepIndex( this.DataModel.Steps ) );
end 
end 



function documentDataChanged( this, eventData )
try 
if ~isempty( this.DataModel.Steps ) &&  ...
strcmp( this.DataModel.Steps( end  ).OperationType, 'Sort' )
stepIndex = this.DataModel.getIndexWithID( this.DataModel.Steps( end  ).ID );
this.DataModel.replaceCodeAt(  ...
'Code', eventData.Code{ 1 } ...
, 'DisplayName', eventData.Code{ 1 } ...
, 'VariableName', 'Foo' ...
, 'TableVariableName', 'Bar' ...
, 'OperationType', "Sort" ...
, 'StepIndex', stepIndex );
else 
this.DataModel.addCodeAt(  ...
'Code', eventData.Code{ 1 } ...
, 'DisplayName', eventData.Code{ 1 } ...
, 'VariableName', 'Foo' ...
, 'TableVariableName', 'Bar' ...
, 'OperationType', "Sort" );
end 
catch e
disp( e );
end 

this.LastChangeSource = this.CurrentTabularDocument;
end 

function updateAppAfterUserInteractions( this, data )
if data.error
errorTitle = getString( message( 'MATLAB:datatools:preprocessing:app:USR_ACTION_ERROR_TITLE' ) );
errorText = getString( message( 'MATLAB:datatools:preprocessing:app:USR_ACTION_ERROR_TEXT' ) );
uialert( this.AppContainer, errorText, errorTitle );
return ;
end 

val = data.codeObj;
this.DataModel.addCodeAt(  ...
'Code', val.Code ...
, 'DisplayName', val.DisplayName ...
, 'VariableName', val.VariableName ...
, 'TableVariableName', join( val.TableVariableName ) ...
, 'OperationType', "NonEditable" );
end 


function handleClientSelectionChanged( this, srcObj, selection )
selection.LastChangedSrc = srcObj;
selObj = struct( 'SelectedVariable', selection.Variable, 'SelectedTableVariables',  ...
selection.Columns, 'LastChangedSrc', srcObj );
this.Selection.setSelection( selObj, true );
end 








function openTask( this, task, workspace, variableName, tableVariableName, state )
R36
this
task( 1, 1 )struct
workspace( 1, 1 )matlab.internal.datatoolsservices.AppWorkspace
variableName string = string.empty
tableVariableName string = string.empty
state( 1, 1 )struct = struct(  )
end 
data = this.DataModel.CurrentWorkspace.( this.Selection.SelectedVariable );
if isempty( fieldnames( task ) ) && ~isempty( fieldnames( state ) )
task = state.Task;
end 

if isempty( fieldnames( state ) )
this.EditStep = false;

[ isValid, msg ] = matlab.internal.preprocessingApp.isCleaningValid( task, data, tableVariableName );
if ~isValid
uialert( this.CurrentTabularDocument.Figure, msg.text, msg.title );
return ;
end 
end 

this.InspectorControlPanel.Title = task.Name;
this.InspectorControlPanel.Collapsed = false;




if ~isempty( this.CurrentTask )
this.AutoRunOn = this.CurrentTask.AutoRunOn;
this.CurrentTabularDocument.VizScript = [  ];

this.CurrentTask.cleanUpTask(  );
this.TaskInspector = this.CurrentTask.TaskInspector;

this.CurrentTask = [  ];
this.CurrentStepIDString = [  ];
end 


if ~isempty( fieldnames( state ) )
this.CurrentStepIDString = state.stepID;
else 


this.HistoryPanel.setSelection( [  ] );
end 

if isempty( task )
return ;
end 

this.CurrentTask = matlab.internal.preprocessingApp.tasks.InspectorAppTask(  ...
'Task', task ...
, 'VariableName', this.Selection.SelectedVariable ...
, 'TableVariableName', this.Selection.SelectedTableVariables ...
, 'TaskPanel', this.InspectorControlPanel ...
, 'TaskInspector', this.TaskInspector ...
, 'CurrentWorkspace', workspace.clone ...
, 'State', state ...
, 'App', this );

if isempty( this.CurrentTask.TaskInspector )
this.CurrentTask = [  ];
this.CurrentStepIDString = [  ];
return ;
end 

if ismethod( this.CurrentTask, 'startup' )
this.CurrentTask.startup;
end 
this.CurrentTask.TaskCompletedFcn = @( ed )this.ppmodeTaskCompletedCallback( ed );

if ~isempty( fieldnames( task ) )
this.AppToolstrip.setPreprocessingModeTabTitle( task.Name );
else 
this.AppToolstrip.setPreprocessingModeTabTitle( state.Name );
end 

this.AppContainer.Busy = false;
end 

function ppmodeTaskCompletedCallback( this, eventData )
addNewCodeLine = false;
if isempty( this.CurrentStepIDString )
addNewCodeLine = true;
end 
this.LastChangeSource = this.CurrentTask;
this.updateCleaningSteps( addNewCodeLine );
end 


function openCustomPPDialog( this )
dialog = matlab.internal.preprocessingApp.tasks.CustomFunctionDialog;
end 

function openEditCustomPPDialog( this )
dialog = matlab.internal.preprocessingApp.tasks.EditCustomFunctionsDialog;
end 


function exportData( this )
vars = this.DataModel.CurrentWorkspace.getVariables;
if isempty( fieldnames( vars ) )
return ;
end 
varNames = fieldnames( vars );
outputVarNames = varNames;
for i = 1:length( varNames )
outputVarNames{ i } = genvarname( varNames{ i }, evalin( 'base', 'who' ) );
assignin( 'base', outputVarNames{ i }, vars.( varNames{ i } ) );
end 
inputVarNames = strjoin( varNames, "," );
outputVarNames = strjoin( outputVarNames, "," );
uialert( this.AppContainer,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:EXPORT_VARIABLE_EXPORTED', inputVarNames, outputVarNames ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:EXPORT_DIALOG_TITLE' ) ),  ...
'Icon', 'success' );
end 

function exportScript( this )
try 
steps = this.DataModel.Steps;
steps = processCodeToExport( steps );
code = getScriptCode( steps );
matlab.desktop.editor.newDocument( code );
uialert( this.AppContainer,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:EXPORT_SCRIPT_EXPORTED' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:EXPORT_DIALOG_TITLE' ) ),  ...
'Icon', 'success' );
catch 
end 
end 

function exportFunction( this )
try 
steps = this.DataModel.Steps;
steps = processCodeToExport( steps );
code = this.getFunctionCode( steps );
matlab.desktop.editor.newDocument( code );
uialert( this.AppContainer,  ...
getString( message( 'MATLAB:datatools:preprocessing:app:EXPORT_FUNCTION_EXPORTED' ) ),  ...
getString( message( 'MATLAB:datatools:preprocessing:app:EXPORT_DIALOG_TITLE' ) ),  ...
'Icon', 'success' );
catch e
end 
end 

function exportRecipe( this )
[ file, path ] = uiputfile( '*.json' );
filepath = [ path, file ];






steps = this.DataModel.Steps;
try 

f = fopen( filepath, 'w' );
jsonSteps = jsonencode( steps, 'PrettyPrint', true );
fprintf( f, "%s", jsonSteps );
fclose( f );
catch e
disp( e );
return ;
end 
end 

function code = getFunctionCode( this, steps )
code = "function " + this.SelectedVariable +  ...
" = " + "untitled(" + this.SelectedVariable + ")" + newline + sprintf( '\t' );

if ~isempty( steps )
codeBody = sprintf( "%s", strjoin( string( { steps.Code } ),  ...
sprintf( "\n\n" ) ) );
codeBody = strsplit( codeBody, newline );
codeBody = strjoin( codeBody, [ newline, char( 9 ) ] );
code = code + codeBody;
end 
code = code + newline + "end";
end 

function item = getItemFromGallery( this, itemName )
items = this.AppToolstrip.PreprocessingGalleryItems.keys;
for i = 1:length( items )
if strcmp( itemName, this.AppToolstrip.PreprocessingGalleryItems( items{ i } ).Text )
item = this.AppToolstrip.PreprocessingGalleryItems( items{ i } );
break ;
end 
end 
end 

function close( this )
this.AppContainer.close(  );
end 

function result = closeAndDelete( this )
this.AppContainer.Visible = false;
result = true;
this.delete;
end 


function varValue = getVariableValue( ~, varName )
varValue = evalin( 'base', varName );
end 



function deleteToolstrip( this )
delete( this.AppToolstrip );
end 

function deleteTabularDocument( this )
if isempty( this.AppContainer.getDocuments( "defaultGroup" ) )
return ;
end 
k = this.AppContainer.getDocuments( "defaultGroup" );
for i = 1:length( k )
if isvalid( k{ i } ) && ~isequal( k{ i }, this.CurrentTabularDocument )
delete( k{ i }.Figure );
end 
end 
end 

function closeTabularDocument( this )
if isvalid( this.CurrentTabularDocument ) &&  ...
~isempty( this.CurrentTabularDocument.VariableName ) ||  ...
~strcmp( this.CurrentTabularDocument.VariableName, "" )
this.AppContainer.closeDocument( this.HOME_DOCUMENT_GROUP,  ...
this.CurrentTabularDocument.VariableName );
end 
this.CurrentTabularDocument = [  ];
end 

function deleteVariableBrowser( this )
if isvalid( this.VariableBrowserPanel ) &&  ...
isvalid( this.VariableBrowserPanel.Figure )
delete( this.VariableBrowserPanel.Figure );
end 
end 

function deleteHistoryPanel( this )
if isvalid( this.HistoryPanel ) &&  ...
isvalid( this.HistoryPanel.Figure )
delete( this.HistoryPanel.Figure );
end 
delete( this.HistoryChangedFcn );
end 

function deleteDataModel( this )
delete( this.DataModel );
end 

function deleteModePreviewPanels( this )
delete( this.InspectorControlPanel );
end 

function deleteTaskListeners( this )
delete( this.TaskAddedListener );
delete( this.TaskRemovedListener );
delete( this.TaskModifiedListener );
end 

function delete( this )
this.deleteDataModel(  );
this.deleteToolstrip(  );
this.deleteVariableBrowser(  );
this.deleteHistoryPanel(  );
delete( this.SelectionThrottler );
this.deleteTaskListeners(  );
this.deleteVariableBrowser(  );
this.deleteHistoryPanel(  );
this.deleteModePreviewPanels(  );
end 


function centerUIToApp( this, dialog )
appContainerWindowBounds = this.AppContainer.WindowBounds;
appCenterX = appContainerWindowBounds( 1 ) + ( appContainerWindowBounds( 3 ) / 2 );
appCenterY = appContainerWindowBounds( 2 ) + ( appContainerWindowBounds( 4 ) / 2 );
screenSize = get( groot, 'ScreenSize' );
if appContainerWindowBounds( 1 ) > screenSize( 3 ) - screenSize( 1 )

MP = get( 0, 'MonitorPositions' );
newPosition = MP( 2, : );
newCenterX = newPosition( 1 ) + ( newPosition( 3 ) / 2 );
newCenterY = newPosition( 2 ) + ( newPosition( 4 ) / 2 );
dialog.Position( 1 ) = newCenterX - dialog.WIDTH_WITH_VAR_SELECTION / 2;
dialog.Position( 2 ) = newCenterY - dialog.HEIGHT_WITH_VAR_SELECTION / 2;
dialog.Position( 3 ) = dialog.WIDTH_WITH_VAR_SELECTION;
dialog.Position( 4 ) = dialog.HEIGHT_WITH_VAR_SELECTION;
else 
dialog.Position( 1 ) = appCenterX - dialog.WIDTH_WITH_VAR_SELECTION / 2;
dialog.Position( 2 ) = appCenterY - dialog.HEIGHT_WITH_VAR_SELECTION / 2;
dialog.Position( 3 ) = dialog.WIDTH_WITH_VAR_SELECTION;
dialog.Position( 4 ) = dialog.HEIGHT_WITH_VAR_SELECTION;
end 
end 

function result = isSupportedVarsInWorkspace( this )
result = false;
variables = evalin( 'base', 'whos' );
for i = 1:length( variables )
if ismember( variables( i ).class, this.getSupportedTypes(  ) )
result = true;
break ;
end 
end 
end 

function supportedTypes = getSupportedTypes( this )
supportedTypes = "timetable";
if this.TableSupportOn
supportedTypes = [ supportedTypes, "table" ];
end 
end 

function varSelector = getImportDataSelector( this )
supportedTypes = "timetable";
if this.TableSupportOn
supportedTypes = [ supportedTypes, "table" ];
end 

wp = matlab.internal.importdata.WorkspaceProvider( "base" );
f = @( x )mustBeA( x, supportedTypes );
g = @mustBeNonempty;
wp.FilterFunction = { f, g };
varSelector = matlab.internal.importdata.VariableSelector( wp );
varSelector.IsModal = 1;
varSelector.SingleSelection = 1;
varSelector.ExtraMessage = getString( message ...
( 'MATLAB:datatools:preprocessing:app:IMPORT_SINGLEVARIABLE_SUPPORT_ONLY' ) );
end 


function obj = testGetContextObject( ~, tag, panelTags, toolstripTags )
obj = getContextObject( tag, panelTags, toolstripTags );
end 

function obj = testGetScreenCenterLocation( ~ )
obj = getScreenCenterLocation(  );
end 

function obj = testGetTaskDescription( ~, taskName, taskTableVarName,  ...
taskVarName )
obj = getTaskDescription( taskName, taskTableVarName, taskVarName );
end 

function steps = testGetProcessedCodeForExport( ~, steps )
steps = processCodeToExport( steps );
end 

function code = testGetScriptCode( ~, steps )
code = getScriptCode( steps );
end 

function importDataSelector = testGetImportDataSelector( this )
importDataSelector = this.getImportDataSelector(  );
end 

function [ hasGrouped, unsupportedReason, unsupportedVarClass, unsupportedVarArray ] = testContainsGroupedColumns( ~, data )
[ hasGrouped, unsupportedReason, unsupportedVarClass, unsupportedVarArray ] = containsUnsupportedColumns( data );
end 

function [ hasUnsupported, unsupportedReason, unsupportedVarClass, unsupportedVarArray ] = testContainsUnsupportedColumns( ~, data )
[ hasUnsupported, unsupportedReason, unsupportedVarClass, unsupportedVarArray ] = containsUnsupportedColumns( data );
end 
end 

methods ( Static )


function iconPath = getIconForStep( stepName )
if contains( stepName, "sortrows", 'IgnoreCase', true )
if contains( stepName, "descend", 'IgnoreCase', true )
iconPath = 'release/images/sortDown2.svg';
else 
iconPath = 'release/images/sortUp2.svg';
end 
elseif contains( stepName, "rename", 'IgnoreCase', true )
iconPath = 'release/images/rename_16.png';
elseif contains( stepName, "delete", 'IgnoreCase', true )
iconPath = 'release/images/delete2_16.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_dataSmoother_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/smoothData_16.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_timetableRetimer_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/retimeTimetable_16.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_trendRemover_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/RemoveTrends_16.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_tableUnstacker_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/unstackableTable_16.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_tableStacker_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/stackTableVariables_16.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_outlierDataCleaner_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/DataCleaning16px-05.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_missingDataCleaner_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/cleanMissing_16.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_NormalizeDataTask_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/NormalizeData_16px.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_ComputeByGroupTask_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/ComputeByGroup_16px.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_tableJoiner_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/tableJoiner_16px.png';
elseif contains( stepName, getString( message( 'MATLAB:dataui:Tool_timetableSynchronizer_Label' ) ), 'IgnoreCase', true )
iconPath = 'release/images/timetableSynchronizer_16px.png';
else 
iconPath = 'release/images/function_16.png';
end 
end 
end 

methods ( Access = 'private' )
function updateCleaningTasksList( this, data )



if isequal( width( data ), 1 )
this.removeStructuralTasks(  );
elseif ~this.galleryContainsStructural(  )
this.addStructuralTasks(  );
end 
end 

function result = galleryContainsStructural( this )
atf = matlab.internal.preprocessingApp.tasks.AppTaskFactory.getInstance;
galleryTasks = atf.PreprocessingLiveTasks;
result = true;
for i = 1:length( galleryTasks )
if contains( galleryTasks( i ).Name, string( message( 'MATLAB:dataui:Tool_tableStacker_Label' ) ) ) ||  ...
contains( galleryTasks( i ).Name, string( message( 'MATLAB:dataui:Tool_tableUnstacker_Label' ) ) )
if isempty( this.AppToolstrip.PreprocessingGalleryItems( galleryTasks( i ).Name ) )
result = false;
break ;
end 
end 
end 
end 

function addStructuralTasks( this )
atf = matlab.internal.preprocessingApp.tasks.AppTaskFactory.getInstance;
galleryTasks = atf.PreprocessingLiveTasks;
for i = 1:length( galleryTasks )
if contains( galleryTasks( i ).Name, string( message( 'MATLAB:dataui:Tool_tableStacker_Label' ) ) ) ||  ...
contains( galleryTasks( i ).Name, string( message( 'MATLAB:dataui:Tool_tableUnstacker_Label' ) ) )
this.taskAdded( galleryTasks( i ) );
end 
end 
end 

function removeStructuralTasks( this )
atf = matlab.internal.preprocessingApp.tasks.AppTaskFactory.getInstance;
galleryTasks = atf.PreprocessingLiveTasks;
for i = 1:length( galleryTasks )
if contains( galleryTasks( i ).Name, string( message( 'MATLAB:dataui:Tool_tableStacker_Label' ) ) ) ||  ...
contains( galleryTasks( i ).Name, string( message( 'MATLAB:dataui:Tool_tableUnstacker_Label' ) ) )
this.taskRemoved( galleryTasks( i ) );
end 
end 
end 
end 




end 

function taskDescription = getTaskDescription( currentTaskName,  ...
currentTaskTableVariableName,  ...
currentTaskVariable )
if ~isempty( currentTaskTableVariableName )
currentTaskTableVariableName = strrep( currentTaskTableVariableName,  ...
'.', [ currentTaskVariable, '.' ] );
try 
currentTaskTableVariableName = strjoin( currentTaskTableVariableName, ',' );
catch 
end 
else 
currentTaskTableVariableName = currentTaskVariable;
end 
taskDescription = currentTaskName + ": " + currentTaskTableVariableName;
end 

function contextObj = getContextObject( tag, panelTags, toolstripTags )
import matlab.ui.container.internal.appcontainer.*;

contextObj = ContextDefinition(  );
contextObj.Tag = tag;
contextObj.PanelTags = panelTags;
contextObj.ToolstripTabGroupTags = toolstripTags;
end 

function location = getScreenCenterLocation(  )
screenSize = get( groot, 'ScreenSize' );
appSize = round( ( 3 / 4 ) * screenSize );
centerLocation = round( ( screenSize - appSize ) / 2 );
location = [ centerLocation( 3 ), centerLocation( 4 ), appSize( 3 ), appSize( 4 ) ];
end 

function result = showPropertyInspector( task, usePropertyInspector )
result = ( task.HasVisualization || strcmp( task.Group, 'User Authored' ) ) ...
 && usePropertyInspector;
end 

function currenttask = getCurrentTask( task, state )
if ~isempty( fieldnames( task ) )
currenttask = task;
else 
currenttask = state.Task;
end 
end 

function result = getTableVariables( data )
result = data.Properties.VariableNames;
if istimetable( data )
result = [ data.Properties.DimensionNames( 1 ), result ];
end 
end 

function result = getDefaultTableVariable( data )
result = string( data.Properties.VariableNames );
result = result( 1 );
if istimetable( data )
result = [ data.Properties.DimensionNames( 1 ), result ];
result = result( 2 );
end 
end 

function istableleveltask = isTableLevelTask( task )
istableleveltask = ~isempty( task.ReshapeOutputVariable ) && ( task.ReshapeOutputVariable == 1 );
end 

function idx = getLastEnabledStepIndex( steps )
idx = 0;
if isempty( steps )
return ;
end 

for i = length( steps ): - 1:1
if steps( i ).Enabled
idx = i;
break ;
end 
end 
end 

function step = getLastEnabledStep( steps )
step = struct.empty;
for i = length( steps ): - 1:1
if steps( i ).Enabled
step = steps( i );
break ;
end 
end 
end 

function steps = processCodeToExport( steps )
for i = 1:length( steps )
if ~steps( i ).Enabled
steps( i ).Code =  ...
strjoin( strcat( "%",  ...
strsplit( steps( i ).Code,  ...
newline ) ), newline );
end 
end 
end 

function code = getScriptCode( steps )
code = "";
if isempty( steps )
return ;
end 

try 
code = sprintf( "%s", strjoin( string( { steps.Code } ), sprintf( "\n\n" ) ) );
catch 
end 
end 

function result = isNonEditableOperation( type )
result = any( ismember( [ "Sort", "Rename", "Delete" ], type ) );
end 

function isGreater = isSizeGreaterThanLimit( data )
rowCount = size( data, 1 );
colCount = size( data, 2 );
isGreater = ( rowCount * colCount ) > 1000000;
end 

function [ result, reason, className, unsupportedVariableArray ] = containsUnsupportedColumns( data )
result = false;
reason = '';
className = '';
unsupportedVariableArray = [  ];
for i = 1:size( data, 2 )
if ( width( data.( i ) ) > 1 )
result = true;
reason = 'GroupedColumn';
unsupportedVariableArray = [ unsupportedVariableArray, string( data.Properties.VariableNames{ i } ) ];
elseif ( isobject( data.( i ) ) && ~iscategorical( data.( i ) ) && ~isstring( data.( i ) ) && ~isdatetime( data.( i ) ) && ~isduration( data.( i ) ) )
result = true;
reason = 'UnsupportedColumn';
if isempty( className )
className = internal.matlab.variableeditor.peer.PeerUtils.formatClass( data.( i ) );
end 
unsupportedVariableArray = [ unsupportedVariableArray, string( data.Properties.VariableNames{ i } ) ];
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpYj1wGs.p.
% Please follow local copyright laws when handling this file.

