classdef List < handle





properties ( Access = public )
Tabs sl.interface.dictionaryApp.tab.TabConfig;
DictObj Simulink.interface.Dictionary;
end 

properties ( Access = private )
SpreadsheetComponent;
SelectedNodes;
TabToNodesMap;
TabToVisibleColumnsMap;
CommonTabIds cell;
PlatformSpecificTabs sl.interface.dictionaryApp.tab.TabConfig;
CurrentTabId;
TabAdapter;
SelectedPlatformId;
PlatformCustomizer;
DictToSpreadsheetRegistry;
Studio sl.interface.dictionaryApp.StudioApp;
NodeClassToGenericNodePropertiesMap;
end 


methods ( Static, Access = public )
function handleTabChanged( ~, tabId, this )
if ~isequal( tabId, this.CurrentTabId )
this.clearSelectedNodeCache(  );
this.changeTab( tabId );
end 
end 
end 


methods ( Static, Access = public )
function result = handleSelectionChange( ~, selectedNodes, this )
result = [  ];
this.cacheSelectedNodes( selectedNodes );
end 

function canAddChildren = canAddChildren( selectedNode )
canAddChildren = ~isempty( selectedNode ) &&  ...
isa( selectedNode, 'sl.interface.dictionaryApp.node.InterfaceNode' ) ||  ...
isa( selectedNode, 'sl.interface.dictionaryApp.node.StructTypeNode' );
end 
end 


methods ( Access = public )
function this = List( ssComp, dictObj, platformId, studio )

this.SpreadsheetComponent = ssComp;
this.DictObj = dictObj;
this.SelectedPlatformId = platformId;
this.Studio = studio;
this.getPlatformCustomizer(  );
this.SelectedNodes = [  ];


this.setCommonTabIds(  );
this.populateTabConfigForSelectedPlatform(  );
this.CurrentTabId = this.Tabs( 1 ).Id;
this.TabAdapter = this.constructTabAdapter( this.CurrentTabId );



this.NodeClassToGenericNodePropertiesMap = containers.Map(  );


this.initializeMapsAndRegistry(  );

this.addTabsToSpreadsheetComponent(  );


this.TabToVisibleColumnsMap = containers.Map(  );
this.initializeTabToVisibleColumnsMap(  );


this.initColumns(  );
this.SpreadsheetComponent.enableHierarchicalView( true );
this.SpreadsheetComponent.setTitle(  ...
message( 'interface_dictionary:common:GuiTitle' ).getString(  ) );
end 

function children = getChildren( this, ~, ~, ~ )

tabId = this.CurrentTabId;
if isempty( this.TabToNodesMap ) || ~this.TabToNodesMap.isKey( tabId )
nodes = this.TabAdapter.getNodes(  );
this.initializeMapAndRegistryForTab( tabId, nodes );
end 

children = [  ];
values = this.TabToNodesMap( tabId ).values;
if ~isempty( values )
children = [ values{ : } ];
end 

columns = this.getVisibleColumns(  );
this.displayColumns( columns );
end 

function setCurrentTabIdByName( this, tabId )
for tabIdx = 1:numel( this.Tabs )
tabInfo = this.Tabs( tabIdx );
if strcmp( tabInfo.Id, tabId )
if ~isequal( ( tabIdx - 1 ), this.SpreadsheetComponent.getCurrentTab(  ) )
this.SpreadsheetComponent.setCurrentTab( tabIdx - 1 );
break ;
end 
end 
end 
end 

function tabId = getTab( this )
tabId = this.CurrentTabId;
end 

function tabIdx = getTabIdx( this )
for tabIdx = 1:numel( this.Tabs )
tabInfo = this.Tabs( tabIdx );
if isequal( tabInfo.Id, this.CurrentTabId )
return ;
end 
end 
tabIdx = 0;
end 

