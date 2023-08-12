classdef QABManager < handle


properties ( Access = 'protected' )
QAB;
Config;
CustomQAG;
DefaultQAG;
CustomWidgets;
DefaultWidgets dig.QABEntries;
Studio;
end 

properties ( Abstract )
ConfigName;
end 

properties ( Constant )
QabName = 'qab';
RefreshEvent = 'QABRefresh';
CustomRefreshEvent = 'CustomQAGRefresh';
CustomQAGroupName = 'customQuickAccessGroup';
DefaultQAGroupName = 'simulinkQuickAccessGroup';
DefaultPrefFile = 'qabprefs.txt';
end 

methods ( Abstract )

initDefaults( obj );
end 

methods ( Static, Access = 'protected' )
function out = setGetInstance( subclassName, instance )
out = [  ];
persistent instances;

if isempty( instances )
instances = containers.Map;
end 

if nargin > 1
instances( subclassName ) = instance;
out = instance;
else 
if isKey( instances, subclassName )
out = instances( subclassName );
end 
end 
end 
end 

methods ( Static )
function testUserData( userdata, ~ )
disp( userdata );
end 

function obj = get( varargin )
if nargin > 0
subclassName = varargin{ 1 };
else 
DAStudio.error( 'Simulink:utility:invNumArgsWithAbsValue', mfilename, 1 );
end 

instance = dig.QABManager.setGetInstance( subclassName );
if isempty( instance ) || ~isvalid( instance )
mgr = feval( subclassName );
if ~isempty( mgr )
instance = dig.QABManager.setGetInstance( subclassName, mgr );
end 
end 
obj = instance;
end 

function clearInstance( subclassName )
dig.QABManager.setGetInstance( subclassName, [  ] );
end 

function gw = generate( userdata, ~ )
gw = [  ];
manager = dig.QABManager.get( userdata );
gw = manager.QAB;

manager.onGenerate(  );
end 

function addToQuickAccessBarCB( userdata, cbinfo )
this = dig.QABManager.get( userdata );
this.addCustomWidget( cbinfo.EventData );
end 

function removeFromQuickAccessBarCB( userdata, cbinfo )
this = dig.QABManager.get( userdata );


widgetName = this.stripNamePrefix( cbinfo.EventData );
this.removeCustomWidget( widgetName );
end 

function moveInQuickAccessBarCB( userdata, cbinfo )
this = dig.QABManager.get( userdata );
data = split( cbinfo.EventData, ',' );
this.moveWidget( data{ 1 }, str2num( data{ 2 } ) );%#ok<ST2NM>
end 

function showTextInQuickAccessBarCB( userdata, cbinfo )
this = dig.QABManager.get( userdata );
data = split( cbinfo.EventData, ',' );
widgetName = this.stripNamePrefix( data{ 1 } );
this.showWidgetText( widgetName, str2num( data{ 2 } ) );%#ok<ST2NM>
end 

function restoreQuickAccessBarPresetsCB( userdata, ~ )
this = dig.QABManager.get( userdata );
this.restoreFactoryPresets(  );
end 

function gw = generateCustomQAG( userdata, cbinfo )
this = dig.QABManager.get( userdata );
typeChain = cbinfo.Context.TypeChain;

gw = dig.GeneratedWidget( cbinfo.EventData.namespace, cbinfo.EventData.type );

entries = this.CustomWidgets.getEntries(  );
for index = 1:length( entries )
this.createCustomWidget( gw, entries( index ), typeChain );
end 
end 
end 

methods 
function this = QABManager(  )

this.generateQAB(  );
end 

function onGenerate( ~ )


end 

function generateQAB( this )
this.clear(  );

subclassName = this.SubclassName;
this.QAB = dig.GeneratedWidget( this.QabName, 'QuickAccessBar' );



this.CustomQAG = this.QAB.Widget.addChild( 'QuickAccessGroup', this.CustomQAGroupName );
this.CustomQAG.setGeneratorFromArray( { @dig.QABManager.generateCustomQAG, subclassName }, dig.model.FunctionType.Action );
this.CustomQAG.Generator.eventTriggers.add( this.CustomRefreshEvent );


this.DefaultQAG = this.QAB.Widget.addChild( 'QuickAccessGroup', this.DefaultQAGroupName );

this.loadPreferences(  );
this.restoreDefaults(  );
dig.postStringEvent( this.RefreshEvent );
end 

function onRestore( ~ )

end 

function restoreFactoryPresets( this )
if exist( this.getPrefFile, 'file' ) == 2

delete( this.getPrefFile );
end 
this.generateQAB(  );
this.onRestore(  );
end 

function clear( this )
this.QAB = [  ];
this.clearCustomQAB(  );
end 

function delete( this )
filepath = fileparts( this.getPrefFile(  ) );
if exist( filepath, 'dir' )
this.savePreferences(  );
end 
end 

