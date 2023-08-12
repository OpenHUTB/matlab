classdef Dialog < systemcomposer.internal.mixin.ModelClose &  ...
systemcomposer.internal.mixin.CenterDialog &  ...
systemcomposer.internal.mixin.BlockDelete





properties 
BlockHdl;
MappingsTable;
InputTree;
OutputTree;
Adaptation;
unknownElems;
OutputPortInterf;
IsSWArch;
end 

properties ( Access = private )
currTableRow = 0;
currInputTreeSelection = '';
currOutputTreeSelection = '';
lastSelectedTree = '';


dirty = false;
transientStatusMsg = '';
inputTreeSearchText = '';
outputTreeSearchText = '';
end 

methods ( Static )
function launch( blkHdl )
if ischar( blkHdl )
blkHdl = get_param( blkHdl, 'handle' );
end 
dlg = systemcomposer.internal.adapter.Dialog.dialogFor( blkHdl );
if isempty( dlg ) || ~ishandle( dlg )
obj = systemcomposer.internal.adapter.Dialog( blkHdl );
dlg = DAStudio.Dialog( obj );
systemcomposer.internal.adapter.Dialog.dialogFor( blkHdl, dlg );
end 
dlg.show(  );
dlg.refresh(  );
end 

function dlg = dialogFor( blkHdl, dlg )
persistent DialogMap;
if isempty( DialogMap )
DialogMap = containers.Map( 'KeyType', 'double', 'ValueType', 'any' );
end 
if nargin > 1
if DialogMap.isKey( blkHdl )
DialogMap.remove( blkHdl );
end 
DialogMap( blkHdl ) = dlg;
else 
if DialogMap.isKey( blkHdl )
dlg = DialogMap( blkHdl );
else 
dlg = [  ];
end 
end 
end 
end 

methods 
function this = Dialog( blkH )



this.BlockHdl = blkH;


this.IsSWArch = any( strcmpi( get_param( get_param( this.BlockHdl, 'Parent' ), 'SimulinkSubDomain' ),  ...
{ 'SoftwareArchitecture', 'AUTOSARArchitecture' } ) );


this.registerCloseListener( get_param( bdroot( blkH ), 'Handle' ) );


this.registerDeleteListener( { blkH } );


this.Adaptation = systemcomposer.internal.adapter.Adaptation( blkH );


this.MappingsTable = systemcomposer.internal.adapter.MappingsTable( blkH );

if ~this.MappingsTable.isConsistent(  ) && ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge )


this.resetToFactoryDefault(  );
end 


outArchPort = this.getArchPortWithName( this.getOutputPortName );
this.OutputPortInterf = systemcomposer.internal.getWrapperForImpl( outArchPort.getPortInterface(  ) );


this.InputTree = systemcomposer.internal.adapter.InterfaceTree( this, blkH, 'input' );
this.OutputTree = systemcomposer.internal.adapter.InterfaceTree( this, blkH, 'output' );

if this.isInBusCreationMode && ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge )




this.OutputTree.pruneUnconnectedOutputBEPs(  );
end 
end 

function schema = getDialogSchema( this )


descSchema = this.getDescriptionSchema(  );
descSchema.RowSpan = [ 1, 1 ];
descSchema.ColSpan = [ 1, 2 ];

mappingSchema = this.getMappingSchema(  );
mappingSchema.RowSpan = [ 2, 2 ];
mappingSchema.ColSpan = [ 2, 2 ];

adaptationsSchema = this.getAdaptationsSchema(  );
adaptationsSchema.RowSpan = [ 2, 2 ];
adaptationsSchema.ColSpan = [ 1, 1 ];

panel.Type = 'panel';
panel.Tag = 'main_panel';
panel.Items = { descSchema, adaptationsSchema, mappingSchema };
panel.LayoutGrid = [ 2, 2 ];
panel.RowStretch = [ 0, 1 ];
panel.ColStretch = [ 1, 1 ];

if this.dirty
schema.DialogTitle = DAStudio.message( 'SystemArchitecture:Adapter:MappingAppNameUnsavedChanges' );
else 
schema.DialogTitle = DAStudio.message( 'SystemArchitecture:Adapter:MappingAppName' );
end 
schema.DisplayIcon = fullfile( matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'ARCHITECTURE', 'Adapter.png' );
schema.Items = { panel };
schema.DialogTag = 'system_composer_interface_adapter';
schema.Source = this;
schema.HelpMethod = 'handleClickHelp';
schema.HelpArgs = {  };
schema.HelpArgsDT = {  };
schema.OpenCallback = @( dlg )this.handleOpenDialog( dlg );
schema.CloseMethod = 'handleCloseDialog';
schema.CloseMethodArgs = { '%dialog', '%closeaction' };
schema.CloseMethodArgsDT = { 'handle', 'char' };
schema.PreApplyMethod = 'preApply';
schema.PreApplyArgs = {  };
schema.PreApplyArgsDT = {  };
schema.MinMaxButtons = true;
schema.ShowGrid = false;
schema.DisableDialog = false;
schema.StandaloneButtonSet = { 'Ok', 'Cancel', 'Help' };
schema.DefaultOk = false;
schema.ExplicitShow = true;
end 
end 


methods ( Access = private )
function schema = getDescriptionSchema( ~ )