function addElement( this, elementInfo )
tabAdapter = this.getTabAdapter(  );
if this.isChildElementType( elementInfo )
if this.isNodeSelectedInSpreadsheet(  )
selectedNode = getSelectedNodeForAddElement( this );
childNodeIsSelected = ~this.canAddChildren( selectedNode );
if childNodeIsSelected

parentNode = selectedNode.getParentNode(  );
position =  ...
sl.interface.dictionaryApp.list.DragNDropHelper.getIndexOf( selectedNode ) + 1;
else 
parentNode = selectedNode;

position = 1;
end 
assert( this.canAddChildren( parentNode ), 'Expected to be able to add child element to parent node.' )
tabAdapter.addEntry( elementInfo, parentNode, position );
else 
assert( false, 'Should not be able to add child elements without selecting parent or another child.' );
end 
else 

tabAdapter.addEntry( elementInfo );
end 
end 

function deleteSelectedNodes( this )
selectedNodes = this.getSelectedNodes(  );
tabAdapter = this.getTabAdapter(  );
for ii = 1:length( selectedNodes )
selectedNode = selectedNodes{ ii };
tabAdapter.deleteEntry( selectedNode );
end 
end 

function tabChanged( this, tabId )
if ~isequal( tabId, this.CurrentTabId )
this.clearSelectedNodeCache(  );
this.changeTab( tabId );
end 
end 

function tabAdapter = getTabAdapter( this )
if ~strcmp( this.TabAdapter.getTabId(  ), this.CurrentTabId )

this.TabAdapter = this.constructTabAdapter(  );
end 
tabAdapter = this.TabAdapter;
end 

function tabAdapter = constructTabAdapter( this, tabId )
if nargin < 2

tabId = this.CurrentTabId;
end 
if this.isPlatformSpecificTab( tabId )
tabAdapter =  ...
this.PlatformCustomizer.getTabAdapter( tabId );
else 

platformMappingKind = this.getPlatformMappingKind(  );
tabAdapter =  ...
sl.interface.dictionaryApp.tab.AbstractArchTabAdapter.getTabAdapter(  ...
this.DictObj, platformMappingKind, tabId, this.Studio, this );
end 
end 

function cacheSelectedNodes( this, selectedNodes )
if ~isempty( selectedNodes ) && ~iscell( selectedNodes )


selectedNodes = { selectedNodes };
end 
this.SelectedNodes = selectedNodes;
end 

function clearSelectedNodeCache( this )
this.cacheSelectedNodes( [  ] );
end 

function selection = getSelectedNodes( this )
selection = this.SelectedNodes;
end 

function selectedNodeNames = getSelectedNodeNames( this )
selectedNodeNames = {  };
selectedNodes = this.getSelectedNodes(  );
if ~isempty( selectedNodes )
selectedNodeNames = cellfun( @( node )node.Name, selectedNodes,  ...
'UniformOutput', false );
end 
end 

function prepareForRefreshAfterAdd( this, entryName, spreadsheetNode, spreadsheetTabId )

entryNameToNodeObjMap = this.TabToNodesMap( spreadsheetTabId );
entryNameToNodeObjMap( entryName ) = spreadsheetNode;%#ok

if strcmp( spreadsheetTabId, this.getTab(  ) )

nodeToSelect = { spreadsheetNode };
this.selectNode( nodeToSelect );
else 


this.selectNode( this.getSelectedNodes(  ) );
end 
end 

function prepareForRefreshAfterDelete( this, deletedNodeName, spreadsheetTabId )

entryNameToNodeObjMap = this.TabToNodesMap( spreadsheetTabId );
if entryNameToNodeObjMap.isKey( deletedNodeName )

deletedNodeObj = entryNameToNodeObjMap( deletedNodeName );
displayNameOfDeletedNode = deletedNodeObj.Name;


remove( entryNameToNodeObjMap, deletedNodeName );


selectedNodeNames = this.getSelectedNodeNames(  );
isSelectedNodeDeleted = any( ismember( selectedNodeNames, displayNameOfDeletedNode ) );
if isSelectedNodeDeleted

