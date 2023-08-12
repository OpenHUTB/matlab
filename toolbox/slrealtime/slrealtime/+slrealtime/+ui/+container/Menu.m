classdef Menu < dynamicprops








properties ( Dependent )


SkipInstall
AsyncLoad
Application



ReloadOnStop
AutoImportFileLog
ExportToBaseWorkspace



WaitForReboot
end 
methods 
function value = get.SkipInstall( this )
value = this.LoadButton.SkipInstall;
end 
function set.SkipInstall( this, value )
this.LoadButton.SkipInstall = value;
end 

function value = get.AsyncLoad( this )
value = this.LoadButton.AsyncLoad;
end 
function set.AsyncLoad( this, value )
this.LoadButton.AsyncLoad = value;
end 

function value = get.Application( this )
value = this.LoadButton.Application;
end 
function set.Application( this, value )
this.LoadButton.Application = value;
end 

function value = get.ReloadOnStop( this )
value = this.StartStopButton.ReloadOnStop;
end 
function set.ReloadOnStop( this, value )
this.StartStopButton.ReloadOnStop = value;
end 

function value = get.AutoImportFileLog( this )
value = this.StartStopButton.AutoImportFileLog;
end 
function set.AutoImportFileLog( this, value )
this.StartStopButton.AutoImportFileLog = value;
end 

function value = get.ExportToBaseWorkspace( this )
value = this.StartStopButton.ExportToBaseWorkspace;
end 
function set.ExportToBaseWorkspace( this, value )
this.StartStopButton.ExportToBaseWorkspace = value;
end 

function value = get.WaitForReboot( this )
value = this.RebootButton.WaitForReboot;
end 
function set.WaitForReboot( this, value )
this.RebootButton.WaitForReboot = value;
end 
end 

methods ( Access = public )
function delete( this )
delete( this.TargetSelectorUpdatedListener );
delete( this.ConnectDisconnectButtonUpdatedListener );
delete( this.LoadButtonUpdatedListener );
delete( this.StartStopButtonUpdatedListener );
end 

function this = Menu( menuOrFigure, options )
R36
menuOrFigure( 1, 1 ){ mustBeNonempty, mustBeA( menuOrFigure, { 'matlab.ui.container.Menu', 'matlab.ui.Figure' } ) }
options.Name{ mustBeTextScalar } = message( 'slrealtime:appdesigner:MenuTarget' ).getString(  )
end 

if isa( menuOrFigure, 'matlab.ui.container.Menu' )
fig = ancestor( menuOrFigure.Parent, 'figure' );
else 
fig = menuOrFigure;
end 
this.Figure = fig;

this.TargetMenu = uimenu( menuOrFigure );
this.TargetMenu.Text = convertStringsToChars( options.Name );
this.SelectTargetMenu = uimenu( this.TargetMenu );
this.SelectTargetMenu.Text = message( 'slrealtime:appdesigner:MenuSelect' ).getString(  );





prop = this.addprop( 'TargetSelector' );
prop.SetAccess = 'private';

this.TargetSelector = slrealtime.ui.control.TargetSelector( fig );
this.TargetSelector.Position = [ 0, 0, 0, 0 ];
this.TargetSelector.Visible = 'off';

this.ConnectDisconnectButton = slrealtime.ui.control.ConnectButton( fig );
this.ConnectDisconnectButton.TargetSource = this.TargetSelector;
this.ConnectDisconnectButton.Position = [ 0, 0, 0, 0 ];
this.ConnectDisconnectButton.Visible = 'off';
this.ConnectDisconnectMenuItem = uimenu( this.TargetMenu,  ...
'MenuSelectedFcn', @( o, e )this.connectDisconectMenuItemSelected );

this.LoadButton = slrealtime.ui.control.LoadButton( fig );
this.LoadButton.TargetSource = this.TargetSelector;
this.LoadButton.Position = [ 0, 0, 0, 0 ];
this.LoadButton.Visible = 'off';
this.LoadMenuItem = uimenu( this.TargetMenu,  ...
'MenuSelectedFcn', @( o, e )this.loadMenuItemSelected,  ...
'Separator', 'on', 'Text', message( 'slrealtime:appdesigner:MenuLoadApp' ).getString(  ) );

this.StartStopButton = slrealtime.ui.control.StartStopButton( fig );
this.StartStopButton.TargetSource = this.TargetSelector;
this.StartStopButton.Position = [ 0, 0, 0, 0 ];
this.StartStopButton.Visible = 'off';
this.StartStopMenuItem = uimenu( this.TargetMenu,  ...
'MenuSelectedFcn', @( o, e )this.startStopMenuItemSelected,  ...
'Separator', 'on' );