desc.Tag = 'txtDesc';
desc.Type = 'text';
desc.WordWrap = true;
desc.Name = DAStudio.message( 'SystemArchitecture:Adapter:DialogDesc' );

schema.Type = 'group';
schema.Name = '';
schema.Items = { desc };
end 

function schema = getAdaptationsSchema( this )


tableData = this.getTableDataSchema(  );
nRows = size( tableData, 1 );
nCols = size( tableData, 2 );

if this.currTableRow == 0 && nRows > 0
this.currTableRow = 1;
end 

mappings.Type = 'table';
mappings.Tag = 'currentMappingsTable';
mappings.Size = [ nRows, nCols ];
mappings.Data = tableData;
mappings.Grid = true;
mappings.SelectionBehavior = 'Row';
mappings.DialogRefresh = true;
mappings.HeaderVisibility = [ 1, 1 ];
mappings.ColHeader = {  ...
DAStudio.message( 'SystemArchitecture:Adapter:Input' ),  ...
DAStudio.message( 'SystemArchitecture:Adapter:Output' ) };
mappings.RowHeader = arrayfun( @( x )num2str( x ), 1:nRows, 'UniformOutput', false );
mappings.ColumnHeaderHeight = 2;
mappings.RowHeaderWidth = 3;
mappings.ColumnStretchable = ones( 1, nCols );
mappings.Editable = false;
mappings.CurrentItemChangedCallback = @( d, r, c )this.handleMappingsTableSelectionChanged( d, r, c );
if this.currTableRow > 0
mappings.SelectedRow = this.currTableRow - 1;
else 
mappings.SelectedRow =  - 1;
end 
mappings.RowSpan = [ 2, 2 ];
mappings.ColSpan = [ 1, 3 ];
mappings.Enabled = ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge );

remove.Type = 'pushbutton';
remove.Tag = 'removeSelectedMapping';
remove.Name = DAStudio.message( 'SystemArchitecture:Adapter:RemoveMapping' );
remove.ToolTip = '';
remove.Source = this;
remove.ObjectMethod = 'handleClickRemoveMapping';
remove.MethodArgs = { '%dialog' };
remove.ArgDataTypes = { 'handle' };
remove.RowSpan = [ 3, 3 ];
remove.ColSpan = [ 1, 1 ];
remove.DialogRefresh = true;
remove.Enabled = ( this.currTableRow > 0 ) && ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge );



msg = '';
needsUndo = false;

if ~isempty( this.transientStatusMsg )
msg = this.transientStatusMsg;
this.transientStatusMsg = '';
needsUndo = true;

elseif this.currTableRow > 0 && this.currTableRow <= this.MappingsTable.numEntries
currRow = tableData( this.currTableRow, : );
currInput = currRow{ 1 }.Value;
currOutput = currRow{ 2 }.Value;

if this.isUnknownElem( currInput )
msg = DAStudio.message( 'SystemArchitecture:Adapter:UnknownElement', currInput );
end 
if this.isUnknownElem( currOutput )
if ~isempty( msg )
msg = [ msg, newline ];
end 
msg = [ msg, DAStudio.message( 'SystemArchitecture:Adapter:UnknownElement', currOutput ) ];
end 
end 


if nRows == 0
msg = DAStudio.message( 'SystemArchitecture:Adapter:MappingsTableEmptyWarning' );
needsUndo = false;
end 

unknownElemMsg.Type = 'text';
unknownElemMsg.Tag = 'textBelowMappingsTable';
unknownElemMsg.Name = msg;
unknownElemMsg.WordWrap = true;

unknownElemGroup.Type = 'group';
unknownElemGroup.Items = { unknownElemMsg };
unknownElemGroup.RowSpan = [ 3, 3 ];
unknownElemGroup.ColSpan = [ 2, 3 ];

if needsUndo
undoLink.Type = 'hyperlink';
undoLink.Name = DAStudio.message( 'SystemArchitecture:Adapter:Undo' );
undoLink.Tag = 'undoLink';
undoLink.Source = this;
undoLink.ObjectMethod = 'handleClickUndo';
undoLink.MethodArgs = {  };
undoLink.ArgDataTypes = {  };
undoLink.Graphical = true;
undoLink.DialogRefresh = true;

unknownElemGroup.Items = { unknownElemMsg, undoLink };
end 

conversion.Type = 'combobox';
conversion.Tag = 'conversionChoice';
conversion.Name = DAStudio.message( 'SystemArchitecture:Adapter:Conversion' );
conversion.NameLocation = 1;
conversion.Entries = this.Adaptation.getSupportedModes(  );
conversion.Value = this.Adaptation.getMode(  );
conversion.Source = this;
conversion.ObjectMethod = 'handleInterfaceConversionChoiceChanged';
conversion.MethodArgs = { '%value', '%dialog' };
conversion.ArgDataTypes = { 'char', 'handle' };
conversion.DialogRefresh = true;
conversion.RowSpan = [ 1, 1 ];
conversion.ColSpan = [ 1, 2 ];
if this.IsSWArch
conversion.ToolTip = DAStudio.message( 'SystemArchitecture:Adapter:SWConversionTooltip' );
else 
conversion.ToolTip = DAStudio.message( 'SystemArchitecture:Adapter:ConversionTooltip' );
end 
conversion.Enabled = true;