this.selectNode( {  } );
else 


this.selectNode( this.getSelectedNodes(  ) );
end 
end 
end 

function dlgStruct = getDialogSchema( ~, ~ )
filterWidget.Type = 'spreadsheetfilter';
filterWidget.Tag = 'spreadsheetfilter';
filterWidget.PlaceholderText = DAStudio.message( 'Simulink:studio:DataView_default_filter' );
filterWidget.Clearable = true;
filterWidget.RowSpan = [ 1, 1 ];
filterWidget.ColSpan = [ 3, 3 ];

dlgStruct.LayoutGrid = [ 1, 3 ];
dlgStruct.ColStretch = [ 0, 1, 0 ];
dlgStruct.DialogTitle = '';
dlgStruct.IsScrollable = false;
dlgStruct.Items = { filterWidget };
dlgStruct.StandaloneButtonSet = { '' };
dlgStruct.EmbeddedButtonSet = { '' };
end 

function refreshList( this, changesReportObj )

this.SpreadsheetComponent.update( true );
if isa( changesReportObj, 'sl.interface.dictionaryApp.observer.SLDDChangesReport' )





this.refreshListFromSLDD( changesReportObj.ChangesReport );
elseif ~isempty( this.PlatformCustomizer )

this.PlatformCustomizer.refreshSpreadsheetList( this, changesReportObj );

this.refreshPIDialog(  );
end 
this.SpreadsheetComponent.update( true );
end 

function forceRefreshList( this )
this.TabAdapter = this.constructTabAdapter( this.CurrentTabId );
this.repopulateTabToNodesMap(  );
this.initializeTabToVisibleColumnsMap(  );
this.SpreadsheetComponent.update( true );
end 

function refreshTabs( this, platformId )
if ~strcmp( this.SelectedPlatformId, platformId )

this.removePlatformSpecificTabs(  );
this.SelectedPlatformId = platformId;
this.getPlatformCustomizer(  );
this.populateTabConfigForSelectedPlatform(  );



this.forceRefreshList(  );
this.addPlatformSpecificTabsFromSpreadsheetComponent(  );
end 
end 

function showOptions( this )
if ~isempty( this.PlatformCustomizer )
this.PlatformCustomizer.showOptions(  );
end 
end 

function showHelp( this )
if ~isempty( this.PlatformCustomizer )
this.PlatformCustomizer.showHelp(  );
else 

helpview( fullfile( docroot, 'autosar', 'helptargets.map' ),  ...
'autosar_shared_dictionary' );
end 
end 

function close( this )
if ~isempty( this.PlatformCustomizer )
this.PlatformCustomizer.close(  );
end 
end 

function tabInfo = getCommonTabs( this )

tabInfo = sl.interface.dictionaryApp.tab.TabConfig.empty(  ...
0, length( this.CommonTabIds ) );
for idx = 1:length( this.CommonTabIds )
tabId = this.CommonTabIds{ idx };
tabInfo( idx ).Id = tabId;
tabInfo( idx ).Name = message( [ 'interface_dictionary:tabs:' ...
, tabId, 'Name' ] ).getString(  );
tabInfo( idx ).Tooltip = message( [ 'interface_dictionary:tabs:' ...
, tabId, 'Tooltip' ] ).getString(  );
end 
end 

function columns = getColumnsForCurrentTab( this )

tabAdapter = this.getTabAdapter(  );
columns = tabAdapter.getColumnNames(  );
end 

function visibleColumns = getVisibleColumns( this )

if isKey( this.TabToVisibleColumnsMap, this.CurrentTabId )
visibleColumns = this.TabToVisibleColumnsMap( this.CurrentTabId );
else 

visibleColumns = {  };
end 
end 

function setVisibleColumns( this, visibleColumns )


