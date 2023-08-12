classdef StudioApp < handle




properties ( Constant, Access = public )
SLDDNodeName = 'InterfaceDictionary';
end 

properties ( Constant, Access = private )
PropertyInspectorWidthRatio = 0.45;
end 

properties ( Access = private )
DictObj Simulink.interface.Dictionary;


AppWindow;
AppWindowActivatedListener;

AvoidEarlyGUICloseFromDDListener = false;


ListComponent;
ListObj;

PropertyInspectorComponent;

Source sl.interface.dictionaryApp.source.Source;
end 

properties ( Hidden )
SelectedPlatformId;
end 


methods ( Static, Access = public )

function hWin = open( dict )

if isstring( dict ) || ischar( dict )
dict = Simulink.interface.dictionary.open( dict );
end 
assert( isa( dict, 'Simulink.interface.Dictionary' ),  ...
'Expected open to return an Interface Dictionary object.' );
assert( dict.isOpen, 'Expected Interface Dictionary connection to be open' );
guiObj = sl.interface.dictionaryApp.StudioApp.getUIObj( dict );
hWin = guiObj.show( true );
end 

function handleDDClose( ddfilePath )
if ~isempty( ddfilePath ) && exist( ddfilePath, 'file' )
nodeName = sl.interface.dictionaryApp.StudioApp.SLDDNodeName;
guiObj =  ...
sl.interface.dictionaryApp.StudioApp.findStudioAppForDict( ddfilePath );
if ~isempty( guiObj )
Simulink.dd.internal.DictionaryViewManager.instance.removeView(  ...
ddfilePath, nodeName );
end 
end 
end 

function handleDDSave( ddfilePath )

guiObj = sl.interface.dictionaryApp.StudioApp.findStudioAppForDict( ddfilePath );
if ~isempty( guiObj ) && guiObj.isWindowActive(  )
contextObj = guiObj.AppWindow.getContextObject;
contextObj.TypeChainHandler.updateTypeChainForCleanDictionary(  );
guiObj.updateWindow(  );
end 
end 

function handleDDEvents( ddfilePath, evtStr )
switch evtStr
case { 'preClose', 'postClose' }
sl.interface.dictionaryApp.StudioApp.handleDDClose( ddfilePath );
case 'postSave'
sl.interface.dictionaryApp.StudioApp.handleDDSave( ddfilePath );
otherwise 

end 
end 

function result = handleSelectionChange( ~, selection, this )
result = this.handleSelectedNodeChange( selection );
this.setMimeInfo( selection );
end 

function handleTabChanged( ~, tabId, this )
this.tabChanged( tabId );
end 

function studioApp = findStudioAppForDict( filePath )
nodeName = sl.interface.dictionaryApp.StudioApp.SLDDNodeName;
studioApp =  ...
Simulink.dd.internal.DictionaryViewManager.instance.getView( filePath,  ...
nodeName );
end 
end 

methods ( Static, Access = private )
function guiObj = getUIObj( dictObj )
guiObj = sl.interface.dictionaryApp.StudioApp.findStudioAppForDict( dictObj.filepath(  ) );
if isempty( guiObj )
nodeName = sl.interface.dictionaryApp.StudioApp.SLDDNodeName;
guiObj = sl.interface.dictionaryApp.StudioApp( dictObj );
Simulink.dd.internal.DictionaryViewManager.instance.setView(  ...
dictObj.filepath(  ), nodeName, guiObj );
end 
end 

function isValid = isValidDictionary( filePath )

isValid =  ...
autosar.dictionary.Utils.isAUTOSARInterfaceDictionary( filePath );
end 

function node = findNodeByName( nodes, nodeName )
node = nodes( strcmp( nodeName, { nodes.Name } ) );
assert( length( node ) == 1, 'Expected to find 1 node' );
end 

function isValidDrag = onDrag( listComponent, selection, destination, location, action )
isValidDrag = sl.interface.dictionaryApp.list.DragNDropHelper.isValidDrag(  ...
listComponent, selection, destination, location, action );
end 

