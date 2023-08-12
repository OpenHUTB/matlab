function sltipalert( action, arg1, dialogtitle, helptag, prefkey, actionLabel, actionCall )
























narginchk( 2, 7 );

action = lower( action );

switch ( action )
case 'create'


narginchk( 5, 7 );
if nargin < 7
narginchk( 5, 5 );
actionCall = {  };
actionLabel = '';
end 

if i_getpref( prefkey )

i_create( arg1, dialogtitle, helptag, prefkey, actionLabel, actionCall );
end 

case 'never'
narginchk( 2, 2 );

i_setpref( arg1, false );

case 'show'
narginchk( 2, 2 );

i_setpref( arg1, true );

otherwise 
DAStudio.error( 'Simulink:utility:invalidInputArgs', mfilename )

end 

end 


function i_create( strDlgDesc, strTitle, strHelpTag, strPrefsKey, actionLabel, actionCall )

AlertFig = dialog(  ...
'Visible', 'off',  ...
'Name', strTitle,  ...
'Pointer', 'arrow',  ...
'Units', 'points',  ...
'UserData', strPrefsKey,  ...
'IntegerHandle', 'off',  ...
'Resize', 'off',  ...
'WindowStyle', 'normal',  ...
'HandleVisibility', 'callback',  ...
'Tag', 'TipAlert' ...
 );
set( AlertFig, 'KeyPressFcn', { @i_keypress, AlertFig } );
set( AlertFig, 'DeleteFcn', @( ~, ~ )i_delete( AlertFig ) );

BtnFontSize = get( 0, 'FactoryUIControlFontSize' );
BtnFontName = get( 0, 'FactoryUIControlFontName' );



OkButtonString = DAStudio.message( 'Simulink:dialog:DCDOK' );
ButtonTag = 'OK';
ok_btn = uicontrol( AlertFig,  ...
'Style', 'pushbutton',  ...
'Units', 'points',  ...
'String', OkButtonString,  ...
'HorizontalAlignment', 'center',  ...
'FontUnits', 'points',  ...
'FontSize', BtnFontSize,  ...
'FontName', BtnFontName,  ...
'Tag', ButtonTag,  ...
'Callback', @( ~, ~ )i_ok( AlertFig ),  ...
'KeyPressFcn', { @i_keypress, AlertFig } ...
 );
OkSize = get( ok_btn, 'extent' );

helpButtonString = DAStudio.message( 'Simulink:dialog:DCDHelp' );
ButtonTag = 'Help';
help_btn = uicontrol( AlertFig,  ...
'Style', 'pushbutton',  ...
'Units', 'points',  ...
'CallBack', { @i_help },  ...
'String', helpButtonString,  ...
'HorizontalAlignment', 'center',  ...
'FontUnits', 'points',  ...
'FontSize', BtnFontSize,  ...
'FontName', BtnFontName,  ...
'Tag', ButtonTag,  ...
'UserData', strHelpTag ...
 );
HelpSize = get( help_btn, 'extent' );

if ~isempty( actionLabel )
ButtonTag = 'Action';
action_btn = uicontrol( AlertFig,  ...
'Style', 'pushbutton',  ...
'Units', 'points',  ...
'CallBack', { @i_action },  ...
'String', actionLabel,  ...
'HorizontalAlignment', 'center',  ...
'FontUnits', 'points',  ...
'FontSize', BtnFontSize,  ...
'FontName', BtnFontName,  ...
'Tag', ButtonTag,  ...
'UserData', actionCall ...
 );
ActionSize = get( action_btn, 'extent' );
else 
ActionSize = [ 0, 0, 0, 0 ];
end 


MsgHandle = uicontrol( AlertFig,  ...
'Style', 'text',  ...
'Units', 'points',  ...
'Tag', 'strDlgDesc',  ...
'FontUnits', 'points',  ...
'FontSize', BtnFontSize,  ...
'FontName', BtnFontName,  ...
'HorizontalAlignment', 'left' ...
 );


dontShowAgainStr = DAStudio.message(  ...
'Simulink:utility:DoNotShowThisMessageAgain' );
checkbox = uicontrol( AlertFig,  ...
'Style', 'checkbox',  ...
'Units', 'points',  ...
'String', dontShowAgainStr,  ...
'Tag', 'DontShowAgain',  ...
'HorizontalAlignment', 'left',  ...
'FontUnits', 'points',  ...
'FontWeight', 'bold',  ...
'FontSize', BtnFontSize,  ...
'FontName', BtnFontName ...
 );