conversionOptions.Type = 'pushbutton';
conversionOptions.Tag = 'conversionOptionsButton';
conversionOptions.Name = '';
conversionOptions.FilePath = fullfile( matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'Configuration.png' );
conversionOptions.ToolTip = '';
conversionOptions.Source = this;
conversionOptions.ObjectMethod = 'handleConversionOptionsClick';
conversionOptions.MethodArgs = { '%dialog' };
conversionOptions.ArgDataTypes = { 'handle' };
conversionOptions.RowSpan = [ 1, 1 ];
conversionOptions.ColSpan = [ 3, 3 ];
conversionOptions.DialogRefresh = true;
conversionOptions.Enabled = this.Adaptation.isMode( this.Adaptation.ModeEnum.RateTransition );

schema.Type = 'group';
schema.Name = DAStudio.message( 'SystemArchitecture:Adapter:Mappings' );
schema.Items = { mappings, remove, unknownElemGroup, conversion, conversionOptions };
schema.LayoutGrid = [ 3, 3 ];
schema.RowStretch = [ 1, 0, 0 ];
schema.ColStretch = [ 0, 1, 0 ];
end 

function schema = getTableDataSchema( this )



this.crossValidateMappingsWithTreeElements(  );

nRows = this.MappingsTable.numEntries;
nCols = 2;





Highlight = [ 255, 226, 245 ];
Error = [ 255, 0, 0 ];
NormalBG = [ 255, 255, 255 ];
NormalFG = [ 0, 0, 0 ];

schema = cell( nRows, nCols );
for r = 1:nRows

[ inVal, outVal ] = this.MappingsTable.getMapping( r );

inp.Type = 'edit';
inp.Value = inVal;
inp.BackgroundColor = NormalBG;
inp.ForegroundColor = NormalFG;

out.Type = 'edit';
out.Value = outVal;
out.BackgroundColor = NormalBG;


if ( strcmp( this.lastSelectedTree, 'input' ) &&  ...
strcmp( inVal, this.currInputTreeSelection ) ) ||  ...
( strcmp( this.lastSelectedTree, 'output' ) &&  ...
strcmp( outVal, this.currOutputTreeSelection ) )

inp.BackgroundColor = Highlight;
out.BackgroundColor = Highlight;
end 



if this.isUnknownElem( inVal )
inp.ForegroundColor = Error;
end 
if this.isUnknownElem( outVal )
out.ForegroundColor = Error;
end 

schema{ r, 1 } = inp;
schema{ r, 2 } = out;
end 
end 

function schema = getMappingSchema( this )


outMapName = this.getCurrentMappingForInput(  );
outMapNameMsg = '';
if ~isempty( outMapName )
outMapNameMsg = DAStudio.message( 'SystemArchitecture:Adapter:CurrentMapping',  ...
this.currInputTreeSelection, outMapName );
end 

inMapName = this.getCurrentMappingForOutput(  );
inMapNameMsg = '';
if ~isempty( inMapName )
inMapNameMsg = DAStudio.message( 'SystemArchitecture:Adapter:CurrentMapping',  ...
this.currOutputTreeSelection, inMapName );
end 

inputTreeSearch.Type = 'edit';
inputTreeSearch.Tag = 'inputTreeSearchBox';
inputTreeSearch.PlaceholderText = DAStudio.message( 'SystemArchitecture:Adapter:SearchInputs' );
inputTreeSearch.Clearable = true;
inputTreeSearch.Graphical = true;
inputTreeSearch.RespondsToTextChanged = true;
inputTreeSearch.ObjectMethod = 'handleInputTreeSearchTextChanged';
inputTreeSearch.MethodArgs = { '%dialog', '%value' };
inputTreeSearch.ArgDataTypes = { 'handle', 'char' };
inputTreeSearch.Source = this;
inputTreeSearch.DialogRefresh = false;
inputTreeSearch.RowSpan = [ 1, 1 ];
inputTreeSearch.ColSpan = [ 1, 1 ];

inputTree.Type = 'tree';
inputTree.Name = DAStudio.message( 'SystemArchitecture:Adapter:SelectInput' );
inputTree.Tag = 'inputTree';
inputTree.TreeModel = this.InputTree.getTreeModel( this.inputTreeSearchText );
inputTree.TreeMultiSelect = false;
inputTree.ExpandTree = true;
inputTree.Source = this;
inputTree.ObjectMethod = 'handleSelectInputTreeNode';
inputTree.MethodArgs = { '%value' };
inputTree.ArgDataTypes = { 'mxArray' };
inputTree.TreeEditCallback = @( d, tag, id, elem )this.handleRequestTreeItemEdit( d, tag, id, elem );
inputTree.TreeValueChangedCallback = @( d, tag, id, elem, val )this.handleTreeEditComplete( d, tag, id, elem, val );
inputTree.DialogRefresh = true;
inputTree.RowSpan = [ 2, 4 ];
inputTree.ColSpan = [ 1, 1 ];

inputCurrMapping.Type = 'text';
inputCurrMapping.Tag = 'inputTreeMsg';
inputCurrMapping.Name = outMapNameMsg;
inputCurrMapping.WordWrap = true;
inpGroup.Type = 'group';
inpGroup.Items = { inputCurrMapping };
inpGroup.RowSpan = [ 5, 5 ];
inpGroup.ColSpan = [ 1, 1 ];