function onDrop( ~, selection, destination, location, action )

sl.interface.dictionaryApp.list.DragNDropHelper.drop(  ...
selection, destination, location, action );
end 

function contextMenu = onContextMenuRequest( ~, selection )

contextMenu = selection.getContextMenuItems(  );
end 
end 


methods ( Access = public )

function dictObj = getInterfaceDictObj( this )
dictObj = this.DictObj;
end 

function addElement( this, elementInfo )
this.ListObj.addElement( elementInfo );
end 

function deleteSelectedNodes( this )
this.ListObj.deleteSelectedNodes(  );
end 

function showOptions( this )
this.ListObj.showOptions(  );
end 

function showHelp( this )
this.ListObj.showHelp(  );
end 

function showEntry( this, itfDictEntry )


this.changeTabForEntry( itfDictEntry );

drawnow;
this.selectItfDictEntry( itfDictEntry );
end 

function currentTabName = getCurrentTabName( this )
currentTabName = this.ListObj.getTab(  );
end 

function forceTabChangeByName( this, tabName )
this.setCurrentTabByName( tabName );
this.tabChanged( tabName );
end 

function changePlatform( this, platformId )
this.SelectedPlatformId = platformId;
contextObj = this.AppWindow.getContextObject;
contextObj.TypeChainHandler.setContextTypeChainForSelectedPlatform( this.SelectedPlatformId );
this.refreshTabs(  );
this.setDefaultPI(  );
end 

function refreshTabs( this )

this.ListObj.refreshTabs( this.SelectedPlatformId );
this.updateWindow(  );
end 

function setDefaultPI( this )

this.PropertyInspectorComponent.updateSource( '',  ...
sl.interface.dictionaryApp.pi.DefaultPISchema( this.DictObj.DictionaryFileName ) );
end 

function refreshList( this, changesReportObj )
this.ListObj.refreshList( changesReportObj );
this.refreshSourceObj(  );
this.updateWindow(  );
end 

function refreshSourceObj( this )

this.Source.refresh(  );
end 

function refreshPIDialog( this )

this.ListObj.refreshPIDialog(  );
end 

function isActive = isWindowActive( this )


isActive = ~isempty( this.AppWindow.getStudio(  ) );
end 



function tf = isVisible( this )
tf = false;
studioWindow = this.getStudioWindow(  );
if ~isempty( studioWindow )
tf = studioWindow.getStudio(  ).isStudioVisible(  );
end 
end 

function clipboard = getClipboard( ~ )
clipboard =  ...
sl.interface.dictionaryApp.clipboard.Clipboard.getInstance(  );
end 



function sw = getStudioWindow( this )
sw = [  ];
if ~isempty( this.AppWindow ) && isvalid( this.AppWindow )
sw = this.AppWindow;
end 
end 



function studio = getStudio( this )
studio = [  ];
if ~isempty( this.AppWindow ) && isvalid( this.AppWindow )
studio = this.AppWindow.getStudio(  );
end 
end 

function exportToM( ~ )
assert( false, 'Export to MATLAB files has not been implemented' );
end 

function exportToMAT( ~ )
assert( false, 'Export to MAT files has not been implemented' );
end 

function exportPlatform( this )
try 
reEnableStudioWindow = onCleanup( @(  )this.enableStudio(  ) );
this.disableStudio(  );

platformMapping = this.DictObj.getPlatformMapping( this.SelectedPlatformId );
platformMapping.exportDictionary( IsInterfaceDictUIContext = true );
catch Me


dp = DAStudio.DialogProvider;
title = DAStudio.message( 'Simulink:utility:ErrorDialogSeverityError' );
dp.errordlg( Me.message, title, true );



disp( Me.getReport );
end 
end 

function platformMappingIds = getBuiltInPlatformIds( this )%#ok<MANU>
platformMappingIds = Simulink.interface.Dictionary.getBuiltInPlatformNames(  );
end 

function platformMappingIds = getMappedPlatformIds( this )

platformMappingIds = this.DictObj.getPlatformNames(  );
end 

