



classdef showPasteConflict < handle
properties 
meHandle;
mDestinationHandle;
mDestinationTreeNode;
mConflictsList;
mOperation
m_children
mShowIncompletePaste
end 

methods 

function obj = showPasteConflict( me, dest, items, operation, incompletePaste )
obj.meHandle = me;
obj.mDestinationHandle = dest;
obj.mDestinationTreeNode = dest;
if isa( obj.mDestinationHandle, 'DAStudio.Shortcut' )
fwdObj = obj.mDestinationHandle.getForwardedObject;
if isa( fwdObj, 'DAStudio.WorkspaceNode' )
obj.mDestinationHandle = fwdObj;
end 
end 

obj.mConflictsList = items( ~all( cellfun( @isempty, items ), 2 ), : );
obj.mOperation = operation;
obj.m_children = [  ];
obj.mShowIncompletePaste = incompletePaste;
end 

function schema = getDialogSchema( obj )
image.Type = 'image';
image.Tag = 'image';
image.RowSpan = [ 1, 1 ];
image.ColSpan = [ 1, 1 ];
image.FilePath = fullfile( matlabroot, 'toolbox', 'shared', 'dastudio', 'resources', 'warning.png' );

conflictRows = find( ~strcmp( obj.mConflictsList( :, 1 ), 'No conflict' ) );
conflictCount = length( conflictRows );

if slfeature( 'MEPasteConflict' ) < 2 && isequal( 1, conflictCount )
if isequal( obj.mConflictsList{ conflictRows, 1 }, DAStudio.message( 'modelexplorer:DAS:PasteConflict_Skip' ) )
description.Name = DAStudio.message( 'modelexplorer:DAS:PasteConflict_Identical', obj.mConflictsList{ conflictRows, 2 }.getPropValue( 'Name' ), obj.mDestinationHandle.getSourceName(  ) );
else 
description.Name = DAStudio.message( 'modelexplorer:DAS:PasteConflict_Single', obj.mConflictsList{ conflictRows, 2 }.getPropValue( 'Name' ), obj.mDestinationHandle.getSourceName(  ) );
end 
else 
[ conflictsListRows, ~ ] = size( obj.mConflictsList );
if ~isequal( conflictCount, conflictsListRows )
description.Name = DAStudio.message( 'modelexplorer:DAS:PasteConflict_Multiple_Some', obj.mDestinationHandle.getSourceName(  ) );
else 
description.Name = DAStudio.message( 'modelexplorer:DAS:PasteConflict_Multiple_All', obj.mDestinationHandle.getSourceName(  ) );
end 
description.Name = [ description.Name, DAStudio.message( 'modelexplorer:DAS:PasteConflict_Instruction' ) ];
end 
description.WordWrap = true;
description.Type = 'text';
description.Tag = 'PasteConflict_GeneralMsg';
description.RowSpan = [ 1, 2 ];
description.ColSpan = [ 2, 10 ];



if ~isempty( obj.mConflictsList )
if slfeature( 'MEPasteConflict' ) > 1
details.Type = 'spreadsheet';
details.Columns = { ' ',  ...
DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Name' ),  ...
DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Source' ),  ...
DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Value' ),  ...
DAStudio.message( 'modelexplorer:DAS:PasteConflictColumn_Action' ) };
details.Source = obj;
details.Tag = 'conflictList';
details.RowSpan = [ 3, 3 ];
details.ColSpan = [ 1, 10 ];
elseif ( conflictCount > 1 )
conflictStr = '';
duplicates = {  };
for i = 1:conflictCount
id = conflictRows( i );
duplicates{ end  + 1 } = [ obj.mConflictsList{ id, 2 }.getPropValue( 'Name' ), newline(  ) ];
end 
conflictStr = strjoin( sort( duplicates ), '' );
details.Text = conflictStr;
details.Type = 'textbrowser';
details.Editable = false;
details.Tag = 'conflictList';
details.RowSpan = [ 3, 3 ];
details.ColSpan = [ 2, 10 ];
end 
end 

buttons.Type = 'panel';
buttons.Tag = 'buttonPanel';
buttons.LayoutGrid = [ 1, 2 ];

if slfeature( 'MEPasteConflict' ) > 1
lastBtn = 1;
btnOk.Type = 'pushbutton';
btnOk.Tag = 'Simulink:editor:DialogOK';
btnOk.Name = DAStudio.message( btnOk.Tag );
btnOk.MatlabMethod = 'showPasteConflict.buttonCB';
btnOk.MatlabArgs = { '%dialog', btnOk.Tag };
btnOk.RowSpan = [ 1, 1 ];
btnOk.ColSpan = [ lastBtn, lastBtn ];