this.UpdateButton = slrealtime.ui.control.UpdateButton( fig );
this.UpdateButton.TargetSource = this.TargetSelector;
this.UpdateButton.Position = [ 0, 0, 0, 0 ];
this.UpdateButton.Visible = 'off';
this.UpdateMenuItem = uimenu( this.TargetMenu,  ...
'MenuSelectedFcn', @( o, e )this.updateMenuItemSelected,  ...
'Separator', 'on' );

this.RebootButton = slrealtime.ui.control.RebootButton( fig );
this.RebootButton.TargetSource = this.TargetSelector;
this.RebootButton.Position = [ 0, 0, 0, 0 ];
this.RebootButton.Visible = 'off';
this.RebootMenuItem = uimenu( this.TargetMenu,  ...
'MenuSelectedFcn', @( o, e )this.rebootMenuItemSelected );

this.updateTargetMenu(  );




this.TargetSelectorUpdatedListener = addlistener( this.TargetSelector, 'GUIUpdated', @( src, evnt )this.updateTargetMenu(  ) );
this.ConnectDisconnectButtonUpdatedListener = addlistener( this.ConnectDisconnectButton, 'GUIUpdated', @( src, evnt )this.updateTargetMenu(  ) );
this.LoadButtonUpdatedListener = addlistener( this.LoadButton, 'GUIUpdated', @( src, evnt )this.updateTargetMenu(  ) );
this.StartStopButtonUpdatedListener = addlistener( this.StartStopButton, 'GUIUpdated', @( src, evnt )this.updateTargetMenu(  ) );
end 
end 

methods ( Access = public )
function configureForDeployedWithDefaultTarget( this )
prompt = 'Enter ip address for target computer:';
name = 'Enter ip address';
answer = inputdlg( prompt, name );
skip = isempty( answer ) || ( iscell( answer ) && isempty( answer{ 1 } ) );
if ~skip
tgname = answer{ 1 };

tgs = slrealtime.Targets;
try 
tgs.getTarget( tgs.getTargetNames{ 1 } ).TargetSettings.address = tgname;
catch ME
fig = this.Figure;
if strcmp( fig.Visible, 'off' )
return ;
end 
errorTitle = message( 'slrealtime:appdesigner:TargetErrorTitle' );
uialert(  ...
fig,  ...
slrealtime.internal.replaceHyperlinks( ME.message ), errorTitle.getString(  ),  ...
'Icon', 'error', 'Modal', true );
return ;
end 

this.TargetSelector.Dropdown.Value = tgname;
tgs.getTarget( tgs.getTargetNames{ 1 } ).TargetSettings.name = tgname;
this.updateTargetMenu(  );
end 
end 
end 

properties ( Hidden, Access = private, Transient, NonCopyable )
TargetMenu matlab.ui.container.Menu

Figure

SelectTargetMenu matlab.ui.container.Menu
SelectTargetMenuItems matlab.ui.container.Menu

ConnectDisconnectMenuItem matlab.ui.container.Menu
ConnectDisconnectButton

LoadMenuItem matlab.ui.container.Menu
LoadButton

StartStopMenuItem matlab.ui.container.Menu
StartStopButton

UpdateMenuItem matlab.ui.container.Menu
UpdateButton

RebootMenuItem matlab.ui.container.Menu
RebootButton










TargetSelectorUpdatedListener
ConnectDisconnectButtonUpdatedListener
LoadButtonUpdatedListener
StartStopButtonUpdatedListener
end 



methods ( Access = private )
function updateTargetMenu( this )








for i = 1:length( this.SelectTargetMenuItems )
delete( this.SelectTargetMenuItems( i ) );
end 
this.SelectTargetMenuItems = matlab.ui.container.Menu.empty;

items = this.TargetSelector.Dropdown.Items;
itemsData = this.TargetSelector.Dropdown.ItemsData;
value = this.TargetSelector.Dropdown.Value;
selectedIdx = find( strcmp( itemsData, value ) );

if slrealtime.internal.SLRTComponent.isDeployedWithDefaultTarget(  )
this.SelectTargetMenuItems( 1 ) = uimenu( this.SelectTargetMenu,  ...
'Text', items{ 1 },  ...
'MenuSelectedFcn', @( o, e )this.configureForDeployedWithDefaultTarget(  ) );
this.SelectTargetMenuItems( 1 ).Checked = 'off';

this.ConnectDisconnectMenuItem.Visible = 'off';
this.LoadMenuItem.Visible = 'off';
this.StartStopMenuItem.Visible = 'off';
this.UpdateMenuItem.Visible = 'off';
this.RebootMenuItem.Visible = 'off';
return ;
end 

this.ConnectDisconnectMenuItem.Visible = 'on';
this.LoadMenuItem.Visible = 'on';
this.StartStopMenuItem.Visible = 'on';
this.UpdateMenuItem.Visible = 'on';
this.RebootMenuItem.Visible = 'on';

