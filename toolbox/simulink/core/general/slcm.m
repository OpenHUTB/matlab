function slcm( action, block )





if nargin < 2
if nargin < 1
action = 'Create';
end 
block = gcbh;
elseif ischar( block )
block = get_param( block, 'Handle' );
end 

switch action
case 'Create'

LocalCreate( block );

case 'OK'

LocalOk( block );

case 'Cancel'

LocalCancel( block );

case 'Help'

LocalHelp( block )

case 'Apply'

LocalApply( block )

case 'Rename'

LocalRename( block )

case 'TransferModelFields'

LocalTransferModelFields( block );

case 'TransferCMFields'



case 'LoadBlock'

LocalLoadBlock( block );

case 'CopyBlock'

LocalCopyBlock( block );

case 'UpdateAllCMBlocksInThisModel'


if isempty( gcbf )
LocalUpdateDiagram( gcbh )
end 

case 'UpdateAllCMBlocksInThisModelInit'




restore_dirty = Simulink.PreserveDirtyFlag( bdroot( block ), 'blockDiagram' );%#ok<NASGU>
if isempty( gcbf )
LocalUpdateDiagram( block );
end 

case 'Resize'

LocalResize( block );

otherwise 
DAStudio.error( 'Simulink:ModelInfo:UnhandledOption', action );

end 
end 


function LocalCreate( block )



if isunix && ~strcmpi( get( 0, 'TerminalProtocol' ), 'X' )
return ;
end 


if blockIsInLockedLibrary( block )
return ;
end 


fig = get_param( block, 'UserData' );
if ~isempty( fig )
if ishandle( fig )

figure( fig );
return ;
else 

set_param( block, 'UserData', [  ] );
end 
end 


allData.block = block;


[ bdRoot, enable ] = LocalGetBDRoot( allData.block );

allData.currentRoot = bdRoot;


opts = sluiutil( 'dimension' );

visibility = 'on';


figWidth = 520 * opts.hScale;
figHeight = 370 * opts.vScale;

oldUnits = get( 0, 'Units' );
set( 0, 'Units', 'Characters' );
screenSize = get( 0, 'ScreenSize' );
set( 0, 'Units', oldUnits );

figLeft = ( screenSize( 3 ) - figWidth ) / 2;
figBottom = ( screenSize( 4 ) - figHeight ) / 2;

figPosition = [ figLeft, figBottom,  ...
figWidth, figHeight ];


windowName = DAStudio.message( 'Simulink:ModelInfo:WindowTitle', get_param( block, 'Parent' ) );

fig = figure( 'NumberTitle', 'off',  ...
'Name', windowName,  ...
'IntegerHandle', 'off',  ...
'Visible', 'off',  ...
'HandleVisibility', 'on',  ...
'DeleteFcn', { @LocalFigureCallback, 'Cancel' },  ...
'ResizeFcn', { @LocalFigureCallback, 'Resize' },  ...
'Units', 'Characters',  ...
'MenuBar', 'none',  ...
'Position', figPosition,  ...
'Color', get( 0, 'FactoryUicontrolBackgroundColor' ),  ...
'Tag', 'ModelInfo' );



buttons = { 'Apply', 'Help', 'Cancel', 'OK' };
buttonsEnable = { enable, 'on', 'on', enable };

left = figWidth;

for i = 1:length( buttons )
left = left - opts.leftAlignment - opts.buttonWidth;
position = [ left, opts.vertSpacer, opts.buttonWidth, opts.buttonHeight ];

properties = { 'String', DAStudio.message( [ 'Simulink:ModelInfo:', buttons{ i } ] ),  ...
'Tag', buttons{ i },  ...
'Callback', { @LocalFigureCallback, buttons{ i } } };

allData.bottomButtons( i ) = sluiutil( 'CreatePushbutton', fig,  ...
'on', buttonsEnable{ i }, position, properties );
end 