R36
this sl.interface.dictionaryApp.list.List
visibleColumns( 1, : )cell
end 
this.TabToVisibleColumnsMap( this.CurrentTabId ) = visibleColumns;

this.displayColumns( visibleColumns )
this.SpreadsheetComponent.update( true );
end 

function selectNode( this, node )
this.cacheSelectedNodes( node );
this.SpreadsheetComponent.view( node );
end 

function expandNode( this, node )
this.SpreadsheetComponent.expand( node, false );
end 

function setGenericNodePropertiesFromCache( this, node )


nodeClass = class( node );
if isKey( this.NodeClassToGenericNodePropertiesMap, nodeClass )

node.setPropertiesMap( this.NodeClassToGenericNodePropertiesMap( nodeClass ) );
if node.isHierarchical

childNodes = node.getHierarchicalChildren(  );

for i = 1:length( childNodes )
childNode = childNodes( i );
this.setGenericNodePropertiesFromCache( childNode );
end 
end 
else 

node.initializeGenericProperties(  );
this.NodeClassToGenericNodePropertiesMap( nodeClass ) = node.getPropertiesMap(  );
if node.isHierarchical
childNodes = node.getHierarchicalChildren(  );
if ~isempty( childNodes )

for i = 1:length( childNodes )
childNode = childNodes( i );
childNodeClass = class( childNode );
if ~isKey( this.NodeClassToGenericNodePropertiesMap, childNodeClass )

childNode.initializeGenericProperties(  );
this.NodeClassToGenericNodePropertiesMap( childNodeClass ) = childNode.getPropertiesMap(  );
else 

childNode.setPropertiesMap( this.NodeClassToGenericNodePropertiesMap( childNodeClass ) );
end 
end 
end 
end 
end 
end 

function refreshPIDialog( this )
selection = this.getSelectedNodes(  );
if ~isempty( selection )
if iscell( selection )
selection{ end  }.refreshDialog(  );
else 
selection.refreshDialog(  );
end 
end 
end 
end 

methods ( Access = public, Hidden )
function forceUpdateTabToNodesMap( this, modifiedNodeObj, newDictElementName, oldDictElementName, destinationTabId )

entryNameToNodeObjMap = this.TabToNodesMap( destinationTabId );
if entryNameToNodeObjMap.isKey( oldDictElementName )
remove( entryNameToNodeObjMap, oldDictElementName );
end 
entryNameToNodeObjMap( newDictElementName ) = modifiedNodeObj;%#ok

if isa( modifiedNodeObj, 'sl.interface.dictionaryApp.node.DesignNode' )

dictEntryObj = this.DictObj.getDDEntryObject( newDictElementName );
this.DictToSpreadsheetRegistry.updateDictToSpreadsheetRegistryForModifiedNode( dictEntryObj.UUID );
end 


this.selectNode( modifiedNodeObj );
pause( 0.001 )


this.SpreadsheetComponent.update( true );
end 
end 


methods ( Access = private )

function initializeMapsAndRegistry( this )




this.TabToNodesMap = containers.Map(  );
this.DictToSpreadsheetRegistry = sl.interface.dictionaryApp.list.DictToSpreadsheetRegistry( this );
for i = 1:length( this.Tabs )
tabConfig = this.Tabs( i );
tabId = tabConfig.Id;


tabAdapter = this.constructTabAdapter( tabId );
nodes = tabAdapter.getNodes(  );
this.initializeMapAndRegistryForTab( tabId, nodes );
end 
end 

function initializeMapAndRegistryForTab( this, tabId, nodes )

entryNameToNodeObjMap = containers.Map(  );
commonTabIds = { this.getCommonTabs(  ).Id };
for i = 1:length( nodes )




curNode = nodes{ i };
curNodeName = curNode.Name;
entryNameToNodeObjMap( curNodeName ) = curNode;


if ismember( tabId, commonTabIds )

this.DictToSpreadsheetRegistry.populateRegistryForNode( tabId, curNodeName );
end 
end 