for i = 1:length( items )
this.SelectTargetMenuItems( i ) = uimenu( this.SelectTargetMenu,  ...
'Text', items{ i },  ...
'MenuSelectedFcn', @( o, e )this.selectTargetMenuItemSelected( o ) );
if i == selectedIdx
this.SelectTargetMenuItems( i ).Checked = 'on';
else 
this.SelectTargetMenuItems( i ).Checked = 'off';
end 
end 








targetName = this.TargetSelector.TargetName;
this.ConnectDisconnectMenuItem.Enable = this.ConnectDisconnectButton.Button.Enable;
if strcmp( this.ConnectDisconnectButton.Button.Icon, this.ConnectDisconnectButton.ConnectedIcon )
this.ConnectDisconnectMenuItem.Text = message( 'slrealtime:appdesigner:MenuDisconnectFromTarget', targetName ).getString;
else 
this.ConnectDisconnectMenuItem.Text = message( 'slrealtime:appdesigner:MenuConnectToTarget', targetName ).getString(  );
end 
isNormalMode = strcmp( targetName,  ...
slrealtime.ui.control.TargetSelector.SIMULINK_NORMAL_MODE );





this.LoadMenuItem.Enable = this.LoadButton.Button.Enable;
if isNormalMode
this.LoadMenuItem.Text = message( 'slrealtime:appdesigner:MenuLoadModel' ).getString(  );
else 
this.LoadMenuItem.Text = message( 'slrealtime:appdesigner:MenuLoadApp' ).getString(  );
end 








this.StartStopMenuItem.Enable = this.StartStopButton.StartButton.Enable || this.StartStopButton.StopButton.Enable;
appName = this.LoadButton.Label.Text;
if isempty( appName )
appName{ 1 } = '';
end 
if this.StartStopButton.StartButton.Enable
this.StartStopMenuItem.Text = message( 'slrealtime:appdesigner:MenuStartApp', appName{ 1 } ).getString(  );
elseif this.StartStopButton.StopButton.Enable
this.StartStopMenuItem.Text = message( 'slrealtime:appdesigner:MenuStopApp', appName{ 1 } ).getString(  );
else 
this.StartStopMenuItem.Text = message( 'slrealtime:appdesigner:MenuStart' ).getString(  );
end 





targetName = this.TargetSelector.TargetName;
this.UpdateMenuItem.Enable = this.UpdateButton.Button.Enable;
this.UpdateMenuItem.Text = message( 'slrealtime:appdesigner:MenuUpdate', targetName ).getString;





targetName = this.TargetSelector.TargetName;
this.RebootMenuItem.Enable = this.RebootButton.Button.Enable;
this.RebootMenuItem.Text = message( 'slrealtime:appdesigner:MenuReboot', targetName ).getString;
end 

function selectTargetMenuItemSelected( this, o )

e.PreviousValue = this.TargetSelector.Dropdown.Value;


items = this.TargetSelector.Dropdown.Items;
itemsData = this.TargetSelector.Dropdown.ItemsData;
this.TargetSelector.Dropdown.Value = itemsData{ strcmp( items, o.Text ) };


e.Value = this.TargetSelector.Dropdown.Value;


this.TargetSelector.valueChanged( e );
end 

function connectDisconectMenuItemSelected( this )
this.ConnectDisconnectButton.buttonPushed(  );
end 

function loadMenuItemSelected( this )
this.LoadButton.buttonPushed(  );
end 

function startStopMenuItemSelected( this )
if this.StartStopButton.StartButton.Enable
this.StartStopButton.startButtonPushed(  );
else 
this.StartStopButton.stopButtonPushed(  );
end 
end 

function updateMenuItemSelected( this )
this.UpdateButton.buttonPushed(  );
end 

function rebootMenuItemSelected( this )
this.RebootButton.buttonPushed(  );
end 
end 




methods ( Access = public, Hidden )
function out = getForTesting( this, prop )
narginchk( 2, 2 );

if ~ischar( prop ) && ~isStringScalar( prop )
slrealtime.internal.throw.Error( 'slrealtime:appdesigner:InvalidPropertyName' );
end 

if ~contains( prop, '.' )
if isprop( this, prop )
out = this.( prop );
else 
slrealtime.internal.throw.Error( 'slrealtime:appdesigner:NotTargetProperty', prop, class( this ) );
end 
else 
props = split( prop, '.' );
numProps = length( props );
obj = this;
for i = 1:( numProps - 1 )
obj = obj.( char( props( i ) ) );
end 

if isprop( obj, char( props( numProps ) ) ) ||  ...
any( strcmp( fieldnames( obj ), char( props( numProps ) ) ) )
out = obj.( char( props( numProps ) ) );
else 
slrealtime.internal.throw.Error( 'slrealtime:appdesigner:NotTargetProperty', prop, class( obj ) );
end 
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6W7S1c.p.
% Please follow local copyright laws when handling this file.

