function slideg( varargin )














orig_gcbh = gcbh;




switch nargin, 

case { 4, 6 }

LocalObsolete( orig_gcbh, nargin, varargin{ 1:end  } );
Action = 'Open';

case 0

DAStudio.error( 'Simulink:dialog:SlidegNoArg' );

otherwise , 

Action = varargin{ 1 };

if 1 ~= nargin
MSLDiagnostic( 'Simulink:dialog:SlidegExtraArgs' ).reportAsWarning;
end 

end 

switch Action, 





case 'Open', 
blockHandleSliderGainTopMask = orig_gcbh;
LocalOpenBlockFcn( blockHandleSliderGainTopMask );






case 'Close', 
blockHandleSliderGainTopMask = orig_gcbh;
LocalCloseBlockFcn( blockHandleSliderGainTopMask );






case 'DeleteBlock', 
blockHandleSliderGainTopMask = orig_gcbh;
LocalDeleteBlockFcn( blockHandleSliderGainTopMask );






case 'Copy', 
blockHandleNewDestinationSliderGain = orig_gcbh;
LocalCopyBlockFcn( blockHandleNewDestinationSliderGain );






case 'Load', 
blockHandleSliderGainTopMask = orig_gcbh;
LocalLoadBlockFcn( blockHandleSliderGainTopMask );






case 'NameChange', 
blockHandleSliderGainAfterNameChanged = orig_gcbh;
LocalNameChangeBlockFcn( blockHandleSliderGainAfterNameChanged );






case 'ParentClose', 
blockHandleSliderGainTopMask = orig_gcbh;
LocalParentCloseBlockFcn( blockHandleSliderGainTopMask );






case 'DeleteFigure', 
LocalDeleteFigureFcn;






case 'CloseRequest', 
LocalCloseRequestFigureFcn;






case 'Help', 
LocalHelpFcn;






case 'Slider', 
LocalSliderFcn;






case 'LowEdit', 
LocalLowEditFcn;






case 'GainEdit', 
LocalGainEditFcn;






case 'HighEdit', 
LocalHighEditFcn;






case 'StartFcn', 
blockHandleSliderGainTopMask = orig_gcbh;
LocalStartBlockFcn( blockHandleSliderGainTopMask )






case 'StopFcn'
blockHandleSliderGainTopMask = orig_gcbh;
LocalStopBlockFcn( blockHandleSliderGainTopMask )

otherwise , 
DAStudio.error( 'Simulink:dialog:UnknownAction', Action );

end 








function LocalParamsToMaskEntries( blockHandleSliderGainTopMask, low, gain, high )


aMaskObj = Simulink.Mask.get( blockHandleSliderGainTopMask );
while ( ~isempty( aMaskObj.BaseMask ) )
aMaskObj = aMaskObj.BaseMask;
end 

aMaskParameters = aMaskObj.Parameters;
aMaskNames = { aMaskParameters( : ).Name }';

set_param( blockHandleSliderGainTopMask,  ...
aMaskNames{ 1 }, num2str( low ),  ...
aMaskNames{ 2 }, num2str( gain ),  ...
aMaskNames{ 3 }, num2str( high ) );








function [ low, gain, high ] = LocalMaskEntriesToParams( block )


aMaskObj = Simulink.Mask.get( block );
while ( ~isempty( aMaskObj.BaseMask ) )
aMaskObj = aMaskObj.BaseMask;
end 

aMaskParameters = aMaskObj.Parameters;
aMaskValues = { aMaskParameters( : ).Value }';

low = str2double( aMaskValues{ 1 } );
gain = str2double( aMaskValues{ 2 } );
high = str2double( aMaskValues{ 3 } );






function value = LocalGetValue( low, gain, high )

if high == low
value = 0.5;
else 
value = ( gain - low ) / ( high - low );
end 







function LocalOpenBlockFcn( blockHandleSliderGainTopMask )

modelHandle = bdroot( blockHandleSliderGainTopMask );






FigHandle = get_param( blockHandleSliderGainTopMask, 'UserData' );
if ishghandle( FigHandle ), 
set( FigHandle, 'Visible', 'on' );
figure( FigHandle );
else 
if strcmp( get_param( modelHandle, 'Lock' ), 'on' ) ||  ...
strcmp( get_param( blockHandleSliderGainTopMask, 'LinkStatus' ), 'implicit' )