bottom = 2 * opts.vertSpacer + opts.buttonHeight;



frame.left = opts.leftAlignment;
frame.width = figWidth - 2 * opts.leftAlignment;
frame.height = 2 * opts.vertSpacer + opts.textHeight;
frame.properties = '';

frameTop = bottom + frame.height;
allData.frame = sluiutil( 'FrameWidget', fig, frameTop,  ...
frame, visibility );


horzTextAlignString = DAStudio.message( 'Simulink:ModelInfo:HorizontalTextAlignment' );
tempText = uicontrol( 'Parent', fig,  ...
'Style', 'Text',  ...
'String', horzTextAlignString,  ...
'Visible', 'off',  ...
'Position', [ 0, 0, figWidth, figHeight ] );

textExtent = get( tempText, 'Extent' );
delete( tempText );
textWidth = textExtent( 3 ) * opts.hScale;


bottom = bottom + opts.vertSpacer + opts.textHeight;

text.left = 2 * opts.leftAlignment;
text.width = textWidth;
text.properties = { 'String', horzTextAlignString };

popup.left = text.left + text.width + opts.leftAlignment;
popup.width = 100 * opts.hScale;




textHorzAlignString = { 'Left', 'Center', 'Right' };
textHorzAlignValue = get_param( allData.block, 'HorizontalTextAlignment' );
value = find( strcmpi( textHorzAlignString, textHorzAlignValue ) );


l10n_textHorzAlignString = { DAStudio.message( 'Simulink:ModelInfo:HorzAlignLeft' ),  ...
DAStudio.message( 'Simulink:ModelInfo:HorzAlignCenter' ),  ...
DAStudio.message( 'Simulink:ModelInfo:HorzAlignRight' ) };

popup.properties = { 'String', l10n_textHorzAlignString; ...
'Value', value; ...
'HorizontalAlignment', 'Left'; ...
'UserData', textHorzAlignString };

allData.textHorzAlignPopup = sluiutil( 'PopupWidget', fig, bottom,  ...
text, popup, visibility, enable );


checkbox.width = 140 * opts.hScale;
checkbox.left = figWidth - checkbox.width - 2 * opts.leftAlignment;

isFramed = get_param( allData.block, 'Frame' );
value = strcmpi( isFramed, 'on' );

checkbox.properties = { 'String', DAStudio.message( 'Simulink:ModelInfo:ShowBlockFrame' ), 'Value', value };

allData.blockIconFrame = sluiutil( 'CheckboxWidget', fig, bottom,  ...
checkbox, visibility, enable );

labelList = { DAStudio.message( 'Simulink:ModelInfo:ModelProperties' ) };
left = opts.leftAlignment;
top = figHeight - 2 * opts.vertSpacer;


listboxHeight = ( figHeight - frameTop ...
 - opts.vertSpacer - 2 * opts.textHeight );
text.left = left;
text.width = 170 * opts.hScale;

listbox.left = left;
listbox.width = 170 * opts.hScale;
listbox.height = listboxHeight;

text.properties = { 'String', labelList{ 1 } };
listbox.properties = '';

allData.list( 1 ) = sluiutil( 'ListWidget', fig, top, 0,  ...
text, listbox, visibility, enable );

top = top - opts.textHeight;


buttonPosition = [ left + listbox.width + opts.leftAlignment,  ...
top - opts.buttonHeight, opts.buttonWidth / 2, opts.buttonHeight ];

allData.transferButton( 1 ) = uicontrol( 'Parent', fig,  ...
'Style', 'PushButton',  ...
'String', '-->',  ...
'Units', 'Characters',  ...
'Visible', visibility,  ...
'Enable', enable,  ...
'Position', buttonPosition,  ...
'Tag', sprintf( 'Transfer%d', 1 ) );



editPositionLeft = buttonPosition( 1 ) + buttonPosition( 3 ) + opts.leftAlignment;