enableMapButton = true;
if strcmp( inMapName, this.currInputTreeSelection ) && strcmp( outMapName, this.currOutputTreeSelection )


btnName = DAStudio.message( 'SystemArchitecture:Adapter:Map' );
enableMapButton = false;
elseif ~isempty( inMapName ) || ~isempty( outMapName )
btnName = DAStudio.message( 'SystemArchitecture:Adapter:MapOverwrite' );
else 
btnName = DAStudio.message( 'SystemArchitecture:Adapter:Map' );
end 

createMapping.Type = 'pushbutton';
createMapping.Tag = 'createNewMapping';
createMapping.Name = btnName;
createMapping.ToolTip = '';
createMapping.Source = this;
createMapping.ObjectMethod = 'handleClickCreateNewMapping';
createMapping.MethodArgs = { '%dialog' };
createMapping.ArgDataTypes = { 'handle' };
createMapping.RowSpan = [ 1, 1 ];
createMapping.ColSpan = [ 1, 1 ];
createMapping.DialogRefresh = true;
createMapping.Visible = ~this.isInBusCreationMode;
createMapping.Enabled = enableMapButton && ~isempty( this.currInputTreeSelection ) ...
 && ~isempty( this.currOutputTreeSelection ) && ~this.isInBusCreationMode ...
 && ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge );

addToOutputTreeBtn.Type = 'pushbutton';
addToOutputTreeBtn.Tag = 'addToOutputTreeBtn';
addToOutputTreeBtn.FilePath = fullfile( matlabroot, 'toolbox', 'sysarch', 'sysarch',  ...
'+systemcomposer', '+internal', '+adapter', 'resources', 'forward_24.png' );
addToOutputTreeBtn.ToolTip = DAStudio.message( 'SystemArchitecture:Adapter:addToOutputTreeBtnTooltip' );
addToOutputTreeBtn.Source = this;
addToOutputTreeBtn.ObjectMethod = 'handleClickAddToOutputTree';
addToOutputTreeBtn.MethodArgs = { '%dialog' };
addToOutputTreeBtn.ArgDataTypes = { 'handle' };
addToOutputTreeBtn.RowSpan = [ 2, 2 ];
addToOutputTreeBtn.ColSpan = [ 1, 1 ];
addToOutputTreeBtn.DialogRefresh = true;
addToOutputTreeBtn.Enabled = this.isInBusCreationMode && ~isempty( this.currInputTreeSelection ) ...
 && ~this.isTreeNodeMapped( this.currInputTreeSelection ) && ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge );
addToOutputTreeBtn.Visible = this.isInBusCreationMode;

removeFromOutputTreeBtn.Type = 'pushbutton';
removeFromOutputTreeBtn.Tag = 'removeFromOutputTreeBtn';
removeFromOutputTreeBtn.FilePath = fullfile( matlabroot, 'toolbox', 'sysarch', 'sysarch',  ...
'+systemcomposer', '+internal', '+adapter', 'resources', 'failed_24.png' );
removeFromOutputTreeBtn.ToolTip = DAStudio.message( 'SystemArchitecture:Adapter:removeFromOutputTreeBtnTooltip' );
removeFromOutputTreeBtn.Source = this;
removeFromOutputTreeBtn.ObjectMethod = 'handleClickRemoveFromOutputTree';
removeFromOutputTreeBtn.MethodArgs = { '%dialog' };
removeFromOutputTreeBtn.ArgDataTypes = { 'handle' };
removeFromOutputTreeBtn.RowSpan = [ 3, 3 ];
removeFromOutputTreeBtn.ColSpan = [ 1, 1 ];
removeFromOutputTreeBtn.DialogRefresh = true;
removeFromOutputTreeBtn.Enabled = this.isInBusCreationMode && this.isOutputTreeDataElement( this.currOutputTreeSelection ) ...
 && ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge );
removeFromOutputTreeBtn.Visible = this.isInBusCreationMode;

buttonGroup.Type = 'panel';
buttonGroup.Tag = 'mappingSchemaButtonPanel';
buttonGroup.Items = { createMapping, addToOutputTreeBtn, removeFromOutputTreeBtn };
buttonGroup.LayoutGrid = [ 3, 1 ];
buttonGroup.RowStretch = [ 1, 1, 1 ];
buttonGroup.ColStretch = [ 1 ];%#ok<NBRAK2> 
buttonGroup.RowSpan = [ 3, 3 ];
buttonGroup.ColSpan = [ 2, 2 ];

outputTreeSearch.Type = 'edit';
outputTreeSearch.Tag = 'outputTreeSearchBox';
outputTreeSearch.PlaceholderText = DAStudio.message( 'SystemArchitecture:Adapter:SearchOutputs' );
outputTreeSearch.Clearable = true;
outputTreeSearch.Graphical = true;
outputTreeSearch.RespondsToTextChanged = true;
outputTreeSearch.ObjectMethod = 'handleOutputTreeSearchTextChanged';
outputTreeSearch.MethodArgs = { '%dialog', '%value' };
outputTreeSearch.ArgDataTypes = { 'handle', 'char' };
outputTreeSearch.Source = this;
outputTreeSearch.DialogRefresh = false;
outputTreeSearch.RowSpan = [ 1, 1 ];
outputTreeSearch.ColSpan = [ 3, 3 ];