buttons.Items = { btnOk };
else 
lastBtn = 2;
btnKeep.Type = 'pushbutton';
btnKeep.Tag = 'modelexplorer:DAS:PasteConflict_KeepBoth';
btnKeep.Name = DAStudio.message( btnKeep.Tag );
btnKeep.MatlabMethod = 'showPasteConflict.buttonCB';
btnKeep.MatlabArgs = { '%dialog', btnKeep.Tag };
btnKeep.RowSpan = [ 1, 1 ];
btnKeep.ColSpan = [ lastBtn, lastBtn ];

if isequal( obj.mConflictsList{ conflictRows, 1 }, 'Skip' )
btnDefault.Tag = 'modelexplorer:DAS:PasteConflict_Skip';
btnDefault.Name = DAStudio.message( btnDefault.Tag );
else 
btnDefault.Tag = 'modelexplorer:DAS:PasteConflict_Replace';
btnDefault.Name = DAStudio.message( btnDefault.Tag );
end 
btnDefault.Type = 'pushbutton';
btnDefault.MatlabMethod = 'showPasteConflict.buttonCB';
btnDefault.MatlabArgs = { '%dialog', btnDefault.Tag };
btnDefault.RowSpan = [ 1, 1 ];
btnDefault.ColSpan = [ 1, 1 ];

buttons.Items = { btnKeep, btnDefault };
end 

btnCancel.Type = 'pushbutton';
btnCancel.Tag = 'Simulink:editor:DialogCancel';
btnCancel.Name = DAStudio.message( btnCancel.Tag );
btnCancel.MatlabMethod = 'showPasteConflict.buttonCB';
btnCancel.MatlabArgs = { '%dialog', btnCancel.Tag };
btnCancel.RowSpan = [ 1, 1 ];
lastBtn = lastBtn + 1;
btnCancel.ColSpan = [ lastBtn, lastBtn ];

buttons.Items{ end  + 1 } = btnCancel;

schema.DialogTitle = DAStudio.message( 'modelexplorer:DAS:ME_MODEL_EXPLORER_GUI' );
if slfeature( 'MEPasteConflict' ) < 2 && isequal( 1, conflictCount )
schema.Items = { image, description };
else 
fakeCols.Type = 'text';
fakeCols.Name = [ '    ',  ...
'                   ',  ...
'                   ',  ...
'                   ',  ...
'                   ',  ...
'             ',  ...
'             ' ...
 ];
fakeCols.Visible = true;
fakeCols.RowSpan = [ 2, 2 ];
fakeCols.ColSpan = [ 2, 10 ];
schema.Items = { image, description, fakeCols, details };
end 

schema.StandaloneButtonSet = { '' };
buttons.RowSpan = [ 5, 5 ];
buttons.ColSpan = [ 9, 10 ];
schema.Items = [ schema.Items, buttons ];

schema.CloseArgs = { '%dialog', '%closeaction' };
schema.CloseCallback = 'showPasteConflict.closeCB';

schema.DialogTag = 'showPasteConflict';

schema.Sticky = true;
schema.IsScrollable = false;
schema.LayoutGrid = [ 4, 10 ];
schema.DisplayIcon = fullfile( 'toolbox', 'shared', 'dastudio', 'resources', 'ModelExplorer.png' );

end 

function children = getChildren( obj )
if isempty( obj.m_children )
try 
rows = find( ~strcmp( obj.mConflictsList( :, 1 ), DAStudio.message( 'modelexplorer:DAS:PasteConflict_NoConflict' ) ) );
rowCount = length( rows );
for i = 1:rowCount
id = rows( i );
rowObj = obj.mConflictsList{ id, 2 };
action = obj.mConflictsList{ id, 1 };
valueStr = obj.mConflictsList{ id, 3 };
sourceStr = obj.mConflictsList{ id, 4 };
obj.m_children = [ obj.m_children ...
, NameConflictSpreadsheetRow( obj, id, rowObj,  ...
action,  ...
valueStr,  ...
sourceStr ) ];
end 
catch E
end 
end 
children = obj.m_children;
end 

function setAction( obj, id, action )
obj.mConflictsList{ id, 1 } = action;
end 
end 

methods ( Static )

function launchDialog( me, destination, names, operation, incompletePaste )
conflictResDlg = showPasteConflict( me, destination, names, operation, incompletePaste );
DAStudio.Dialog( conflictResDlg, '', 'DLG_STANDALONE' );
end 

function buttonCB( dialogH, btnTag )
dataCreated = false;
dlgsrc = dialogH.getDialogSource;

ed = DAStudio.EventDispatcher;
ed.broadcastEvent( 'MESleepEvent' );