top = figHeight - 2 * opts.vertSpacer;
text.left = editPositionLeft;
text.width = figWidth - editPositionLeft - opts.leftAlignment;
text.properties = { 'String', DAStudio.message( 'Simulink:ModelInfo:EnterTextPrompt' ) };

edit.left = text.left;
edit.width = text.width;
edit.height = listboxHeight;

charArray = get_param( allData.block, 'DisplayStringWithTags' );
cellArray = cellstr( charArray );
edit.properties = { 'String', charArray };

allData.edit = sluiutil( 'MultipleLineEditWidget', fig, top, 0,  ...
text, edit, visibility, enable );

set( allData.edit.edit, 'String', cellArray );

set( allData.edit.text, 'Position', allData.edit.text.Position + [ 0, 0, 0, 1 ] );

modelFields = getModelFields;
set( allData.list( 1 ).list, 'String', modelFields( :, 1 ) );


set( allData.transferButton( 1 ),  ...
'CallBack', { @LocalFigureCallback, 'TransferModelFields' } );


warningPosition = [ 0, 0, 25, opts.textHeight ];
allData.windowTooSmall = sluiutil( 'CreateText', fig,  ...
'off', enable, warningPosition,  ...
{ 'HorizontalAlignment', 'Center' } );




allData.fig = fig;


allData.visibility = 'on';


set( fig, 'UserData', allData );


set_param( block, 'UserData', fig );


set( fig, 'HandleVisibility', 'Callback', 'Visible', 'on' );

end 



function appendTagToList( allData, appendTag )





editString = get( allData.edit.edit, 'String' );
if iscell( editString )
newString = [ editString;{ appendTag } ];
else 
newString = cellstr( strvcat( editString, appendTag ) );%#ok (strvcat slow but useful)
end 
set( allData.edit.edit, 'String', newString );

end 


function LocalCancel( block )



fig = LocalGetFigure( block );
if ~isempty( fig )
set_param( block, 'UserData', [  ] );
delete( fig );
end 
end 


function LocalApply( block )


fig = LocalGetFigure( block );
allData = get( fig, 'UserData' );
blockdiagram = LocalGetBDRoot( block );




editString = get( allData.edit.edit, 'String' );
displayStringWithTags = sluiutil( 'getCharArrayFromCellArray', editString );
set_param( allData.block, 'DisplayStringWithTags', displayStringWithTags );




horzAlign = get( allData.textHorzAlignPopup.popup, 'UserData' );
value = get( allData.textHorzAlignPopup.popup, 'Value' );


LocalUpdateBlock( block, blockdiagram, horzAlign{ value } );


value = get( allData.blockIconFrame.checkbox, 'Value' );
frameExist = onoff( value );
set_param( block, 'MaskIconFrame', frameExist, 'Frame', frameExist );

end 


function LocalOk( block )

LocalApply( block );
LocalCancel( block );
end 


function LocalRename( block )





fig = get_param( block, 'UserData' );
if ishandle( fig )
set( fig, 'Name', DAStudio.message( 'Simulink:ModelInfo:WindowTitle', get_param( block, 'Parent' ) ) );
allData = get( fig, 'UserData' );
allData.blockname = getfullname( block );
set( fig, 'UserData', allData );
end 

end 


function LocalTransferModelFields( block )


allData = get( LocalGetFigure( block ), 'UserData' );

value = get( allData.list( 1 ).list, 'Value' );
modelFields = getModelFields;

appendTagToList( allData, LocalMakeTag( modelFields{ value, 2 } ) );


listSize = size( modelFields, 1 );
value = min( value + 1, listSize );
set( allData.list( 1 ).list, 'Value', value );

end 


function LocalUpdateBlock( block, blockdiagram, leftAlignment )








displayStringWithTags = get_param( block,  ...
'DisplayStringWithTags' );


[ start, tokens ] = regexp( displayStringWithTags, '%<(\w)*>', 'start', 'tokens' );
if ~isempty( start )