outputTree.Type = 'tree';
outputTree.Name = DAStudio.message( 'SystemArchitecture:Adapter:SelectOutput' );
outputTree.Tag = 'outputTree';
outputTree.TreeModel = this.OutputTree.getTreeModel( this.outputTreeSearchText );
outputTree.TreeMultiSelect = false;
outputTree.ExpandTree = true;
outputTree.Source = this;
outputTree.ObjectMethod = 'handleSelectOutputTreeNode';
outputTree.MethodArgs = { '%value' };
outputTree.ArgDataTypes = { 'mxArray' };
outputTree.TreeEditCallback = @( d, tag, id, elem )this.handleRequestTreeItemEdit( d, tag, id, elem );
outputTree.TreeValueChangedCallback = @( d, tag, id, elem, val )this.handleTreeEditComplete( d, tag, id, elem, val );
outputTree.DialogRefresh = true;
outputTree.RowSpan = [ 2, 4 ];
outputTree.ColSpan = [ 3, 3 ];

outputCurrMapping.Type = 'text';
outputCurrMapping.Tag = 'outputTreeMsg';
outputCurrMapping.Name = inMapNameMsg;
outputCurrMapping.WordWrap = true;
outGroup.Type = 'group';
outGroup.Items = { outputCurrMapping };
outGroup.RowSpan = [ 5, 5 ];
outGroup.ColSpan = [ 3, 3 ];

schema.Type = 'group';
schema.Name = DAStudio.message( 'SystemArchitecture:Adapter:CreateNewMapping' );
schema.Items = { inputTreeSearch, inputTree, inpGroup, buttonGroup, outputTreeSearch, outputTree, outGroup };
schema.LayoutGrid = [ 5, 3 ];
schema.RowStretch = [ 0, 1, 1, 1, 1 ];
schema.ColStretch = [ 1, 0, 1 ];
end 
end 


methods 
function handleClickHelp( ~ )

helpview( fullfile( docroot, 'systemcomposer', 'helptargets.map' ), 'adapter' );
end 

function handleOpenDialog( this, dlg )

this.positionDialog( dlg, get_param( bdroot( this.BlockHdl ), 'Handle' ) );
end 

function handleCloseDialog( this, ~, action )




if this.dirty
if strcmpi( action, 'ok' )
this.preApply(  );
systemcomposer.internal.adapter.Dialog.dialogFor( this.BlockHdl, [  ] );
else 
dp = DAStudio.DialogProvider;
dp.questdlg(  ...
DAStudio.message( 'SystemArchitecture:Adapter:UnappliedChangesQuestion' ),  ...
DAStudio.message( 'SystemArchitecture:Adapter:UnappliedChangesTitle' ),  ...
{ DAStudio.message( 'SystemArchitecture:Adapter:Apply' ),  ...
DAStudio.message( 'SystemArchitecture:Adapter:Discard' ),  ...
DAStudio.message( 'SystemArchitecture:Adapter:Cancel' ) },  ...
DAStudio.message( 'SystemArchitecture:Adapter:Apply' ),  ...
@( resp )localHandleResponse( resp, this ) );
end 
else 


systemcomposer.internal.adapter.Dialog.dialogFor( this.BlockHdl, [  ] );
end 

function localHandleResponse( resp, this )
if strcmp( resp, DAStudio.message( 'SystemArchitecture:Adapter:Apply' ) )
try 
this.preApply(  );
catch ex
dp = DAStudio.DialogProvider;
dp.errordlg( ex.message,  ...
DAStudio.message( 'SystemArchitecture:Adapter:ErrorTitle' ),  ...
true );
dlg = DAStudio.Dialog( this );
dlg.show(  );
return ;
end 
systemcomposer.internal.adapter.Dialog.dialogFor( this.BlockHdl, [  ] );
elseif strcmp( resp, DAStudio.message( 'SystemArchitecture:Adapter:Cancel' ) )

dlg = DAStudio.Dialog( this );
this.setDirty( dlg );
dlg.show(  );
elseif strcmp( resp, DAStudio.message( 'SystemArchitecture:Adapter:Discard' ) )
if this.isInBusCreationMode && ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge )




this.OutputTree.pruneUnconnectedOutputBEPs(  );
end 
end 
end 
end 

function handleMappingsTableSelectionChanged( this, dlg, row, ~ )


this.currTableRow = row + 1;
dlg.refresh(  );
end 

function handleClickRemoveMapping( this, dlg )


row = this.currTableRow;
if this.isInBusCreationMode


[ ~, nodePath ] = this.MappingsTable.getMapping( row );

this.removeBEP( nodePath );
end 

this.removeEntryAndUpdateTable( dlg, row );
end 
function removeEntryAndUpdateTable( this, dlg, row )


if isempty( row ) || row == 0


return ;
end 
this.MappingsTable.removeMapping( row );


if row == 1







row = 0;
elseif row > this.MappingsTable.numEntries
row = this.MappingsTable.numEntries;
end 
this.currTableRow = row;


this.setDirty( dlg );
dlg.refresh(  );
end 

function handleSelectInputTreeNode( this, value )


value = this.tree2ElemPath( value );
this.currInputTreeSelection = value;
this.lastSelectedTree = 'input';
end 

