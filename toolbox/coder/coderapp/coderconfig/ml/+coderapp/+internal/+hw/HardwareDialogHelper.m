classdef ( Sealed )HardwareDialogHelper < handle








properties ( SetAccess = immutable, GetAccess = private )
Owner coderapp.internal.hw.HardwareDialog
Hardware coder.Hardware
FakeConfigSet coderapp.internal.hw.FakeConfigSet
CloseCallback function_handle
ParameterGroups struct
InitialStorageKeys cell
ResolvedStorageKeys cell
end 

properties ( Access = private )
DialogSchema struct
UpdatedStorageKeys struct
Applied logical = false
end 

properties ( Dependent, SetAccess = immutable )
HardwareData
end 

properties ( Constant, Access = private )
WIDGET_TAG_PREFIX = 'Tag_ConfigSet_CoderTarget_'
end 

methods 
function this = HardwareDialogHelper( owner, hwArg, closeCallback, initData )
R36
owner( 1, 1 )coderapp.internal.hw.HardwareDialog
hwArg{ mustBeA( hwArg, [ "char", "string", "coder.Hardware" ] ) }
closeCallback function_handle{ mustBeScalarOrEmpty( closeCallback ) } = function_handle.empty
initData struct{ mustBeScalarOrEmpty( initData ) } = struct.empty
end 

this.Owner = owner;

if ~isa( hwArg, 'coder.Hardware' )
hwArg = emlcprivate( 'projectCoderHardware', hwArg );
initToHardware = false;
else 
initToHardware = true;
end 
this.Hardware = hwArg;

this.ParameterGroups = codergui.internal.getHardwareParameterInfo( this.Hardware );
[ initData, this.InitialStorageKeys, this.ResolvedStorageKeys ] = this.initializeData( this.Hardware, initData, initToHardware );

this.FakeConfigSet = coderapp.internal.hw.FakeConfigSet( this.Hardware, initData );
this.CloseCallback = closeCallback;
end 

function dls = getDialogSchema( this )
this.rebuildDialogSchema(  );
dls = this.DialogSchema;
end 

function cs = getConfigSet( this )
cs = this.FakeConfigSet;
end 

function data = get.HardwareData( this )
data = this.filterData( rmfield( this.FakeConfigSet.Data, { 'UseCoderTarget', 'TargetHardware' } ) );
end 
end 

methods ( Hidden )
function onDialogClose( this )
if ~isempty( this.CloseCallback )
this.CloseCallback( this.HardwareData, this.Applied );
end 
end 

function onDialogApply( this )
this.applyToHardware(  );
this.Applied = true;
end 

function onWidgetChange( this, source, dialog, tag, widgetHint )


switch widgetHint.Callback
case 'widgetChangedCallback'
callback = 'codertarget.targethardware.doWidgetChangedCallback';
case 'useCoderTargetCallback'
callback = 'codertarget.targethardware.doUseCoderTargetCallback';
case 'targetHardwareChangedCallback'
callback = 'codertarget.targethardware.doTargetHardwareChangedCallback';
otherwise 
callback = widgetHint.Callback;
end 

logCleanup = this.Owner.Logger.debug( 'Hardware dialog widget changed (tag="%s", callback="%s")', tag, callback );%#ok<NASGU>

this.FakeConfigSet.Record = true;
cleanup = onCleanup( @(  )this.stopRecording(  ) );
if ~isempty( callback )
feval( callback, source, dialog, tag, widgetHint.Type );%#ok<FVAL>
end 

if widgetHint.DialogRefresh
this.Owner.Logger.debug( 'Refreshing hardware dialog due to %s', tag );
dialog.setEnabled( tag, this.evalAmbiguousString( widgetHint.Enabled ) );
dialog.setVisible( tag, this.evalAmbiguousString( widgetHint.Visible ) );
end 
end 
end 

methods ( Access = private )
function rebuildDialogSchema( this )
logCleanup = this.Owner.Logger.trace( 'Rebuilding hardware dialog schema' );%#ok<NASGU>
hw = this.Hardware;
pGroups = this.ParameterGroups;
dls.Items = cell( 1, numel( pGroups ) );

for i = 1:numel( pGroups )
panel = this.groupToWidget( pGroups( i ) );
panel.Tag = sprintf( 'Tag_ParamGroup_%d', i );
dls.Items{ i } = panel;
end 

dls.DialogTitle = hw.Name;
dls.DisplayIcon = 'toolbox/shared/dastudio/resources/ActiveConfiguration.png';
dls.StandaloneButtonSet = createCustomButtonPanel(  );
dls.CloseMethod = 'onDialogClose';
dls.PostApplyMethod = 'onDialogApply';
dls.DialogTag = 'HardwareDialog';