modelFields = getModelFields;
modelFields = modelFields( :, 2 );


modelFields = [ modelFields;'ModifiedDate' ];



tokens = [ tokens{ : } ];


for i = 1:numel( tokens )
t = tokens{ i };
fieldInd = find( strcmp( t, modelFields ) );
if ~isempty( fieldInd )
if strcmp( t, 'LastModificationDate' )




insertString = get_param( blockdiagram, 'LastModifiedDate' );
elseif strcmp( t, 'ModelName' )
insertString = get_param( blockdiagram, 'Name' );
else 
insertString = get_param( blockdiagram, t );
end 

displayStringWithTags = regexprep( displayStringWithTags,  ...
LocalMakeTag( t ), insertString );
modelFields( fieldInd ) = [  ];
end 
end 
end 

if strcmpi( leftAlignment, 'defaultLeftAlignment' )
leftAlignment = get_param( block, 'HorizontalTextAlignment' );
end 

maskDisplayString = sluiutil( 'replaceChar10ByNewLine', displayStringWithTags );
set_param( block,  ...
'MaskDisplayString', maskDisplayString,  ...
'HorizontalTextAlignment', leftAlignment,  ...
'LeftAlignmentValue', horizontalTextOffset( leftAlignment ) );

end 



function LoadOrCopyBlock( block, blockdiagram, ~ )


LocalUpdateBlock( block, blockdiagram, 'defaultLeftAlignment' );

end 


function LocalLoadBlock( block )


[ blockdiagram, enable ] = LocalGetBDRoot( block );


if strcmp( enable, 'on' )


restore_dirty = Simulink.PreserveDirtyFlag( blockdiagram, 'blockDiagram' );%#ok<NASGU>
lockStatus = get_param( blockdiagram, 'Lock' );
lockCleanup = onCleanup( @(  )set_param( blockdiagram, 'Lock', lockStatus ) );
set_param( blockdiagram, 'Lock', 'off' );


maskInitialization = get_param( block, 'MaskInitialization' );
set_param( block, 'MaskInitialization', '' );



set_param( block, 'NameChangeFcn', 'slcm Rename;',  ...
'DeleteFcn', 'slcm Cancel;' );

LoadOrCopyBlock( block, blockdiagram, 'loading' );

set_param( block,  ...
'MaskIconFrame', get_param( block, 'Frame' ),  ...
'MaskInitialization', maskInitialization );


delete( lockCleanup );
end 

end 


function LocalCopyBlock( block )



if ParentIsLinkedSubsystem( block )
return ;
end 

blockdiagram = LocalGetBDRoot( block );



maskInitialization = get_param( block, 'MaskInitialization' );
set_param( block, 'MaskInitialization', '' );

LoadOrCopyBlock( block, blockdiagram, 'copying' );


set_param( block, 'MaskInitialization', maskInitialization,  ...
'UserData', '' );

end 


function offset = horizontalTextOffset( alignment )



switch alignment
case { 'Left' }
offset = '0.02';

case { 'Center' }
offset = '0.5';

case { 'Right' }
offset = '0.98';

end 

end 


function LocalUpdateDiagram( block )


if ParentIsLinkedSubsystem( block )
parent = get_param( block, 'Parent' );


sourcebd = strtok( get_param( parent, 'ReferenceBlock' ), '/' );
if ~bdIsLoaded( sourcebd )
try 
load_system( sourcebd )
catch E


warning( E.identifier, '%s', E.message )
return 
end 
end 


LocalUpdateBlock( block, sourcebd, 'defaultLeftAlignment' );
else 
parentOfBlock = strtok( get_param( block, 'parent' ), '/' );


if bdIsLibrary( parentOfBlock ) &&  ...
strcmpi( get_param( parentOfBlock, 'lock' ), 'on' )
MSLDiagnostic( 'Simulink:ModelInfo:LockedLibrary', getfullname( block ) ).reportAsWarning;
return 
end 