function handleSelectOutputTreeNode( this, value )


this.currOutputTreeSelection = this.tree2ElemPath( value );
this.lastSelectedTree = 'output';
end 

function handleClickCreateNewMapping( this, dlg )



this.createNewMapping( this.currInputTreeSelection, this.currOutputTreeSelection );

this.setDirty( dlg );
end 

function createNewMapping( this, inputNodePath, outputNodePath )



elemMapIdx = this.MappingsTable.hasInput( inputNodePath );
this.MappingsTable.removeMapping( elemMapIdx );

elemMapIdx = this.MappingsTable.hasOutput( outputNodePath );
this.MappingsTable.removeMapping( elemMapIdx );

this.MappingsTable.addMapping( inputNodePath, outputNodePath );




fullPortMapIdx = this.MappingsTable.hasOutput( this.getOutputPortName );
elemMapIdx = this.MappingsTable.searchOutputs( [ this.getOutputPortName, '.' ] );

if any( fullPortMapIdx ) && any( elemMapIdx )

if strcmp( outputNodePath, this.getOutputPortName )




this.MappingsTable.removeMapping( elemMapIdx );

this.transientStatusMsg = DAStudio.message( 'SystemArchitecture:Adapter:RemovedElementMappings', this.getOutputPortName );
else 




this.MappingsTable.removeMapping( fullPortMapIdx );

this.transientStatusMsg = DAStudio.message( 'SystemArchitecture:Adapter:RemovedFullPortMapping', this.getOutputPortName );
end 
end 
end 

function handleClickUndo( this )

this.MappingsTable.revert(  );
end 

function [ nodeIsEditable, editorText ] = handleRequestTreeItemEdit( this, ~, treeTag, ~, elemPath )





nodeIsEditable = ~contains( elemPath, "/" );
editorText = elemPath;
if this.isInBusCreationMode && strcmp( treeTag, 'outputTree' )
depth = length( strfind( elemPath, '/' ) );
if depth <= 1



nodeIsEditable = true;
end 
if depth == 1
editorText = split( elemPath, '/' );
editorText = editorText{ 2 };
end 
end 
end 

function [ isValueChanged, editStr ] = handleTreeEditComplete( this, dlg, treeTag, ~, oldName, newName )




try 
if this.isInBusCreationMode && strcmp( treeTag, 'outputTree' ) && contains( oldName, "/" )
elemPath = split( oldName, '/' );
elemName = elemPath{ 2 };
this.renameOutputPortElement( elemName, newName );
newName = [ elemPath{ 1 }, '/', newName ];
else 
systemcomposer.internal.adapter.renamePort( this.BlockHdl, oldName, newName );
end 
isValueChanged = ~strcmp( oldName, newName );
editStr = newName;
catch me
isValueChanged = false;
editStr = oldName;

mEx = MException( message( 'SystemArchitecture:Adapter:CouldNotRenameNode', oldName, newName ) );
mEx.addCause( me );
report = mEx.getReport(  );

dp = DAStudio.DialogProvider;
dp.errordlg( report,  ...
DAStudio.message( 'SystemArchitecture:Adapter:CouldNotRenameNodeTitle' ),  ...
true );
end 



if isValueChanged
if strcmp( treeTag, 'inputTree' )
tag = 'input';
this.InputTree.update(  );
elseif strcmp( treeTag, 'outputTree' )
tag = 'output';
this.OutputTree.update(  );
else 
end 
this.MappingsTable.updateEntryName( tag, this.tree2ElemPath( oldName ), this.tree2ElemPath( newName ) );
end 

dlg.refresh(  );
end 

function handleInterfaceConversionChoiceChanged( this, value, dlg )

allModes = this.Adaptation.getSupportedModes(  );
mode = allModes{ value + 1 };
if ~strcmp( this.Adaptation.getMode(  ), mode )

this.Adaptation.setMode( mode );
this.setDirty( dlg );
end 
end 

function handleConversionOptionsClick( this, dlg )

prmsDialogObj = systemcomposer.internal.adapter.RTBParamsDialog( this, dlg );
prmsDlg = DAStudio.Dialog( prmsDialogObj );
prmsDialogObj.setPositionBasedOn( prmsDlg, 'conversionOptionsButton' );
prmsDlg.show(  );
end 

function handleClickAddToOutputTree( this, dlg )




if ~this.isInBusCreationMode
return ;
end 


foundElement = any( this.MappingsTable.hasInput( this.currInputTreeSelection ) );
if foundElement && ~isempty( this.OutputPortInterf.Elements )

return ;
end 


isPortNode = ~contains( this.currInputTreeSelection, "." );
element = this.getInterfaceElementFromNodePath( this.currInputTreeSelection );


if isempty( this.OutputPortInterf )


this.OutputPortInterf = this.setPortInterfaceWithName( this.getOutputPortName, 'CompositeOwned' );
end 


if isPortNode
elemName = this.currInputTreeSelection;
else 
elemName = this.getUniqueElementName( element.Name );
end 


try 
newElement = systemcomposer.internal.adapter.createElementFromSource( this.OutputPortInterf, element, elemName );