this.TabToNodesMap( tabId ) = entryNameToNodeObjMap;
end 

function repopulateTabToNodesMap( this )

this.TabToNodesMap = containers.Map(  );
for i = 1:length( this.Tabs )
tabConfig = this.Tabs( i );
tabId = tabConfig.Id;


tabAdapter = this.constructTabAdapter( tabId );


nodes = tabAdapter.getNodes(  );
this.mapTabIdToNodes( tabId, nodes );
end 
end 

function initializeTabToVisibleColumnsMap( this )

for i = 1:length( this.Tabs )
tabConfig = this.Tabs( i );
tabId = tabConfig.Id;
if ~isKey( this.TabToVisibleColumnsMap, tabId )



tabAdapter = this.constructTabAdapter( tabId );


visibleColumns = tabAdapter.getColumnNames(  );
this.TabToVisibleColumnsMap( tabId ) = visibleColumns;
end 
end 
end 

function mapTabIdToNodes( this, tabId, nodes )
entryNameToNodeObjMap = containers.Map(  );
for nodeIdx = 1:length( nodes )
curNode = nodes{ nodeIdx };
entryNameToNodeObjMap( curNode.Name ) = curNode;
end 

this.TabToNodesMap( tabId ) = entryNameToNodeObjMap;
end 

function isNodeSelected = isNodeSelectedInSpreadsheet( this )
selectedNodes = this.getSelectedNodes(  );
isNodeSelected = ~isempty( selectedNodes );
end 

function selectedNode = getSelectedNodeForAddElement( this )
selectedNode = [  ];
selectedNodes = this.getSelectedNodes(  );
assert( length( selectedNodes ) < 2, 'Cannot add element if multiple nodes are selected' );
if ~isempty( selectedNodes )

selectedNode = selectedNodes{ 1 };
end 
end 

function nodes = getNodesForCurrentTab( this )
tabAdapter = this.getTabAdapter(  );
nodes = tabAdapter.getNodes(  );
end 

function tabName = getTabName( this )
for tabIdx = 1:numel( this.Tabs )
tabInfo = this.Tabs( tabIdx );
if isequal( tabInfo.Id, this.CurrentTabId )
tabName = tabInfo.Name;
return ;
end 
end 
tabName = '';
end 

function initColumns( this )



columns = this.getColumnsForCurrentTab(  );
sortColumn = '';
groupColumn = '';
isAscending = true;
this.SpreadsheetComponent.setColumns( columns, sortColumn, groupColumn, isAscending );
end 

function displayColumns( this, columns )

sortColumn = columns{ 1 };
groupColumn = '';
isAscending = true;
this.SpreadsheetComponent.setColumns( columns, sortColumn, groupColumn, isAscending );
end 

function changeTab( this, tabId )
this.CurrentTabId = tabId;
this.TabAdapter = this.getTabAdapter(  );
cols = this.getVisibleColumns(  );
assert( ~isempty( cols ), 'Visible columns should not return empty.' )
this.displayColumns( cols );
this.SpreadsheetComponent.update( true );
end 

function setCommonTabIds( this )

this.CommonTabIds = { 'InterfacesTab', 'DataTypesTab' };
if slfeature( 'InterfaceDictConstants' )
this.CommonTabIds{ end  + 1 } = 'ConstantsTab';
end 
end 

function populateTabConfigForSelectedPlatform( this )

commonTabs = this.getCommonTabs;
if ~isempty( this.PlatformCustomizer )

platformSpecificTabs = this.PlatformCustomizer.getPlatformSpecificTabs(  );
this.PlatformSpecificTabs = platformSpecificTabs;
this.Tabs = [ commonTabs, platformSpecificTabs ];
else 
this.Tabs = commonTabs;
end 
end 