try 
if strcmp( btnTag, 'modelexplorer:DAS:PasteConflict_Replace' )
rows = find( strcmp( dlgsrc.mConflictsList( :, 1 ), DAStudio.message( 'modelexplorer:DAS:PasteConflict_NoConflict' ) ) );
if ~isempty( rows )
list = cell2mat( dlgsrc.mConflictsList( rows, 2 ) );
dlgsrc.mDestinationHandle.doDropOperation( list, dlgsrc.mOperation, 'KeepBoth' );
dataCreated = true;
end 
rows = find( ~strcmp( dlgsrc.mConflictsList( :, 1 ), DAStudio.message( 'modelexplorer:DAS:PasteConflict_NoConflict' ) ) );
if ~isempty( rows )
list = cell2mat( dlgsrc.mConflictsList( rows, 2 ) );
dlgsrc.mDestinationHandle.doDropOperation( list, dlgsrc.mOperation, 'Overwrite' );
dataCreated = true;
end 
elseif strcmp( btnTag, 'modelexplorer:DAS:PasteConflict_KeepBoth' )
rows = find( strcmp( dlgsrc.mConflictsList( :, 1 ), DAStudio.message( 'modelexplorer:DAS:PasteConflict_NoConflict' ) ) );
if ~isempty( rows )
list = cell2mat( dlgsrc.mConflictsList( rows, 2 ) );
dlgsrc.mDestinationHandle.doDropOperation( list, dlgsrc.mOperation, 'KeepBoth' );
dataCreated = true;
end 
rows = find( ~strcmp( dlgsrc.mConflictsList( :, 1 ), DAStudio.message( 'modelexplorer:DAS:PasteConflict_NoConflict' ) ) );
if ~isempty( rows )
list = cell2mat( dlgsrc.mConflictsList( rows, 2 ) );
dlgsrc.mDestinationHandle.doDropOperation( list, dlgsrc.mOperation, 'KeepBoth' );
dataCreated = true;
end 
elseif strcmp( btnTag, 'modelexplorer:DAS:PasteConflict_Skip' )
rows = find( strcmp( dlgsrc.mConflictsList( :, 1 ), DAStudio.message( 'modelexplorer:DAS:PasteConflict_NoConflict' ) ) );
if ~isempty( rows )
list = cell2mat( dlgsrc.mConflictsList( rows, 2 ) );
dlgsrc.mDestinationHandle.doDropOperation( list, dlgsrc.mOperation, 'KeepBoth' );
dataCreated = true;
end 
elseif strcmp( btnTag, 'Simulink:editor:DialogOK' )
rows = find( strcmp( dlgsrc.mConflictsList( :, 1 ), DAStudio.message( 'modelexplorer:DAS:PasteConflict_NoConflict' ) ) );
if ~isempty( rows )
list = cell2mat( dlgsrc.mConflictsList( rows, 2 ) );
dlgsrc.mDestinationHandle.doDropOperation( list, dlgsrc.mOperation, 'KeepBoth' );
dataCreated = true;
end 
rows = find( strcmp( dlgsrc.mConflictsList( :, 1 ), DAStudio.message( 'modelexplorer:DAS:PasteConflict_Replace' ) ) );
if ~isempty( rows )
list = cell2mat( dlgsrc.mConflictsList( rows, 2 ) );
dlgsrc.mDestinationHandle.doDropOperation( list, dlgsrc.mOperation, 'Overwrite' );
dataCreated = true;
end 
rows = find( strcmp( dlgsrc.mConflictsList( :, 1 ), DAStudio.message( 'modelexplorer:DAS:PasteConflict_KeepBoth' ) ) );
if ~isempty( rows )
list = cell2mat( dlgsrc.mConflictsList( rows, 2 ) );
dlgsrc.mDestinationHandle.doDropOperation( list, dlgsrc.mOperation, 'KeepBoth' );
dataCreated = true;
end 
end 

if ~isequal( dlgsrc.meHandle.getTreeSelection, dlgsrc.mDestinationTreeNode )
dlgsrc.meHandle.view( dlgsrc.mDestinationTreeNode );
end 
catch 
end 

ed = DAStudio.EventDispatcher;
ed.broadcastEvent( 'MEWakeEvent' );

if ~strcmp( btnTag, 'Simulink:editor:DialogCancel' ) && dlgsrc.mShowIncompletePaste
hw = warndlg( DAStudio.message( 'modelexplorer:DAS:ME_INCOMPLETEPASTE' ), DAStudio.message( 'modelexplorer:DAS:ME_WARNING' ), 'modal' );
set( hw, 'tag', 'modelexplorer:DAS:ME_WARNING' );
setappdata( hw, 'WarningID', 'modelexplorer:DAS:ME_INCOMPLETEPASTE' );
end 

if dataCreated
dlgsrc.meHandle.update( dlgsrc.mDestinationHandle, 'list' );
end 
delete( dialogH );
end 

function closeCB( dialogH, ~ )
dlgsrc = dialogH.getDialogSource;
if ~isempty( dlgsrc )
rowCount = length( dlgsrc.m_children );
for i = 1:rowCount
delete( dlgsrc.m_children( i ) );
end 
dlgsrc.m_children = [  ];
dlgsrc.mConflictsList = [  ];
end 
delete( dlgsrc );
end 

end 

end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpwCBMuD.p.
% Please follow local copyright laws when handling this file.