this.DialogSchema = configset.internal.util.convertDDGSchema( dls );
end 

function panel = groupToWidget( this, group )
logger = this.Owner.Logger;
logCleanup = logger.trace( 'Generating panel schema for param group "%s"', group.name );%#ok<NASGU>

panel.Type = 'group';
panel.Name = group.name;
panel.Items = cell( 1, numel( group.parameters ) );

for i = 1:numel( group.parameters )
pDef = group.parameters{ i };
widget = this.setValueFromObj( this.defToWidget( pDef ), pDef.SaveValueAsString );
panel.Items{ i } = widget;
logger.trace( 'Appending widget of type "%s" for param "%s"', widget.Type, pDef.Name );
end 
end 


function widget = defToWidget( this, widgetHint )
userData.Storage = widgetHint.Storage;
userData.ValueType = widgetHint.ValueType;
userData.ValueRange = widgetHint.ValueRange;
userData.Entries = widgetHint.Entries;
if ~isempty( widgetHint.Entries ) && isfield( widgetHint, 'EntriesType' ) && strcmp( widgetHint.EntriesType, 'callback' )
widgetHint.Entries = eval( widgetHint.Entries{ 1 } );
end 

widget.Type = widgetHint.Type;
widget.Name = widgetHint.Name;
widget.Tag = [ this.WIDGET_TAG_PREFIX, widgetHint.Tag ];
widget.Alignment = double( widgetHint.Alignment );
widget.RowSpan = double( widgetHint.RowSpan );
widget.ColSpan = double( widgetHint.ColSpan );
widget.DialogRefresh = widgetHint.DialogRefresh;
widget.UserData = userData;

if ~isequal( widgetHint.Type, 'pushbutton' )
widget.Entries = widgetHint.Entries;
widget.Value = widgetHint.Value;
if ~any( strcmp( widgetHint.Storage, this.InitialStorageKeys ) )
codertarget.data.setParameterValueForWidget( this, widgetHint );
end 
end 

widget.Enabled = this.evalAmbiguousString( widgetHint.Enabled );
widget.Visible = this.evalAmbiguousString( widgetHint.Visible );

if isfield( widgetHint, 'ToolTip' ) && ischar( widgetHint.ToolTip )
widget.ToolTip = widgetHint.ToolTip;
end 


widget.ObjectMethod = 'onWidgetChange';
widget.MethodArgs = { '%source', '%dialog', '%tag', widgetHint };
widget.ArgDataTypes = { 'handle', 'handle', 'string', 'mxArray' };
end 


function widget = setValueFromObj( this, widget, saveValueAsString )
ud = widget.UserData;
if ~isempty( ud ) && ~isempty( ud.Storage )
fieldName = ud.Storage;
else 
fieldName = strrep( widget.Tag, this.WIDGET_TAG_PREFIX, '' );
end 
if codertarget.data.isParameterInitialized( this.FakeConfigSet, fieldName )
objectValue = codertarget.data.getParameterValue( this.FakeConfigSet, fieldName );
if isequal( widget.Type, 'combobox' ) && saveValueAsString

try 
[ found, idx ] = ismember( objectValue, widget.Entries );
catch e %#ok<NASGU>
found = 0;
end 
if ~found
objectValue = 0;
codertarget.data.setParameterValue( this.FakeConfigSet, fieldName,  ...
widget.Entries{ objectValue + 1 } );
else 
objectValue = idx - 1;
end 
end 
widget.Value = objectValue;
elseif ~isequal( widget.Type, 'pushbutton' )
if ischar( widget.Value ) && ~saveValueAsString
widget.Value = evalin( 'base', widget.Value );
end 
dialog = this.Owner.Dialog;
if ~isempty( dialog ) && ~isequal( dialog.getWidgetValue( widget.Tag ), widget.Value )
dialog.setWidgetValue( widget.Tag, widget.Value );
end 
end 
end 

function value = evalAmbiguousString( this, raw )
if ischar( raw )
if any( strcmp( raw, { '1', '0', 'true', 'false' } ) )
value = evalin( 'base', raw );
else 
if nargin( raw ) ~= 0
args = { this };
else 
args = {  };
end 
value = feval( raw, args{ : } );
end 
else 
value = raw;
end 
end 

function filtered = filterData( this, data )%#ok<INUSD>


whitelist = union( this.InitialStorageKeys, this.FakeConfigSet.ModifiedStorageKeys );

filtered = struct(  );
this.forEachStoredParam( @visitParam );