if length( newElement ) > 1
for idx = 1:length( newElement )
newElementNodePath = [ this.getOutputPortName, '.', newElement( idx ).Name ];
this.createNewMapping( [ this.currInputTreeSelection, '.', newElement( idx ).Name ], newElementNodePath );
end 
else 
newElementNodePath = [ this.getOutputPortName, '.', newElement.Name ];
this.createNewMapping( this.currInputTreeSelection, newElementNodePath );
end 
catch me
mEx = MException( message( 'SystemArchitecture:Adapter:CouldNotAddElementToOutputInterface', this.currInputTreeSelection ) );
mEx.addCause( me );
report = mEx.getReport(  );

elemAddFailedDialog = DAStudio.DialogProvider;
elemAddFailedDialog.errordlg( report, DAStudio.message( 'SystemArchitecture:Adapter:CouldNotAddElementToOutputInterfaceTitle' ), true );
end 






this.OutputTree.update(  );


this.setDirty( dlg );
end 

function handleClickRemoveFromOutputTree( this, dlg )

if ~this.isInBusCreationMode
return 
end 

nodePath = this.currOutputTreeSelection;
this.removeBEP( nodePath );

row = find( this.MappingsTable.hasOutput( nodePath ) );
this.removeEntryAndUpdateTable( dlg, row );

this.setDirty( dlg );
end 
function removeBEP( this, nodePath )

if ~isempty( nodePath ) && ~isequal( nodePath, this.getOutputPortName )

element = this.getInterfaceElementFromNodePath( nodePath );
if ~isempty( element )

this.OutputPortInterf.removeElement( element.Name );
end 
end 
end 

function handleInputTreeSearchTextChanged( this, dlg, newValue )

this.inputTreeSearchText = this.elem2TreePath( newValue );
dlg.refresh(  );

if ~isempty( this.inputTreeSearchText ) && this.InputTree.hasElement( this.inputTreeSearchText )

dlg.setWidgetValue( 'inputTree', this.inputTreeSearchText );
end 
end 

function handleOutputTreeSearchTextChanged( this, dlg, newValue )

this.outputTreeSearchText = this.elem2TreePath( newValue );
dlg.refresh(  );

if ~isempty( this.outputTreeSearchText ) && this.OutputTree.hasElement( this.outputTreeSearchText )

dlg.setWidgetValue( 'outputTree', this.outputTreeSearchText );
end 
end 

function [ status, message ] = preApply( this )

status = false;
message = '';


if this.MappingsTable.numEntries == 0 && ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge )
message = DAStudio.message( 'SystemArchitecture:Adapter:ZeroMappingsNotAllowed' );
return ;
end 


if this.dirty

this.Adaptation.save(  );

if ~this.Adaptation.isMode( this.Adaptation.ModeEnum.Merge )
this.MappingsTable.save(  );
else 
systemcomposer.internal.adapter.resetAdapterMappingsForMerge( this.BlockHdl );
end 


this.dirty = false;
end 


systemcomposer.internal.arch.internal.propertyinspector.SysarchAdapterPropertySchema.refresh( this.BlockHdl );
status = true;
end 

function ep = tree2ElemPath( ~, tp )



ep = strrep( tp, '/', '.' );
end 

function tp = elem2TreePath( ~, ep )



tp = strrep( ep, '.', '/' );
end 

function isMapped = isTreeNodeMapped( this, nodePath )

isMapped = any( this.MappingsTable.hasInput( nodePath ) ) ||  ...
any( this.MappingsTable.hasOutput( nodePath ) );
end 

function setDirty( this, dlg )%#ok<INUSD> 

this.dirty = true;
end 

function tf = isInBusCreationMode( this )
tf = false;%#ok<NASGU>



adapterComp = systemcomposer.utils.getArchitecturePeer( this.BlockHdl );
compPorts = adapterComp.getPorts(  );
hasAtleastOneInputPortWithInterface = false;
for cp = compPorts
if ( cp.getPortAction == systemcomposer.architecture.model.core.PortAction.REQUEST ) &&  ...
~isempty( cp.getPortInterface(  ) )
hasAtleastOneInputPortWithInterface = true;
break ;
end 
end 

if hasAtleastOneInputPortWithInterface &&  ...
( ( isempty( this.OutputPortInterf ) ||  ...
( isvalid( this.OutputPortInterf ) &&  ...
isa( this.OutputPortInterf, 'systemcomposer.interface.DataInterface' ) &&  ...
this.OutputPortInterf.isAnonymous &&  ...
strcmp( this.OutputPortInterf.Owner.Name, this.getOutputPortName ) ) ) )




tf = true;
else 
tf = false;
end 
end 

function name = getOutputPortName( this )




outBlk = find_system( this.BlockHdl, 'BlockType', 'Outport' );
name = get_param( outBlk( 1 ), 'PortName' );
end 
end 


methods ( Access = private )

function crossValidateMappingsWithTreeElements( this )





if this.MappingsTable.numEntries <= 0

return ;
end 
for idx = 1:1:this.MappingsTable.numEntries
[ inelem, outelem ] = this.MappingsTable.getMapping( idx );
inPath = this.elem2TreePath( inelem );
outPath = this.elem2TreePath( outelem );
if ~this.InputTree.hasElement( inPath )
this.unknownElems = [ this.unknownElems;{ inelem } ];
end 
if ~this.OutputTree.hasElement( outPath )
this.unknownElems = [ this.unknownElems;{ outelem } ];
end 
end 
end 