errordlg(  ...
DAStudio.message( 'Simulink:dialog:SliderGainInLockLib' ),  ...
'Error', 'modal' )
return 
end 

dlgState = LocalGetDialogState( modelHandle );
ScreenUnit = get( 0, 'Units' );
set( 0, 'Units', 'pixels' );
ScreenSize = get( 0, 'ScreenSize' );




mStdButtonWidth = 90;
mStdButtonHeight = 20;
mFrameToText = 15;
COMPUTER = computer;
if strcmp( COMPUTER( 1:2 ), 'PC' )
mLineHeight = 13;
else 
mLineHeight = 15;
end 


ButtonWH = [ mStdButtonWidth, mStdButtonHeight ];
HS = 5;
FigW = 3 * mStdButtonWidth + 4 * mFrameToText;
FigH = 3 * mStdButtonHeight + 5 * HS + mLineHeight;
FigurePos = [ ( ScreenSize( 3 ) - FigW ) / 2, ( ScreenSize( 4 ) - FigH ) / 2, FigW, FigH ];

bdPos = get_param( get_param( blockHandleSliderGainTopMask, 'Parent' ), 'Location' );
blkPos = get_param( blockHandleSliderGainTopMask, 'Position' );
bdPos = [ bdPos( 1:2 ) + blkPos( 1:2 ), bdPos( 1:2 ) + blkPos( 1:2 ) + blkPos( 3:4 ) ];
hgPos = rectconv( bdPos, 'hg' );

FigurePos( 1 ) = hgPos( 1 ) + ( hgPos( 3 ) - FigurePos( 3 ) );
FigurePos( 2 ) = hgPos( 2 ) + ( hgPos( 4 ) - FigurePos( 4 ) );


if FigurePos( 1 ) < 0
FigurePos( 1 ) = 1;
elseif FigurePos( 1 ) > ScreenSize( 3 ) - FigurePos( 3 )
FigurePos( 1 ) = ScreenSize( 3 ) - FigurePos( 3 );
end 
if FigurePos( 2 ) < 0
FigurePos( 2 ) = 1;
elseif FigurePos( 2 ) > ScreenSize( 4 ) - FigurePos( 4 )
FigurePos( 2 ) = ScreenSize( 4 ) - FigurePos( 4 );
end 



FigHandle = figure( 'Pos', FigurePos,  ...
'Name', get_param( blockHandleSliderGainTopMask, 'Name' ),  ...
'Color', get( 0, 'DefaultUIControlBackgroundColor' ),  ...
'Resize', 'off',  ...
'NumberTitle', 'off',  ...
'MenuBar', 'none',  ...
'HandleVisibility', 'callback',  ...
'IntegerHandle', 'off',  ...
'CloseRequestFcn', 'slideg CloseRequest',  ...
'DeleteFcn', 'slideg DeleteFigure' );




uicontrol( 'Parent', FigHandle,  ...
'Style', 'text',  ...
'String', getString( message( 'Simulink:dialog:lowLabel' ) ),  ...
'HorizontalAlignment', 'left',  ...
'Position', [ 2 * mFrameToText, 2 * mStdButtonHeight + 3 * HS, mStdButtonWidth, mLineHeight ] );

uicontrol( 'Parent', FigHandle,  ...
'Style', 'text',  ...
'String', getString( message( 'Simulink:dialog:highLabel' ) ),  ...
'HorizontalAlignment', 'right',  ...
'Position', [ 2 * mFrameToText + 2 * mStdButtonWidth, 2 * mStdButtonHeight + 3 * HS, mStdButtonWidth, mLineHeight ] );





[ low, gain, high ] = LocalMaskEntriesToParams( blockHandleSliderGainTopMask );

value = LocalGetValue( low, gain, high );
position = [ 2 * mFrameToText, 2 * mStdButtonHeight + mLineHeight + 4 * HS ...
, 3 * mStdButtonWidth, mStdButtonHeight ];
ud.Slider = uicontrol( 'Parent', FigHandle,  ...
'Style', 'slider',  ...
'Value', value,  ...
'Position', position,  ...
'enable', dlgState,  ...
'Callback', 'slideg Slider' );