function addPlatformMapping( this, platformId )
this.DictObj.addPlatformMapping( platformId );
end 

function currentNode = getCurrentListNode( this )

currentNode = this.getSelectedNodes(  );
end 

function currentNode = getSelectedNodes( this )
currentNode = this.ListObj.getSelectedNodes(  );
end 

function tabAdapter = getTabAdapter( this )
tabAdapter = this.ListObj.getTabAdapter(  );
end 

function currentColumns = getColumnsForCurrentTab( this )

currentColumns = this.ListObj.getColumnsForCurrentTab(  );
end 

function visibleColumns = getVisibleColumns( this )

visibleColumns = this.ListObj.getVisibleColumns(  );
end 

function setVisibleColumns( this, visibleColumns )

this.ListObj.setVisibleColumns( visibleColumns );
end 

function propertyInspector = getDialogComp( this )
propertyInspector = this.PropertyInspectorComponent;
end 

function list = getListComp( this )
list = this.ListComponent;
end 

function source = getSource( this )
source = this.Source(  );
end 

function hasTree = hasTreeComp( ~ )
hasTree = false;
end 

function close( this )
if ~this.AvoidEarlyGUICloseFromDDListener
this.clearEditor(  );
this.AppWindow.close(  );
this.AppWindow.delete(  );
end 
end 

function update( ~ )


end 

function isDirty = isDictDirty( this )

isDirty = this.DictObj.isDirty(  );
end 

function isEmpty = isDictEmpty( this )

isEmpty = this.DictObj.isEmpty(  );
end 

function saveDictionary( this )

this.DictObj.save(  );
assert( ~this.isDictDirty, 'Dictionary should not still be dirty' )
end 

function closeDictionary( this, namedArgs )

R36
this sl.interface.dictionaryApp.StudioApp;
namedArgs.DiscardChanges = true;
end 

this.DictObj.close( DiscardChanges = namedArgs.DiscardChanges );
end 

function commandStrProvider = getCommandStrProvider( this )
commandStrProvider = sl.interface.dictionaryApp.utils.CommandStrProvider( this );
end 

function updateTypeChain( this )
contextObj = this.AppWindow.getContextObject;
selectedNodes = this.getSelectedNodes(  );
if isempty( selectedNodes )
contextObj.setContextTypeChainToCurrentList( this.ListObj );
else 
contextObj.setContextTypeChainToSelectedNodes( this.getSelectedNodes(  ) );
end 
end 

function moveSelectedElement( this, moveDirection )
import sl.interface.dictionaryApp.list.DragNDropHelper;


selectedNodes = this.getSelectedNodes(  );
topSelectedNode = selectedNodes{ 1 };
destinationNode =  ...
DragNDropHelper.getDestinationNodeForMoveElementButton(  ...
topSelectedNode, moveDirection );


action = 'move';
location = 'below';
this.onDrop( this.ListComponent, selectedNodes, destinationNode, location, action )
end 
end 

methods ( Access = public, Hidden )
function cleanupObj = disableSLDDListener( this )

deregisterSLDDListenerHandle = @(  )this.deregisterSLDDListener;
registerSLDDListenerHandle = @(  )this.registerSLDDListener;
slprivate( deregisterSLDDListenerHandle );
cleanupObj = onCleanup( @(  )slprivate( registerSLDDListenerHandle ) );
end 

function clearRowHighlights( ~ )

end 

function forceUpdateTabToNodesMap( this, modifiedNodeObj, newDictElementName, oldDictElementName, destinationTabId )
this.ListObj.forceUpdateTabToNodesMap( modifiedNodeObj, newDictElementName, oldDictElementName, destinationTabId )
end 

function isNodeExpanded = isNodeExpanded( this, nodeObj )
ss = this.ListComponent.imSpreadSheetComponent;
isNodeExpanded = ss.isExpanded( nodeObj );
end 
end 

methods ( Access = private )

function this = StudioApp( dictObj )
this.DictObj = dictObj;
this.initPlatformId(  );
this.constructUI(  );
this.initSource(  );
end 