LocalUpdateBlock( block, LocalGetBDRoot( block ), 'defaultLeftAlignment' );
end 
end 



function y = ParentIsLinkedSubsystem( block )



y = false;

parent = get_param( block, 'Parent' );
if strcmpi( get_param( parent, 'Type' ), 'block' )

if strcmpi( get_param( parent, 'BlockType' ), 'SubSystem' )

if ~isempty( get_param( parent, 'ReferenceBlock' ) )


y = true;
end 
end 
end 

end 


function [ bdRoot, enable ] = LocalGetBDRoot( block )

bdRoot = [  ];

parent = get_param( block, 'Parent' );
while ~isempty( parent ) && strcmpi( get_param( parent, 'Type' ), 'block' )

if strcmpi( get_param( parent, 'BlockType' ), 'SubSystem' )

reference = get_param( parent, 'ReferencedSubsystem' );
if ~isempty( reference )

bdRoot = reference;
enable = 'on';
break ;
end 

reference = get_param( parent, 'ReferenceBlock' );
if ~isempty( reference )


bdRoot = bdroot( reference );
enable = 'off';
break ;
end 
end 

parent = get_param( parent, 'Parent' );
end 

if isempty( bdRoot )
bdRoot = bdroot( gcs );
enable = 'on';
end 

bdRoot = get_param( bdRoot, 'Handle' );
end 


function LocalHelp( block )

slhelp( block );
end 


function modelFields = getModelFields



modelFields = { [  ], 'Created'; ...
[  ], 'Creator'; ...
[  ], 'ModifiedBy'; ...
[  ], 'ModifiedComment'; ...
[  ], 'ModelVersion'; ...
[  ], 'ModelName'; ...
[  ], 'Description'; ...
[  ], 'LastModifiedBy'; ...
[  ], 'LastModificationDate' };
for i = 1:size( modelFields, 1 )
modelFields{ i, 1 } = DAStudio.message( [ 'Simulink:ModelInfo:', modelFields{ i, 2 } ] );
end 

end 


function setVisibility( fig, visibility, msg )


allData = get( fig, 'UserData' );


GUISize = get( fig, 'Position' );
figWidth = GUISize( 3 );
figHeight = GUISize( 4 );

if onoff( visibility ) == 0

pos = get( allData.windowTooSmall, 'Position' );
pos( 1 ) = ( figWidth - pos( 3 ) ) / 2;
pos( 2 ) = ( figHeight - pos( 4 ) ) / 2;

set( allData.windowTooSmall, 'Position', pos, 'String', msg );
end 


if onoff( allData.visibility ) == onoff( visibility )
return 
end 

allData.visibility = visibility;

if onoff( notbool( visibility ) )

allObjects = findobj( fig, 'Visible', 'on' );
allData.activeObjects = allObjects( allObjects ~= fig );
end 


set( allData.windowTooSmall, 'Visible', notbool( visibility ) );


set( allData.activeObjects, 'Visible', visibility );




if onoff( visibility )
allData.activeObjects = [  ];
end 


set( fig, 'UserData', allData );

end 


function LocalResize( block )


fig = LocalGetFigure( block );
allData = get( fig, 'UserData' );


opts = sluiutil( 'dimension' );


figPos = get( fig, 'Position' );
figWidth = figPos( 3 );
figHeight = figPos( 4 );


textHorzAlignPopup = get( allData.textHorzAlignPopup.popup, 'Position' );
blockIconFrameCheckbox = get( allData.blockIconFrame.checkbox, 'Position' );

minimX = textHorzAlignPopup( 1 ) + textHorzAlignPopup( 3 ) +  ...
blockIconFrameCheckbox( 3 ) + 3 * opts.leftAlignment;

minimY = 15.4;