Bup = 2 * HS + mStdButtonHeight;
ud.LowEdit = uicontrol( 'Parent', FigHandle,  ...
'Style', 'edit',  ...
'BackgroundColor', 'white',  ...
'Position', [ mFrameToText, Bup, ButtonWH ],  ...
'String', num2str( low ),  ...
'UserData', low,  ...
'enable', dlgState,  ...
'Callback', 'slideg LowEdit' );

ud.GainEdit = uicontrol( 'Parent', FigHandle,  ...
'Style', 'edit',  ...
'BackgroundColor', 'white',  ...
'Position', [ 2 * mFrameToText + mStdButtonWidth, Bup, ButtonWH ],  ...
'String', num2str( gain ),  ...
'UserData', gain,  ...
'enable', dlgState,  ...
'Callback', 'slideg GainEdit' );
ud.HighEdit = uicontrol( 'Parent', FigHandle,  ...
'Style', 'edit',  ...
'BackgroundColor', 'white',  ...
'Pos', [ 3 * mFrameToText + 2 * mStdButtonWidth, Bup, ButtonWH ],  ...
'String', num2str( high ),  ...
'UserData', high,  ...
'enable', dlgState,  ...
'Callback', 'slideg HighEdit' );




ud.Close = uicontrol( 'Parent', FigHandle,  ...
'Style', 'push',  ...
'String', getString( message( 'Simulink:utility:CloseButton' ) ),  ...
'Position', [ 2 * mStdButtonWidth + 3 * mFrameToText, HS, ButtonWH ],  ...
'Callback', 'slideg CloseRequest' );




ud.Help = uicontrol( 'Parent', FigHandle,  ...
'Style', 'push',  ...
'String', getString( message( 'Simulink:blocks:HelpButton' ) ),  ...
'Position', [ mStdButtonWidth + 2 * mFrameToText, HS, ButtonWH ],  ...
'Callback', 'slideg Help' );

set( 0, 'Units', ScreenUnit );




ud.blockHandleSliderGainTopMask = blockHandleSliderGainTopMask;
set( FigHandle, 'UserData', ud );




set_param( blockHandleSliderGainTopMask, 'UserData', FigHandle )

end 







function LocalDeleteBlockFcn( blockHandleSliderGainTopMask )

FigHandle = get_param( blockHandleSliderGainTopMask, 'UserData' );
if ishghandle( FigHandle ), 
delete( FigHandle );
end 







function LocalCloseBlockFcn( blockHandleSliderGainTopMask )

FigHandle = get_param( blockHandleSliderGainTopMask, 'UserData' );
if ishghandle( FigHandle ), 
delete( FigHandle );
end 







function LocalDeleteFigureFcn

FigHandle = get( 0, 'CallbackObject' );
ud = get( FigHandle, 'UserData' );

set_param( ud.blockHandleSliderGainTopMask, 'UserData', [  ] );







function LocalCloseRequestFigureFcn

cbo = get( 0, 'CallbackObject' );
cboType = get( cbo, 'type' );
switch cboType
case 'uicontrol', 
FigHandle = get( cbo, 'Parent' );
case 'figure'
FigHandle = cbo;
otherwise , 
DAStudio.error( 'Simulink:dialog:SlidegUnexpectedObject', mfilename );
end 

delete( FigHandle );







function LocalHelpFcn

ud = get( gcf, 'userdata' );
slhelp( ud.blockHandleSliderGainTopMask );







function LocalCopyBlockFcn( blockHandleNewDestinationSliderGain )



if ( ~isempty( get_param( blockHandleNewDestinationSliderGain, 'UserData' ) ) )
set_param( blockHandleNewDestinationSliderGain, 'UserData', [  ] );
end 







function LocalLoadBlockFcn( blockHandleSliderGainTopMask )

if strcmpi( get_param( bdroot( blockHandleSliderGainTopMask ), 'BlockDiagramType' ), 'Model' )
set_param( blockHandleSliderGainTopMask, 'UserData', [  ] );
end 
DisallowUnitGainElimination( blockHandleSliderGainTopMask );







function LocalNameChangeBlockFcn( blockHandleSliderGainAfterNameChanged )

FigHandle = get_param( blockHandleSliderGainAfterNameChanged, 'UserData' );
if ishghandle( FigHandle ), 
set( FigHandle, 'Name', get_param( blockHandleSliderGainAfterNameChanged, 'Name' ) );
end 