function addTabsToSpreadsheetComponent( this )
for i = 1:length( this.Tabs )
tabData = this.Tabs( i );
this.SpreadsheetComponent.addTab( tabData.Name, tabData.Id, tabData.Tooltip );
end 
end 

function addPlatformSpecificTabsFromSpreadsheetComponent( this )
for i = 1:length( this.PlatformSpecificTabs )
tabData = this.PlatformSpecificTabs( i );
this.SpreadsheetComponent.addTab( tabData.Name, tabData.Id, tabData.Tooltip );
end 
end 

function removePlatformSpecificTabs( this )

selectedTabIdBeforeTabRemoval = this.CurrentTabId;
for idx = 1:length( this.PlatformSpecificTabs )
tabData = this.PlatformSpecificTabs( idx );
this.SpreadsheetComponent.removeNamedTab( tabData.Id );
end 


this.PlatformSpecificTabs = sl.interface.dictionaryApp.tab.TabConfig.empty(  );

if ~any( contains( this.CommonTabIds, selectedTabIdBeforeTabRemoval ) )


this.changeTab( this.CommonTabIds{ end  } );
end 
end 

function getPlatformCustomizer( this )
this.PlatformCustomizer =  ...
sl.interface.dictionaryApp.platform.AbstractPlatformCustomizer.getPlatformCustomizer(  ...
this.SelectedPlatformId, this.DictObj );
end 

function platformMappingKind = getPlatformMappingKind( this )
platformMappingKind =  ...
sl.interface.dictionaryApp.platform.AbstractPlatformCustomizer.getPlatformMappingKind(  ...
this.DictObj, this.SelectedPlatformId );
end 

function tf = isPlatformSpecificTab( this, tabId )
if isempty( this.PlatformCustomizer )
tf = false;
else 
tf = ismember( tabId, this.PlatformCustomizer.PlatformTabIds );
end 
end 

function refreshListFromSLDD( this, changesReport )
R36
this sl.interface.dictionaryApp.list.List
changesReport( 1, 1 )struct
end 
expectedFields = { 'EntryAdded';'EntryDeleted';'EntryModified' };
assert( isequal( fields( changesReport ), expectedFields ), 'Unexpected fields in changeReport' );

if ~isempty( changesReport.EntryAdded )

[ dictEntry, spreadsheetNode, spreadsheetTabId ] =  ...
this.DictToSpreadsheetRegistry.getDictEntryAndNodeObj( changesReport.EntryAdded );
entryName = dictEntry.Name;
this.prepareForRefreshAfterAdd( entryName, spreadsheetNode, spreadsheetTabId );
elseif ~isempty( changesReport.EntryDeleted )
this.deleteEntryFromCurrentList( changesReport.EntryDeleted );
elseif ~isempty( changesReport.EntryModified )

this.modifyEntryFromCurrentList( changesReport.EntryModified );
else 
assert( false, 'ChangesReport was created without any changes' )
end 
end 

function deleteEntryFromCurrentList( this, deletedEntries )


for i = 1:height( deletedEntries )
deletedEntry = deletedEntries{ 1, i };
deletedUUID = deletedEntry;
[ deletedNodeName, spreadsheetTabId ] = this.DictToSpreadsheetRegistry.getSpreadsheetInfoFromDictUUID( deletedUUID );
this.prepareForRefreshAfterDelete( deletedNodeName, spreadsheetTabId );
end 
end 

function modifyEntryFromCurrentList( this, modifiedEntry )



[ dictEntry, modifiedNode, tabId, nodeToSelect ] =  ...
this.getModifiedEntryInfoFromUUID( modifiedEntry );



entryNameToNodeObjMap = this.TabToNodesMap( tabId );
entryNameToNodeObjMap( dictEntry.Name ) = modifiedNode;%#ok


if this.canAddChildren( modifiedNode )
this.SpreadsheetComponent.update( true );
pause( 0.001 );
this.expandNode( modifiedNode );
end 
this.selectNode( nodeToSelect );
pause( 0.001 )
end 