function initPlatformId( this )
if ~slfeature( 'InterfaceDictionaryPlatforms' )


this.SelectedPlatformId = 'AUTOSARClassic';


assert( this.DictObj.hasPlatformMapping( this.SelectedPlatformId ),  ...
'Expected Interface Dictionary to have an AUTOSARClassic platform mapping.' );
else 





this.SelectedPlatformId = 'Native';
end 
end 

function closeWindow = handleAppWindowCloseRequest( this, ~, ~ )


closeWindow = true;
if this.isDictDirty(  )
defaultResponse = '';


warningToSuppress = warning( 'off', 'MATLAB:questdlg:StringMismatch' );
restoreWarning = onCleanup( @(  )warning( warningToSuppress ) );
saveResponse = questdlg(  ...
DAStudio.message( 'interface_dictionary:common:CloseDialogUnsavedChangesQuestion', this.DictObj.DictionaryFileName ),  ...
DAStudio.message( 'interface_dictionary:common:CloseDialogSaveChangesTitle' ),  ...
DAStudio.message( 'interface_dictionary:common:CloseDialogSaveChanges' ),  ...
DAStudio.message( 'interface_dictionary:common:CloseDialogDiscardChanges' ),  ...
DAStudio.message( 'interface_dictionary:common:CloseDialogCloseInterfaceEditor' ),  ...
defaultResponse );
if strcmp( saveResponse, DAStudio.message( 'interface_dictionary:common:CloseDialogSaveChanges' ) )
this.saveDictionary(  );

this.clearEditor(  );
elseif strcmp( saveResponse, DAStudio.message( 'interface_dictionary:common:CloseDialogDiscardChanges' ) )



this.AvoidEarlyGUICloseFromDDListener = true;
this.closeDictionary( DiscardChanges = true );
elseif strcmp( saveResponse, DAStudio.message( 'interface_dictionary:common:CloseDialogCloseInterfaceEditor' ) )


this.clearEditor(  );
else 

closeWindow = false;
return ;
end 
else 

this.clearEditor(  );
end 
end 

function handleAppWindowActivated( this, ~, ~ )
this.updateTypeChain(  );
end 

function hWin = show( this, makeVisible )
if isempty( this.AppWindow ) ||  ...
~isvalid( this.ListComponent )
this.constructUI(  );
end 
if makeVisible
this.AppWindow.show;
end 
hWin = this.AppWindow;
end 

function constructUI( this )

confObj = this.initToolstrip(  );


this.initAppWindow( confObj )


this.initList(  );

this.initPropertyInspector(  );


contextObj = this.AppWindow.getContextObject;
contextObj.initContextWithGuiObj( this );


this.ListComponent.onSelectionChange =  ...
@( src, selection )sl.interface.dictionaryApp.StudioApp.handleSelectionChange( src, selection, this );
this.ListComponent.onTabChange =  ...
@( src, tabId )sl.interface.dictionaryApp.StudioApp.handleTabChanged( src, tabId, this );
this.ListComponent.onContextMenuRequest =  ...
@sl.interface.dictionaryApp.StudioApp.onContextMenuRequest;


Simulink.dd.private.AddDDMgrMATLABCallBackEventHandler(  ...
'sl.interface.dictionaryApp.StudioApp.handleDDEvents' );

this.AppWindow.onCloseRequested = @( studioApp )this.handleAppWindowCloseRequest( studioApp );
this.AppWindowActivatedListener = addlistener( this.AppWindow, 'activated', @this.handleAppWindowActivated );
this.registerSLDDListener(  );
end 

function initSource( this )
source = sl.interface.dictionaryApp.source.Source( this.DictObj.filepath );
source.FilterEntriesFromInterfaceDictionary = false;
source.getChildren(  );
this.Source = source;
end 

function registerSLDDListener( this )
this.DictObj.DictImpl.registerObservingListener(  ...
'sl.interface.dictionaryApp.observer.StudioAppSLDDListener.observeChanges' );
end 

function disableStudio( this )
this.AppWindow.disable(  );
this.ListComponent.disable(  );
end 