function visitParam( pDef )
if ~any( strcmp( pDef.Storage, whitelist ) )
return 
end 
if any( strcmp( pDef.Storage, this.ResolvedStorageKeys ) )
pathStr = [ 'data.', pDef.Storage ];
try 
[ ~, exampleValue ] = evalc( [ 'this.Hardware.', pDef.Storage ] );
massaged = resolveValueTypes( eval( pathStr ), exampleValue );%#ok<EVLDOT,NASGU>
eval( sprintf( 'filtered.%s = massaged;', pDef.Storage ) );
catch 
end 
end 
end 
end 

function applyToHardware( this )
logger = this.Owner.Logger;
logCleanup = logger.trace( 'Applying dialog state to underlying Hardware object' );%#ok<NASGU>

hw = this.Hardware;
if ~isempty( hw )
data = this.HardwareData;%#ok<NASGU>
this.forEachStoredParam( @visitParam );
end 

function visitParam( pDef )
try 
evalc( sprintf( 'hw.%s = data.%s;', pDef.Storage, pDef.Storage ) );
logger.trace( @(  )sprintf( 'Setting %s to: %s', pDef.Storage, getLoggableValueStr( pDef ) ) );
catch me
logger.warn( @(  )sprintf( 'Error when trying to set value for %s to %s: %s',  ...
pDef.Storage, getLoggableValueStr( pDef ), me.message ) );
end 
end 

function str = getLoggableValueStr( pDef )
str = coderapp.internal.value.valueToExpression( eval( sprintf( 'data.%s', pDef.Storage ) ) );
end 
end 

function [ data, storageKeys, resolvedKeys ] = initializeData( this, hw, initial, initToHardware )%#ok<INUSL>
data = struct(  );
storageKeys = {  };
resolvedKeys = {  };
this.forEachStoredParam( @visitParam );

function visitParam( pDef )
initialized = false;
resolved = [  ];
if ~isempty( initial )
try 
evalc( [ 'initial.', pDef.Storage ] );
initialized = true;
catch 
end 
end 
if initToHardware && ~initialized
try 
[ ~, value ] = evalc( [ 'hw.', pDef.Storage ] );%#ok<ASGLU>
initialized = true;
resolved = true;
catch 
end 
end 
if initialized
eval( sprintf( 'data.%s = value;', pDef.Storage ) );
storageKeys{ end  + 1 } = pDef.Storage;
end 
if isempty( resolved )
try 
evalc( [ 'hw.', pDef.Storage ] );
resolved = true;
catch 
resolved = false;
end 
end 
if resolved
resolvedKeys{ end  + 1 } = pDef.Storage;
end 
end 
end 

function forEachStoredParam( this, task )
groups = this.ParameterGroups;
for i = 1:numel( groups )
for j = 1:numel( groups( i ).parameters )
pDef = groups( i ).parameters{ j };
if ~isempty( pDef.Storage )
task( pDef );
end 
end 
end 
end 

function stopRecording( this )
this.FakeConfigSet.Record = false;
end 
end 

methods ( Static, Hidden )
function onDialogButtonClicked( dlg, commit )
if commit
dlg.apply(  );
end 
dlg.delete(  );
end 
end 
end 

function panel = createCustomButtonPanel(  )
ok.Type = 'pushbutton';
ok.Name = message( 'coderApp:config:coderGeneral:hwDialogOk' ).getString(  );
ok.ColSpan = [ 2, 2 ];
ok.Tag = 'Tag_HardwareDialog_OkButton';
ok.MatlabMethod = 'coderapp.internal.hw.HardwareDialogHelper.onDialogButtonClicked';
ok.MatlabArgs = { '%dialog', true };

cancel.Type = 'pushbutton';
cancel.Name = message( 'coderApp:config:coderGeneral:hwDialogCancel' ).getString(  );
cancel.ColSpan = [ 3, 3 ];
cancel.Tag = 'Tag_HardwareDialog_CancelButton';
cancel.MatlabMethod = 'coderapp.internal.hw.HardwareDialogHelper.onDialogButtonClicked';
cancel.MatlabArgs = { '%dialog', false };

spacer.Type = 'panel';

panel.Type = 'panel';
panel.LayoutGrid = [ 1, 3 ];
panel.ColStretch = [ 1, 0, 0 ];
panel.Items = { spacer, ok, cancel };
panel.Tag = 'Tag_HardwareDialog_ButtonPanel';
end 


function value = resolveValueTypes( value, example )
if ( ischar( value ) || isstring( value ) ) && isnumeric( example )
value = str2double( value );
end 
if isnumeric( value ) || islogical( value )
value = cast( value, 'like', example );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpIzR92o.p.
% Please follow local copyright laws when handling this file.