function [ dictEntry, modifiedNode, tabId, nodeToSelect, modType ] =  ...
getModifiedEntryInfoFromUUID( this, modifiedEntry )


modifiedEntryUUID = modifiedEntry{ 1 };
nodeNameBeforeRename =  ...
this.DictToSpreadsheetRegistry.getSpreadsheetInfoFromDictUUID( modifiedEntryUUID );
[ dictEntry, modifiedNode, tabId ] =  ...
this.DictToSpreadsheetRegistry.getDictEntryAndNodeObj( modifiedEntry );


entryNameToNodeObjMap = this.TabToNodesMap( tabId );
if this.canAddChildren( modifiedNode ) &&  ...
isKey( entryNameToNodeObjMap, dictEntry.Name )
modType = 'childElementModified';
modifiedNodeChildren = modifiedNode.getHierarchicalChildren(  );
unmodifiedNode = entryNameToNodeObjMap( dictEntry.Name );
try 
unmodifiedNodeChildren = unmodifiedNode.getHierarchicalChildren(  );
catch 




nodeToSelect = { modifiedNode };
return 
end 
else 

modType = 'renameTopNode';
end 


switch modType
case 'renameTopNode'
this.DictToSpreadsheetRegistry.updateDictToSpreadsheetRegistryForModifiedNode( modifiedEntryUUID );
nodeToSelect = { modifiedNode };
entryNameToNodeObjMap( nodeNameBeforeRename ) = [  ];%#ok, cleanup renamed top node
case 'childElementModified'
if length( modifiedNodeChildren ) > length( unmodifiedNodeChildren )

modType = 'childAdded';
addedNodeName = setdiff( { modifiedNodeChildren.Name }, { unmodifiedNodeChildren.Name } );
addedNode = strcmp( { modifiedNodeChildren.Name }, addedNodeName{ 1 } );
nodeToSelect = { modifiedNodeChildren( addedNode ) };
elseif length( modifiedNodeChildren ) < length( unmodifiedNodeChildren )

modType = 'childDeleted';

if isempty( modifiedNodeChildren )

nodeToSelect = { modifiedNode };
return ;
end 


modifiedNodeChildrenNames = cell( length( modifiedNodeChildren ), 1 );
for i = 1:length( modifiedNodeChildren )
modifiedNodeChildrenNames{ i } = modifiedNodeChildren( i ).Name;
end 


unmodifiedNodeChildrenNames = cell( length( unmodifiedNodeChildren ), 1 );
for i = 1:length( unmodifiedNodeChildren )


unmodifiedNodeChildrenNames{ i } = unmodifiedNodeChildren( i ).getCachedName(  );
end 
assert( ~isempty( unmodifiedNodeChildrenNames{ 1 } ), 'Cached node names should not be empty.' );


removedNodes = setdiff( unmodifiedNodeChildrenNames, modifiedNodeChildrenNames );
removedNodeIdx = find( contains( unmodifiedNodeChildrenNames, removedNodes ) );


if removedNodeIdx( 1 ) > 1
nodeIdxToSelect = removedNodeIdx( 1 ) - 1;
else 
nodeIdxToSelect = 1;
end 
nodeToSelect = { modifiedNodeChildren( nodeIdxToSelect ) };
else 
modType = 'childModified';
assert( isequal( length( modifiedNodeChildren ), length( unmodifiedNodeChildren ) ),  ...
'Expected number of child nodes to be unchanged.' );
nodeToSelect = { modifiedNode };
end 
otherwise 
assert( false, 'Unexpected modification type.' );
end 
end 
end 

methods ( Static, Access = private )
function isChildElementType = isChildElementType( elementInfo )
childElementTypeIds = { 'InterfaceElement', 'StructureElement' };
isChildElementType = any( strcmp( childElementTypeIds, elementInfo ) );
end 
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpWAYvux.p.
% Please follow local copyright laws when handling this file.