function config = getConfiguration( this )
config = dig.Configuration.getOrCreate( this.ConfigName, pwd );
end 

function state = getWidgetStates( this )

state = struct(  );
state.DefaultWidgets = this.DefaultWidgets.serialize;
state.CustomWidgets = this.CustomWidgets.serialize;
end 

function setWidgetStates( this, state )

if isfield( state, 'CustomWidgets' )
this.CustomWidgets = dig.QABEntries;
this.CustomWidgets.loadEntries( state.CustomWidgets );
end 

if isfield( state, 'DefaultWidgets' )
this.DefaultWidgets = dig.QABEntries;
this.DefaultWidgets.loadEntries( state.DefaultWidgets );
end 

this.restoreDefaults(  );
dig.postStringEvent( this.CustomRefreshEvent );
end 

function val = getPrefFile( this, varargin )
if nargin > 1 && ischar( varargin{ 1 } )
val = varargin{ 1 };
elseif isprop( this, 'PrefFile' ) && ~isempty( this.PrefFile )
val = this.PrefFile;
else 
subfolder = this.ConfigName;

filename = this.DefaultPrefFile;
val = fullfile( prefdir, subfolder, filename );
end 
end 

function widget = getWidgetFromProvider( ~, ~ )

widget = [  ];
end 

function addCustomWidget( this, widgetName )

if ( length( widgetName ) > 8 && strcmp( widgetName( end  - 8:end  ), '_favorite' ) )
widgetName = widgetName( 1:end  - 9 );
end 


config = this.getConfiguration(  );
widget = config.lookupWidget( widgetName );

this.addWidgetToCustomGroup( widget );
end 

function addWidgetToCustomGroup( this, widget, shouldAddQABLabel )





R36
this dig.QABManager;
widget;
shouldAddQABLabel = false;
end 

if ~isempty( widget )
config = this.getConfiguration(  );
widgetName = widget.Name;

customWidget = this.CustomWidgets.getEntryByName( widgetName );
if isempty( customWidget )
customWidget.Name = widgetName;
customWidget.ActionId = widget.ActionId;
customWidget.ShowText = shouldAddQABLabel;

this.CustomWidgets.addEntry( customWidget, true );
this.CustomWidgets.updateIndexByOrder(  );
end 
customWidget.ShowText = shouldAddQABLabel;


config.addToQAB( widget.ActionId );
dig.postStringEvent( this.CustomRefreshEvent );
end 
end 

function createCustomWidget( this, gw, widget, typeChain )
config = this.getConfiguration(  );
sourceButton = config.lookupWidget( widget.Name );

if isempty( sourceButton )
sourceButton = this.getWidgetFromProvider( widget.Name );
end 

if ~isempty( sourceButton )

if isa( sourceButton, 'dig.model.Tool' )
switch sourceButton.ToolType
case { 'PushButton', 'GalleryItem', 'ListItem' }
widgetType = 'QABPushButton';
case { 'DropDownButton', 'ListItemWithPopup' }
widgetType = 'QABDropDownButton';
case { 'ToggleButton', 'ToggleGalleryItem', 'ListItemWithCheckBox' }
widgetType = 'QABToggleButton';
case 'SplitButton'
widgetType = 'QABSplitButton';
case 'ToggleSplitButton'
widgetType = 'QABToggleSplitButton';
otherwise 
error( 'Unsupported widget for add to QAB.' );
end 

qabButton = gw.Widget.addChild( widgetType, widget.Name );
qabButton.copyProperties( sourceButton, false, '' );
qabButton.ToolType = widgetType;

if ~isempty( typeChain )
override = config.getWidgetOverride( widget.Name, typeChain );
qabButton.applyOverride( override.composite );
end 

if ~isempty( widget.ActionId )
config.addToQAB( widget.ActionId );
end 

qabButton.ShowText = widget.ShowText;
end 
end 
end 

function onRemove( ~, ~ )


end 

function removeCustomWidget( this, widgetName )
if ~isempty( this.CustomWidgets.getEntryByName( widgetName ) )


config = this.getConfiguration(  );
widget = config.lookupWidget( widgetName );
if ~isempty( widget )
config.removeFromQAB( widget.ActionId );
end 
this.CustomWidgets.removeEntry( widgetName );
this.onRemove( widgetName );

dig.postStringEvent( this.CustomRefreshEvent );
end 
end 

function restoreDefaults( this )
defaultEntries = this.DefaultWidgets.getEntries(  );
for i = 1:length( defaultEntries )
defaultEntries( i ).addWidget( this.DefaultQAG );
end 
end 

function moveCustomWidget( this, fromIndex, newIndex )
entries = this.CustomWidgets.getEntries(  );
numCustomWidgets = length( entries );
if newIndex > numCustomWidgets
error( 'simulink_ui:studio:resources:qabIndexOutOfRange',  ...
message( 'simulink_ui:studio:resources:qabIndexOutOfRange' ).getString(  ) );
end 