function LocalParentCloseBlockFcn( blockHandleSliderGainTopMask )

FigHandle = get_param( blockHandleSliderGainTopMask, 'UserData' );
if ishghandle( FigHandle ), 
delete( FigHandle );
end 







function LocalSliderFcn

FigHandle = gcf;
ud = get( FigHandle, 'UserData' );

[ low, gain, high ] = LocalMaskEntriesToParams( ud.blockHandleSliderGainTopMask );

gain = low + get( ud.Slider, 'Value' ) * ( high - low );

LocalSetLowGainHigh( ud, low, gain, high );







function [ newValue, errstr ] = LocalScanEntry( varNameStr, oldValue, textToScan )

newValue = oldValue;

scanSuccess = true;

[ potentialNewValue, count, errstr ] = sscanf( textToScan, '%f' );

if ( ~isempty( errstr ) ||  ...
1 ~= count ||  ...
isempty( potentialNewValue ) ||  ...
any( ~isfinite( potentialNewValue ) ) )

scanSuccess = false;
else 
newValue = potentialNewValue;
end 

if ~scanSuccess

switch varNameStr

case 'low'

errstr = DAStudio.message( 'Simulink:dialog:SlidegInvalidLowerLimit', textToScan );

case 'gain'

errstr = DAStudio.message( 'Simulink:dialog:SlidegInvalidGainValue', textToScan );

otherwise 

errstr = DAStudio.message( 'Simulink:dialog:SlidegInvalidUpperLimit', textToScan );
end 
end 







function LocalLowEditFcn

warnstr = '';
FigHandle = gcf;
ud = get( FigHandle, 'UserData' );

[ low, gain, high ] = LocalMaskEntriesToParams( ud.blockHandleSliderGainTopMask );

[ low, errstr ] = LocalScanEntry( 'low', low, get( ud.LowEdit, 'String' ) );

if ~isempty( errstr )

errordlg( errstr, 'Error', 'modal' );
return 
end 



if low > gain, 
warnstr = DAStudio.message( 'Simulink:dialog:SlidegLowerLimitGTGain',  ...
sprintf( '%g', low ),  ...
sprintf( '%g', gain ) );
low = gain;
end 

value = LocalGetValue( low, gain, high );
set( ud.Slider, 'Value', value );

LocalSetLowGainHigh( ud, low, gain, high );
set( ud.LowEdit, 'string', num2str( low ) )
set( ud.GainEdit, 'string', num2str( gain ) )
set( ud.HighEdit, 'string', num2str( high ) )


if ~isempty( warnstr )
warndlg( warnstr, DAStudio.message( 'Simulink:dialog:DCDWarnDialogName' ), 'modal' );
end 







function LocalGainEditFcn

FigHandle = gcf;
ud = get( FigHandle, 'UserData' );

[ low, gain, high ] = LocalMaskEntriesToParams( ud.blockHandleSliderGainTopMask );

[ gain, errstr ] = LocalScanEntry( 'gain', gain, get( ud.GainEdit, 'String' ) );

if ~isempty( errstr )

errordlg( errstr, 'Error', 'modal' );
return 
end 

if ( low > gain )
low = gain;
elseif ( gain > high ), 
high = gain;
end 

value = LocalGetValue( low, gain, high );
set( ud.Slider, 'Value', value );

LocalSetLowGainHigh( ud, low, gain, high );







function LocalHighEditFcn

warnstr = '';
FigHandle = gcf;
ud = get( FigHandle, 'UserData' );

[ low, gain, high ] = LocalMaskEntriesToParams( ud.blockHandleSliderGainTopMask );

[ high, errstr ] = LocalScanEntry( 'high', high, get( ud.HighEdit, 'String' ) );

if ~isempty( errstr )
errordlg( errstr, 'Error', 'modal' );
return 
end 



if ( gain > high ), 

warnstr = DAStudio.message( 'Simulink:dialog:SlidegUpperLimitLTGain',  ...
sprintf( '%g', high ),  ...
sprintf( '%g', gain ) );
high = gain;
end 

value = LocalGetValue( low, gain, high );
set( ud.Slider, 'Value', value );

LocalSetLowGainHigh( ud, low, gain, high );