function enableStudio( this )
this.AppWindow.enable(  );
this.ListComponent.enable(  );
end 

function deregisterSLDDListener( this )



if this.DictObj.DictImpl.isvalid(  )
this.DictObj.DictImpl.unregisterObservingListener(  ...
'sl.interface.dictionaryApp.observer.StudioAppSLDDListener.observeChanges' );
end 
end 

function initPropertyInspector( this )
this.PropertyInspectorComponent = GLUE2.PropertyInspectorComponent(  ...
message( 'interface_dictionary:common:propInspectorTitle' ).getString );
this.PropertyInspectorComponent.UserMoveable = false;
this.PropertyInspectorComponent.UserFloatable = false;
this.PropertyInspectorComponent.updateSource( '',  ...
sl.interface.dictionaryApp.pi.DefaultPISchema( this.DictObj.DictionaryFileName ) );
this.AppWindow.addComponent( this.PropertyInspectorComponent, 'right' );
this.setDefaultPISize(  );
end 

function setDefaultPISize( this )


studio = this.PropertyInspectorComponent.getStudio;
curPos = studio.getStudioPosition;
width = curPos( 3 ) * this.PropertyInspectorWidthRatio;
height = curPos( 4 );
this.PropertyInspectorComponent.setPreferredSize( width, height );
end 

function confObj = initToolstrip( ~ )

confObj = studio.WindowConfiguration;
confObj.ToolstripConfigurationName = 'dictToolstripPluginConfig';
confObj.ToolstripConfigurationPath = fullfile( matlabroot, 'toolbox', 'simulink', 'sl_interface_dict', 'editor' );
confObj.ToolstripName = 'dictToolstrip';
confObj.ToolstripContext =  ...
'sl.interface.dictionaryApp.toolstrip.architectureDictionaryCustomContext';
end 

function initAppWindow( this, confObj )

confObj.Title = this.getWindowTitle(  );
confObj.Tag = 'InterfaceDictApp';
confObj.Icon = fullfile( matlabroot, 'toolbox', 'simulink', 'sl_interface_dict',  ...
'editor', '+sl', '+interface', '+dictionaryApp', 'resources',  ...
'prototype', 'main', 'InterfaceDictUI.svg' );
this.AppWindow = studio.Window( confObj );
end 

function setCurrentTabByName( this, tabName )
this.ListObj.setCurrentTabIdByName( tabName );
end 

function result = handleSelectedNodeChange( this, selectedNodes )


result = true;

contextObj = this.AppWindow.getContextObject;
if ~isempty( selectedNodes )
this.ListObj.cacheSelectedNodes( selectedNodes );

contextObj.setContextTypeChainToSelectedNodes( selectedNodes );

this.PropertyInspectorComponent.updateSource( '', selectedNodes{ end  } );
else 
this.ListObj.clearSelectedNodeCache(  );

contextObj.setContextTypeChainToCurrentList( this.ListObj );

this.PropertyInspectorComponent.updateSource( '',  ...
sl.interface.dictionaryApp.pi.DefaultPISchema( this.DictObj.DictionaryFileName ) );
end 
end 

function tabChanged( this, tabId )
this.ListObj.tabChanged( tabId );
this.PropertyInspectorComponent.updateSource( '',  ...
sl.interface.dictionaryApp.pi.DefaultPISchema( this.DictObj.DictionaryFileName ) );

contextObj = this.AppWindow.getContextObject;
contextObj.setContextTypeChainToCurrentList( this.ListObj );
end 

function initList( this )
this.ListComponent = GLUE2.SpreadSheetComponent( 'InterfaceDictList' );

this.ListObj = sl.interface.dictionaryApp.list.List( this.ListComponent,  ...
this.DictObj, this.SelectedPlatformId, this );

this.ListComponent.setSource( this.ListObj );
this.ListComponent.setTitleViewSource( this.ListObj );

this.ListComponent.enableHierarchicalView( true );
this.ListComponent.HideTitle = false;
this.ListComponent.UserMoveable = false;
this.ListComponent.UserFloatable = false;
this.ListComponent.setComponentUserData( struct( 'Multiselection', [  ] ) );