this.CustomWidgets.moveEntry( fromIndex, newIndex );
this.CustomWidgets.updateIndexByOrder(  );
dig.postStringEvent( this.CustomRefreshEvent );
end 

function moveDefaultWidget( this, widgetName, newIndex )


entries = this.DefaultWidgets.getEntries(  );
fromIndex = 0;
toIndex = 0;
visibleWidgets = 0;
size = length( entries );
for index = 1:size
widget = entries( index ).Widget;
if strcmp( widgetName, widget.Name )
if ~widget.Visible
error( 'simulink_ui:studio:resources:qabCannotMoveInvisibleWidget',  ...
message( 'simulink_ui:studio:resources:qabCannotMoveInvisibleWidget' ).getString(  ) );
end 
fromIndex = index;
end 
if widget.Visible
visibleWidgets = visibleWidgets + 1;
if visibleWidgets == newIndex
toIndex = index;
end 
end 
end 

if fromIndex == 0
error( 'simulink_ui:studio:resources:qabInvalidDefaultWidgetName',  ...
message( 'simulink_ui:studio:resources:qabInvalidDefaultWidgetName', widgetName ).getString(  ) );
end 

if toIndex == 0
error( 'simulink_ui:studio:resources:qabIndexOutOfRange',  ...
message( 'simulink_ui:studio:resources:qabIndexOutOfRange' ).getString(  ) );
end 

this.DefaultWidgets.moveEntry( fromIndex, toIndex );
dig.postStringEvent( this.RefreshEvent );
end 

function moveWidget( this, widgetName, newIndex )
widgetName = this.stripNamePrefix( widgetName );
[ cwEntry, fromIndex ] = this.CustomWidgets.getEntryByName( widgetName );
if ~isempty( cwEntry )
this.moveCustomWidget( fromIndex, newIndex );
else 
this.moveDefaultWidget( widgetName, newIndex );
end 
end 

function clearCustomQAB( this )
config = this.getConfiguration(  );
config.clearQAB(  );
dig.postStringEvent( this.CustomRefreshEvent );
end 

function loadPreferences( this, varargin )
prefs = this.readPreferences( varargin{ : } );


this.CustomWidgets = dig.QABEntries(  );

this.DefaultWidgets = dig.QABEntries(  );

if ~isempty( prefs )
if prefs.DefaultEntries.hasEntries(  )
this.DefaultWidgets = prefs.DefaultEntries;
end 

if prefs.CustomEntries.hasEntries(  )
this.CustomWidgets = prefs.CustomEntries;
end 
else 

this.initDefaults( this.DefaultWidgets );
this.DefaultWidgets.updateOrderByIndex(  );
end 
end 

function prefs = readPreferences( this, varargin )
prefs = [  ];
prefFilePath = this.getPrefFile( varargin{ : } );

if exist( prefFilePath, 'file' ) == 2
try 
prefs = load( prefFilePath, '-mat' );
prefs.CustomEntries = dig.QABEntries(  );
prefs.DefaultEntries = dig.QABEntries(  );
prefs.CustomEntries.loadEntries( prefs.CustomWidgets );
prefs.DefaultEntries.loadEntries( prefs.DefaultWidgets );
catch 
prefs = [  ];
try 
delete( prefFilePath );
catch 
end 
end 
end 
end 

function savePreferences( this, varargin )
prefFilePath = this.getPrefFile( varargin{ : } );

if ( isempty( this.CustomWidgets ) )
this.CustomWidgets = dig.QABEntries(  );
end 

if ( isempty( this.DefaultWidgets ) )
this.DefaultWidgets = dig.QABEntries(  );
this.initDefaults( this.DefaultWidgets );
end 

prefs = struct;
prefs.version = '1.0.0';
prefs.CustomWidgets = this.CustomWidgets.serialize(  );
prefs.DefaultWidgets = this.DefaultWidgets.serialize(  );

fileDir = fileparts( prefFilePath );
if ~exist( fileDir, 'dir' )
mkdir( fileDir );
end 

save( prefFilePath, '-struct', 'prefs', '-mat' );
end 

function entry = getEntryByName( this, widgetName )
entry = this.DefaultWidgets.getEntryByName( widgetName );
if isempty( entry )
entry = this.CustomWidgets.getEntryByName( widgetName );
end 
end 

function onShowText( ~, ~, ~ )


end 

function showWidgetText( this, widgetName, show )
entry = this.getEntryByName( widgetName );

if isempty( entry )
return ;
end 

entry.toggleText( show );
this.onShowText( widgetName, show );
dig.postStringEvent( this.CustomRefreshEvent );
end 

function name = stripNamePrefix( this, name )

name = regexprep( name, [ '^', this.QabName, ':' ], '' );

name = regexprep( name, [ '^', this.CustomQAGroupName, ':' ], '' );
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpqNXi75.p.
% Please follow local copyright laws when handling this file.