if ~isempty( warnstr )
warndlg( warnstr, DAStudio.message( 'Simulink:dialog:DCDWarnDialogName' ), 'modal' );
end 







function blkPathStr = LocalBlkHandleToPath( blockHandle )

blkPathStr = [ get_param( blockHandle, 'Parent' ), '/', get_param( blockHandle, 'Name' ) ];







function LocalSetLowGainHigh( ud, low, gain, high )
modelHandle = bdroot( ud.blockHandleSliderGainTopMask );
if ( strcmp( get_param( modelHandle, 'SimulationStatus' ), 'initializing' ) )

errstr = DAStudio.message( 'Simulink:dialog:SlidegNoChangeWhenInit' );

errordlg( errstr, LocalBlkHandleToPath( ud.blockHandleSliderGainTopMask ), 'modal' );
return ;
end 
try 
LocalParamsToMaskEntries( ud.blockHandleSliderGainTopMask, low, gain, high );
set( ud.LowEdit, 'string', num2str( low ) )
set( ud.GainEdit, 'string', num2str( gain ) )
set( ud.HighEdit, 'string', num2str( high ) )
catch myException
errstr = DAStudio.message( 'Simulink:dialog:SlidegMATLABError', myException.message );
errordlg( errstr, LocalBlkHandleToPath( ud.blockHandleSliderGainTopMask ), 'modal' );
end 









function LocalSetDialogWidgetsState( blockHandleSliderGainTopMask )
FigHandle = get_param( blockHandleSliderGainTopMask, 'UserData' );
if ishghandle( FigHandle )
modelHandle = bdroot( blockHandleSliderGainTopMask );
dlgState = LocalGetDialogState( modelHandle );
ud = get( FigHandle, 'UserData' );
set( ud.Slider, 'enable', dlgState );
set( ud.LowEdit, 'enable', dlgState )
set( ud.GainEdit, 'enable', dlgState )
set( ud.HighEdit, 'enable', dlgState )

end 







function LocalStopBlockFcn( blockHandleSliderGainTopMask )

LocalSetDialogWidgetsState( blockHandleSliderGainTopMask );







function LocalStartBlockFcn( blockHandleSliderGainTopMask )

LocalSetDialogWidgetsState( blockHandleSliderGainTopMask );







function out = LocalGetDialogState( mdl )
out = 'on';
s = getModelSimStateTunability( mdl );
if ~s
out = 'off';
end 






function DisallowUnitGainElimination( blockHandleSliderGainTopMask )
cr = sprintf( '\n' );


blockHandleGainUnderMask = find_system( blockHandleSliderGainTopMask,  ...
'MatchFilter', @Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,  ...
'LookUnderMasks', 'all',  ...
'FollowLinks', 'on',  ...
'BlockType', 'Gain',  ...
'Name', [ 'Slider', cr, 'Gain' ] ...
 );
if ( ~isempty( blockHandleGainUnderMask ) && strcmp( get_param( bdroot( blockHandleSliderGainTopMask ), 'Lock' ), 'off' ) )
set_param( blockHandleGainUnderMask, 'AllowUnitGainElimination', 'off' )
end 









function LocalObsolete( orig_gcbh, nArgs, varargin )

if 6 == nArgs

low = varargin{ 3 };
gain = varargin{ 4 };
high = varargin{ 5 };

else 

low = varargin{ 1 };
gain = varargin{ 2 };
high = varargin{ 3 };

end 

set_param( orig_gcbh,  ...
'MaskPromptString', 'Low|Gain|High',  ...
'OpenFcn', 'slideg Open',  ...
'CloseFcn', 'slideg Close',  ...
'DeleteFcn', 'slideg DeleteBlock',  ...
'CopyFcn', 'slideg Copy',  ...
'LoadFcn', 'slideg Load',  ...
'NameChangeFcn', 'slideg NameChange',  ...
'ParentCloseFcn', 'slideg ParentClose' );

LocalParamsToMaskEntries( orig_gcbh, low, gain, high );

MSLDiagnostic( 'Simulink:dialog:SlidegObsolete', LocalBlkHandleToPath( orig_gcbh ) ).reportAsWarning;

% Decoded using De-pcode utility v1.2 from file /tmp/tmpS1yT3n.p.
% Please follow local copyright laws when handling this file.