function outName = getCurrentMappingForInput( this )



outName = '';
if ~isempty( this.currInputTreeSelection )
idx = this.MappingsTable.hasInput( this.currInputTreeSelection );
if any( idx )
matchingRows = find( idx );
[ ~, outName ] = this.MappingsTable.getMapping( matchingRows( 1 ) );
end 
end 
end 

function inName = getCurrentMappingForOutput( this )



inName = '';
if ~isempty( this.currOutputTreeSelection )
idx = this.MappingsTable.hasOutput( this.currOutputTreeSelection );
if any( idx )
matchingRows = find( idx );
[ inName, ~ ] = this.MappingsTable.getMapping( matchingRows( 1 ) );
end 
end 
end 

function outVal = stripOutPortNameForElement( this, value )




if strcmp( value, this.getOutputPortName )
outVal = value;
else 
strToRemove = [ this.getOutputPortName, '/' ];
value = value( length( strToRemove ) + 1:end  );
outVal = value;
end 
end 

function resetToFactoryDefault( this )



systemcomposer.internal.adapter.resetPorts( this.BlockHdl );

this.MappingsTable.resetMappings(  );

this.preApply(  );

warndlg( DAStudio.message( 'SystemArchitecture:Adapter:UnexpectedError',  ...
[ get_param( this.BlockHdl, 'Parent' ), '/', get_param( this.BlockHdl, 'Name' ) ] ) );
end 

function tf = isUnknownElem( this, val )

tf = any( strcmp( val, this.unknownElems ) );
end 

function tf = isOutputTreeDataElement( this, nodePath )

tf = false;
if ~isempty( nodePath ) && ~isequal( nodePath, this.getOutputPortName )
elem = this.getInterfaceElementFromNodePath( nodePath );
if ~isempty( elem ) && isa( elem, 'systemcomposer.interface.DataElement' ) && isequal( elem.Interface, this.OutputPortInterf )
tf = true;
end 
end 
end 

function archPort = getArchPortWithName( this, Name )

archPort = [  ];
adapterComp = systemcomposer.utils.getArchitecturePeer( this.BlockHdl );
compPort = adapterComp.getPort( Name );
if ~isempty( compPort )
archPort = compPort.getArchitecturePort(  );
end 
end 

function newInterface = setPortInterfaceWithName( this, portName, interfaceName )
port = systemcomposer.internal.getWrapperForImpl( this.getArchPortWithName( portName ) );
if strcmp( interfaceName, 'CompositeOwned' )

newInterface = port.createOwnedInterface( "DataInterface" );
newInterface.removeElement( 'elem0' );


else 
newInterface = port.Model.InterfaceDictionary.getInterface( interfaceName );
port.setInterface( newInterface );
end 
end 

function elem = getInterfaceElementFromNodePath( this, nodePath )



elem = [  ];
pathElems = split( this.getCorrectedNodePath( nodePath ), '.' );
portName = pathElems{ 1 };
archPort = this.getArchPortWithName( portName );
if isempty( archPort )


return 
end 
interfImpl = archPort.getPortInterface;
if ~isempty( interfImpl )
interface = systemcomposer.internal.getWrapperForImpl( interfImpl );
if numel( pathElems ) == 1

assert( isa( interface, 'systemcomposer.ValueType' ) || isa( interface, 'systemcomposer.interface.DataInterface' ) );
elem = interface;
return ;
end 


nestedElem = interface;
for i = 2:numel( pathElems )
if isa( nestedElem, 'systemcomposer.interface.DataElement' )

nestedElem = nestedElem.Type.getElement( pathElems{ i } );
else 
assert( isa( nestedElem, 'systemcomposer.interface.DataInterface' ) )
nestedElem = nestedElem.getElement( pathElems{ i } );
end 
end 
elem = nestedElem;
end 
end 

function correctedPath = getCorrectedNodePath( this, nodePath )%#ok<*INUSL> 


pathElems = split( nodePath, '.' );
pathElems = cellfun( @( x )strtok( x, ' (' ), pathElems, 'UniformOutput', false );
correctedPath = strjoin( pathElems, '.' );
end 

function correctedPath = getCorrectedTreePath( this, treePath )

pathElems = split( treePath, '/' );
pathElems = cellfun( @( x )strtok( x, ' (' ), pathElems, 'UniformOutput', false );
correctedPath = strjoin( pathElems, '/' );
end 

function uniqueName = getUniqueElementName( this, initialName )


if ~isempty( this.OutputPortInterf.getElement( initialName ) )


title = DAStudio.message( 'SystemArchitecture:Adapter:ResolveNameConflictTitle' );
prompt = DAStudio.message( 'SystemArchitecture:Adapter:ResolveNameConflictPrompt', initialName );
defaultAnswer = { initialName };
numLines = 1;
answer = inputdlg( prompt, title, numLines, defaultAnswer );
uniqueName = answer{ numLines };
else 
uniqueName = initialName;
end 
end 
function renameOutputPortElement( this, oldName, newName )

dataElement = this.OutputPortInterf.getElement( oldName );
if ~isempty( dataElement )
dataElement.setName( newName );
end 
end 
end 
end 



% Decoded using De-pcode utility v1.2 from file /tmp/tmp0OaRSc.p.
% Please follow local copyright laws when handling this file.