[ MsgString, MsgSize ] = textwrap( MsgHandle, cellstr( strDlgDesc ), 65 );
MsgPos = [ 10, 60, MsgSize( 3 ), MsgSize( 4 ) ];
set( MsgHandle, 'String', MsgString, 'Position', MsgPos );



[ ~, CheckboxSize ] = textwrap( checkbox, cellstr( dontShowAgainStr ),  ...
numel( dontShowAgainStr ) + 1 );

xPadding = 10;
yPadding = 7;

CheckboxWidth = CheckboxSize( 3 ) + 20;
BtnWidth = max( [ OkSize( 3 ), HelpSize( 3 ), ActionSize( 3 ) ] ) + 20;
BtnHeight = max( [ OkSize( 4 ), HelpSize( 4 ), ActionSize( 4 ) ] ) + 3;


FigWidth = max( [ MsgSize( 3 ), CheckboxWidth, ( BtnWidth * 3 + xPadding * 2 ) ] ) + ( xPadding * 2 );


set( help_btn, 'Position',  ...
[ FigWidth - BtnWidth - xPadding, yPadding, BtnWidth, BtnHeight ] );
set( ok_btn, 'Position',  ...
[ FigWidth - ( BtnWidth * 2 ) - ( xPadding * 2 ), yPadding, BtnWidth, BtnHeight ] );

if ~isempty( actionLabel )
set( action_btn, 'Position',  ...
[ FigWidth - ( ( BtnWidth + xPadding ) * 3 ), yPadding, BtnWidth, BtnHeight ] );
end 

yCounter = yPadding * 2 + BtnHeight;

set( checkbox, 'Position',  ...
[ xPadding, yCounter, CheckboxWidth, CheckboxSize( 4 ) ] );

yCounter = yCounter + CheckboxSize( 4 ) + yPadding;

set( MsgHandle, 'Position',  ...
[ xPadding, yCounter, MsgSize( 3 ), MsgSize( 4 ) ] );

yCounter = yCounter + MsgSize( 4 ) + yPadding;

FigHeight = yCounter;

FigPos = get( 0, 'DefaultFigurePosition' );
FigPos( 3:4 ) = [ FigWidth, FigHeight ];


ScreenUnits = get( 0, 'Units' );
set( 0, 'Units', 'points' );
ScreenSize = get( 0, 'ScreenSize' );
set( 0, 'Units', ScreenUnits );

FigPos( 1 ) = ( ScreenSize( 3 ) - FigWidth ) / 2;
FigPos( 2 ) = ( ScreenSize( 4 ) - FigHeight ) / 2;

set( AlertFig, 'Position', FigPos );
set( AlertFig, 'Visible', 'on' );



mdl = bdroot;
if ~isempty( mdl )
Simulink.addBlockDiagramCallback( mdl, 'PreClose', strPrefsKey, @(  )i_delete( AlertFig ) );
end 

drawnow;

end 


function i_help( fig, ~ )


handles = guihandles( fig );
helptag = get( handles.Help, 'UserData' );
helpview( fullfile( docroot, 'mapfiles', 'simulink.map' ), helptag )

end 


function i_ok( fig )


handles = guihandles( fig );
strPrefsKey = get( handles.TipAlert, 'UserData' );
i_setpref( strPrefsKey, ~get( handles.DontShowAgain, 'Value' ) );
delete( fig );

end 


function i_delete( fig )

if ishandle( fig )
delete( fig );
end 

end 





function i_keypress( ~, evd, fig )
switch ( evd.Key )
case { 'return', 'space' }
i_ok( fig );
case 'escape'
i_delete( fig );
end 

end 


function i_action( obj, ~ )

action = get( obj, 'UserData' );
feval( action{ : } );
fig = get( obj, 'parent' );
i_ok( fig );

end 



function b = i_getpref( prefkey )


b = true;

s = settings;
if ~s.hasGroup( 'simulinkPreferenceFlags' )

return ;
end 
s = s.simulinkPreferenceFlags;
if ~s.hasSetting( prefkey )

return ;
end 
try 
b = s.( prefkey ).ActiveValue;
catch E


warning( E.identifier, '%s', E.message );
end 
end 


function i_setpref( prefkey, b )

s = settings;
if ~s.hasGroup( 'simulinkPreferenceFlags' )
s.addGroup( 'simulinkPreferenceFlags' );
end 
s = s.simulinkPreferenceFlags;
if ~s.hasSetting( prefkey )
s.addSetting( prefkey );
end 
try 
s.( prefkey ).PersonalValue = b;
catch E


warning( E.identifier, '%s', E.message );
end 
end 




% Decoded using De-pcode utility v1.2 from file /tmp/tmpHtKHmH.p.
% Please follow local copyright laws when handling this file.