if figWidth < minimX || figHeight < minimY
if figWidth < minimX
if figHeight < minimY
msg = DAStudio.message( 'Simulink:ModelInfo:WindowTooSmall' );
else 
msg = DAStudio.message( 'Simulink:ModelInfo:WindowTooNarrow' );
end 
else 
if figHeight < minimY
msg = DAStudio.message( 'Simulink:ModelInfo:WindowTooShort' );
end 
end 

setVisibility( fig, 'off', msg );
return 
else 
setVisibility( fig, 'on', '' );
end 


left = figWidth;

for i = 1:length( allData.bottomButtons )
left = left - opts.leftAlignment - opts.buttonWidth;

buttonPos = get( allData.bottomButtons( i ), 'Position' );
buttonPos( 1 ) = left;
set( allData.bottomButtons( i ), 'Position', buttonPos );
end 


bottom = 2 * opts.vertSpacer + opts.buttonHeight;



framePos = get( allData.frame.frame, 'Position' );
framePos( 3 ) = figWidth - 2 * opts.leftAlignment;
set( allData.frame.frame, 'Position', framePos );

frameTop = bottom + framePos( 4 );


checkboxPos = get( allData.blockIconFrame.checkbox, 'Position' );
checkboxPos( 1 ) = figWidth - checkboxPos( 3 ) - 2 * opts.leftAlignment;
set( allData.blockIconFrame.checkbox, 'Position', checkboxPos );


top = figHeight - 2 * opts.vertSpacer;

listboxHeight = ( figHeight - frameTop ...
 - opts.vertSpacer - 2 * opts.textHeight );


textPos = get( allData.list( 1 ).text, 'Position' );
textPos( 2 ) = top - opts.textHeight;
set( allData.list( 1 ).text, 'Position', textPos );


listPos = get( allData.list( 1 ).list, 'Position' );
listPos( 2 ) = textPos( 2 ) - listboxHeight;
listPos( 4 ) = listboxHeight;
set( allData.list( 1 ).list, 'Position', listPos );

top = top - opts.textHeight;


buttonPos = get( allData.transferButton( 1 ), 'Position' );
buttonPos( 2 ) = top - opts.buttonHeight;
set( allData.transferButton( 1 ), 'Position', buttonPos );



editPositionLeft = buttonPos( 1 ) + buttonPos( 3 ) + opts.leftAlignment;

top = figHeight - 2 * opts.vertSpacer;

textPos = get( allData.edit.text, 'Position' );
textPos( 1 ) = editPositionLeft;
textPos( 2 ) = top - opts.textHeight;
textPos( 3 ) = figWidth - editPositionLeft - opts.leftAlignment;
set( allData.edit.text, 'Position', textPos );

editPos = get( allData.edit.edit, 'Position' );
editPos( 1 ) = textPos( 1 );
editPos( 3 ) = textPos( 3 );
editPos( 4 ) = listboxHeight;
editPos( 2 ) = textPos( 2 ) - editPos( 4 );

set( allData.edit.edit, 'Position', editPos );

end 


function f = LocalGetFigure( block )
f = get_param( block, 'UserData' );
if ~ishandle( f )
f = [  ];
end 
end 


function LocalFigureCallback( ~, ~, action )
allData = get( gcbf, 'UserData' );
block = allData.block;
feval( mfilename, action, block );
end 


function str = LocalMakeTag( str )
str = [ '%<', str, '>' ];
end 


function locked = blockIsInLockedLibrary( block )

errorMessage = '';
bdname = get_param( bdroot( block ), 'Name' );
if strcmpi( bdname, 'simulink' )

errorMessage = DAStudio.message( 'Simulink:ModelInfo:NeedsModel' );
elseif strcmpi( get_param( bdname, 'Lock' ), 'on' )

errorMessage = DAStudio.message( 'Simulink:ModelInfo:LockedLibrary', getfullname( block ) );
end 

locked = ~isempty( errorMessage );
if locked
uiwait( errordlg( errorMessage, 'Error', 'Modal' ) );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpNSwCzy.p.
% Please follow local copyright laws when handling this file.