listConfigOpts = struct( "regexinfilter", true, "enablesort", false,  ...
"enablecolumnreordering", true, "enablegrouping", false, "showgrid", false );
this.ListComponent.setConfig( jsonencode( listConfigOpts ) );
this.ListComponent.setMultiFilter( true );
this.ListComponent.setConfig( '{"columns":[{"name":"Name","width":150}]}' );


this.ListComponent.setDragCursor( 'move', Simulink.typeeditor.utils.getBusEditorResourceFile( 'move_cursor.png' ) );
this.ListComponent.setDragCursor( 'copy', Simulink.typeeditor.utils.getBusEditorResourceFile( 'copy_cursor.png' ) );


this.ListComponent.setAcceptedMimeTypes( { 'application/interfacedict-mimetype' } );
this.ListComponent.onDrag = @sl.interface.dictionaryApp.StudioApp.onDrag;
this.ListComponent.onDrop = @sl.interface.dictionaryApp.StudioApp.onDrop;

this.AppWindow.addComponent( this.ListComponent, 'center' );
end 

function windowTitle = getWindowTitle( this )


genericTitlePart = message( 'interface_dictionary:common:GuiTitle' ).getString(  );
[ ~, name, ext ] = fileparts( this.DictObj.filepath(  ) );
shortName = [ name, ext ];
if this.isDictDirty
dirtyflag = '*';
else 
dirtyflag = '';
end 

windowTitle = [ genericTitlePart, ': ', shortName, dirtyflag ];
end 

function updateWindow( this )
confObj = studio.WindowConfiguration;
confObj.Title = this.getWindowTitle(  );
this.AppWindow.updateConfiguration( confObj );
end 

function clearEditor( this )
this.deregisterSLDDListener(  );
this.ListObj.close(  );
delete( this.ListComponent );
delete( this.PropertyInspectorComponent );
delete( this.AppWindowActivatedListener );
end 

function changeTabForEntry( this, itfDictEntry )
if isa( itfDictEntry, 'Simulink.interface.dictionary.DataType' ) ||  ...
isa( itfDictEntry, 'Simulink.interface.dictionary.StructElement' )
tabName = 'DataTypesTab';
elseif isa( itfDictEntry, 'Simulink.interface.dictionary.PortInterface' ) ||  ...
isa( itfDictEntry, 'Simulink.interface.dictionary.InterfaceElement' )
tabName = 'InterfacesTab';
elseif isa( itfDictEntry, 'Simulink.interface.dictionary.Constant' )
tabName = 'ConstantsTab';
else 
assert( false, 'Unexpected entry type' )
end 
this.forceTabChangeByName( tabName );
end 

function selectItfDictEntry( this, itfDictEntry )
nodes = this.ListObj.getChildren(  );
nodeName = itfDictEntry.Name;
isChild =  ...
isa( itfDictEntry, 'Simulink.interface.dictionary.InterfaceElement' ) ||  ...
isa( itfDictEntry, 'Simulink.interface.dictionary.StructElement' );
if isChild


parentEntry = itfDictEntry.Owner;
nodeName = parentEntry.Name;
end 
nodeToSelect = this.findNodeByName( nodes, nodeName );
if isChild
this.ListObj.expandNode( nodeToSelect );
nodes = nodeToSelect.getHierarchicalChildren(  );
nodeName = itfDictEntry.Name;
nodeToSelect = this.findNodeByName( nodes, nodeName );
end 
this.ListObj.selectNode( nodeToSelect );
end 

function setMimeInfo( this, selection )



for selIdx = 1:length( selection )
selectedRow = selection{ selIdx };
if selectedRow.isDragAllowed(  ) || selectedRow.isDropAllowed(  )
this.ListComponent.setMimeInfo( selectedRow,  ...
selectedRow.getMimeType(  ), selectedRow.getMimeData(  ) );
end 
end 
end 

end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpiEFraE.p.
% Please follow local copyright laws when handling this file.

