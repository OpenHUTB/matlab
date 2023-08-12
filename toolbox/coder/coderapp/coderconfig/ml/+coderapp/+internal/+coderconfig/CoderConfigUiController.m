classdef CoderConfigUiController < coderapp.internal.config.ui.ConfigDialogController



properties ( Access = private )
UiPostProcessed logical = false

RealShowTcOptions
RealShowHwImpl
HwImplKeys cell = {  }

HwDialog coderapp.internal.hw.HardwareDialog
HwConfigButton codergui.internal.form.model.Button
TcOptionPanel codergui.internal.form.model.Panel
TcOptionsLink codergui.internal.form.model.Button
DevicesPanel codergui.internal.form.model.Panel
TargetHwImplPanel codergui.internal.form.model.Panel
ProdHwImplPanel codergui.internal.form.model.Panel
HwImplLink codergui.internal.form.model.Button
DeepLearningSpkgLink codergui.internal.form.model.Button

CustomSourceTabPane codergui.internal.form.model.TabbedPane
CustomSourceEditor codergui.internal.form.model.TextEditor
CustomHeaderEditor codergui.internal.form.model.TextEditor
CustomInitEditor codergui.internal.form.model.TextEditor
CustomTermEditor codergui.internal.form.model.TextEditor

MisraPanel codergui.internal.form.model.ContentPanel
MisraController = [  ]

TargetFrameworkNeedsRefresh logical = false;
TargetFrameworkSubscription = [  ];
end 

properties ( Dependent, Access = private )
ShowTcOptions logical
ShowHardwareImpl logical
HasMisraAdvisor logical
end 

properties ( Dependent, SetAccess = immutable )
IsProject logical
IsFullConfig logical
end 

methods 
function this = CoderConfigUiController( varargin )
this@coderapp.internal.config.ui.ConfigDialogController( varargin{ : } );
end 

function showHardwareDialog( this, newDialog )
R36
this
newDialog = true
end 

if ~isempty( this.HwDialog )
this.Logger.trace( 'Bringing existing hardware dialog to the front' );
this.HwDialog.show(  );
elseif newDialog
hwName = this.Configuration.get( 'hardwareName' );
if coderapp.internal.hw.HardwareConfigController.isHardwareName( hwName )
logCleanup = this.Logger.info( 'Opening hardware dialog for "%s"', hwName );%#ok<NASGU>
try 
this.HwDialog = coderapp.internal.hw.HardwareDialog( hwName,  ...
InitialData = this.Configuration.export( 'hardwareData' ),  ...
OnClose = @( data, applied )this.onHardwareDialogClosed( data, applied ),  ...
Logger = this.Logger );
catch me
coder.internal.gui.asyncDebugPrint( me );
this.Logger.error( 'Error creating hardware dialog: %s', me.message );
end 
this.UiModel.GlobalEnabled = false;
end 
end 
end 

function closeHardwareDialog( this, commit )
R36
this
commit( 1, 1 )logical = true
end 

if ~isempty( this.HwDialog )
logCleanup = this.Logger.debug( 'Closing hardware dialog (Commit=%g)', commit );%#ok<NASGU>
this.HwDialog.close( commit );
end 
end 

function show = get.ShowTcOptions( this )
show = this.Configuration.get( 'x_showCustomToolchainOptions' );
end 

function set.ShowTcOptions( this, show )
this.Configuration.set( 'x_showCustomToolchainOptions', show );
end 

function show = get.ShowHardwareImpl( this )
show = this.Configuration.get( 'x_showHardwareImpl' );
end 

function set.ShowHardwareImpl( this, show )
this.Configuration.set( 'x_showHardwareImpl', show );
end 

function result = get.HasMisraAdvisor( this )
result = strcmp( this.Owner.ConfigClass, 'coder.EmbeddedCodeConfig' );
end 

function full = get.IsFullConfig( this )
full = any( strcmp( this.Owner.ConfigClass,  ...
{ 'coder.CodeConfig', 'coder.EmbeddedCodeConfig', 'coder.MexCodeConfig' } ) );
end 

function isProj = get.IsProject( this )
isProj = this.Configuration.get( 'x_isApp' );
end 

function delete( this )
if ~isempty( this.HwDialog )
this.HwDialog.delete(  );
end 
if ~isempty( this.TargetFrameworkSubscription )
delete( this.TargetFrameworkSubscription );
this.TargetFrameworkSubscription = [  ];
end 
delete@coderapp.internal.config.ui.ConfigUiController( this );
end 
end 

methods ( Access = { ?coderapp.internal.config.ui.ConfigDialogController, ?coderapp.internal.config.ui.ConfigDialog } )
function attachToUi( this )
logCleanup = this.Logger.trace( 'Entering attachToUi' );%#ok<NASGU>
attachToUi@coderapp.internal.config.ui.ConfigDialogController( this );
cleanup = this.transaction(  );%#ok<NASGU>            

if this.IsFullConfig
this.setupForCoderConfig(  );
end 
this.UiModel.ShowNavigationBar = this.IsFullConfig ||  ...
strcmp( this.Owner.ConfigClass, 'coder.MexConfig' );

this.updateTitle(  );
this.addlistener( 'WorkspaceVariable', 'PostSet', @( ~, ~ )this.updateTitle(  ) );

docRef = coderapp.internal.util.DocRef(  );
docRef.TopicId = 'help_button_config_dialog';
docRef.MapFile = 'coder/helptargets.map';
this.UiModel.DocProviderConfig.ReferencePage = docRef;

if any( [ "coder.CodeConfig", "coder.EmbeddedCodeConfig", "coder.HardwareImplementation" ] == this.Owner.ConfigClass )
this.TargetFrameworkSubscription = targetframework.internal.repository.subscribeToGlobalChanges( @(  )this.targetFrameworkListener(  ) );
end 
this.commit(  );
end 
function targetFrameworkListener( this )
this.TargetFrameworkNeedsRefresh = true;
end 
end 

methods ( Access = protected )
function binding = createBinding( this, bindable )
switch bindable.Key
case { 'customSourceCode', 'customHeaderCode', 'customInitializer', 'customTerminator' }
factory = @createCustomSourceEditor;
case 'category_customSourceCode'
factory = @createCustomSourcePanel;
case 'hardwareName'
factory = @createHardwareWidget;
case 'toolchain'
factory = @createToolchainWidget;
case 'customToolchainOptions'
factory = @createToolchainOptionsWidget;
case 'buildConfiguration'
factory = @createBuildConfigurationWidget;
case { 'category_devices', 'category_hardwareImpl' }
factory = @createDevicesPanel;
case { 'category_prodDevice', 'category_targetDevice' }
factory = @createSingleDevicePanel;
case { 'category_prodSizes', 'category_targetSizes' }
factory = @createHwImplPanel;
case 'category_misra'
factory = @createMisraPanel;
otherwise 
binding = [  ];
return 
end 

binding = coderapp.internal.config.ui.WidgetBinding( this.MfzModel );
binding.Widget = factory( this, bindable );
end 

function uiModel = createConfigUiModel( ~, mfzModel )
uiModel = coderapp.internal.coderconfig.CoderConfigDialogModel( mfzModel );
end 

function handleConfigurationChange( this, evt )
this.Configuration.UndoRedoTransparent = true;
keys = evt.Keys;
for i = 1:numel( keys )
switch keys{ i }
case 'targetLang'
this.updateTextEditorSyntaxes(  );
case { 'hardwareName', 'hardware' }
this.updateHardwareWidget(  );
case { 'toolchain', 'customToolchainOptions', 'buildConfiguration' }
this.updateToolchainOptionPanel(  );
this.updateTcOptionsLink(  );
case 'x_showCustomToolchainOptions'
this.updateTcOptionsLink(  );
case 'x_showHardwareImpl'
this.updateHardwareSizeLink(  );
case 'gpuEnabled'
this.updateDeepLearningLink(  );
case 'name'
this.updateTitle(  );
end 
end 
if ~isempty( this.MisraController ) && this.HasMisraAdvisor
this.MisraController.update( evt );
end 
this.Configuration.UndoRedoTransparent = false;
end 

function handleUiModelChange( this, report )
handleUiModelChange@coderapp.internal.config.ui.ConfigDialogController( this, report );

this.Configuration.UndoRedoTransparent = true;
if this.TargetFrameworkNeedsRefresh
this.TargetFrameworkNeedsRefresh = false;
this.Configuration.refresh( 'hardwareName' );
end 
if ~this.UiPostProcessed && this.UiModel.PrimarySubview.Populated
this.appendHardwareSizeLink(  );
this.updateTextEditorSyntaxes(  );
this.UiPostProcessed = true;
elseif report.isModified( this.UiModel, 'SearchContext' ) ||  ...
( ~isempty( this.UiModel.SearchContext ) && report.isModified( this.UiModel.SearchContext ) )
this.onSearchChanged(  );
end 
this.Configuration.UndoRedoTransparent = false;
end 

function resyncBoundObject( this, force )
R36
this
force = false
end 
if ~this.UiPostProcessed || ~this.UiModel.PrimarySubview.Populated ||  ...
isempty( this.Owner.BoundObjectKey ) || isempty( this.ProductionKey )
return 
end 
resyncBoundObject@coderapp.internal.config.ui.ConfigDialogController( this, force );
end 

function onWindowFocusChanged( this, focused )
R36
this
focused = this.WindowFocused
end 
if focused && ~isempty( this.HwDialog )

timer( 'StartDelay', 0.2, 'StopFcn', @( t, ~ )t.delete(  ),  ...
'TimerFcn', @( ~, ~ )this.showHardwareDialog( false ) ).start(  );
end 
onWindowFocusChanged@coderapp.internal.config.ui.ConfigDialogController( this, focused );
end 
end 

methods ( Access = private )
function setupForCoderConfig( this )
this.Logger.debug( 'Configuring in full config mode (i.e. not MexConfig or HardwareImplementation)' );
cats = this.Configuration.State.Categories.toArray(  );
cats = cats( ismember( { cats.Key }, { 'category_prodDeviceDetails', 'category_targetDeviceDetails',  ...
'category_prodSizes', 'category_targetSizes' } ) );
keys = cell( 1, numel( cats ) );
for i = 1:numel( cats )
params = cats( i ).Params.toArray(  );
keys{ i } = { params.Key };
end 
this.HwImplKeys = [ keys{ : } ];
end 

function widget = createHardwareWidget( this, ~ )
this.Logger.trace( 'Creating hardware widget' );
hwConfigButton = codergui.internal.form.model.Button( this.MfzModel );
hwConfigButton.Text = message( 'coderApp:config:dialogGui:configureHardwareButton' ).getString(  );
hwConfigButton.fire.registerHandler( @( ~, resultHolder )this.onConfigureHardware( resultHolder ) );
hwConfigButton.WidgetTag = 'ConfigureHardware';
this.HwConfigButton = hwConfigButton;
widget = codergui.internal.form.model.ComboBox( this.MfzModel );
widget.Children.add( hwConfigButton );
if this.Configuration.isAwake( 'hardwareName' )
this.updateHardwareWidget(  );
end 
end 

function updateHardwareWidget( this )
if ~this.IsFullConfig
return 
end 
this.Logger.trace( 'Updating hardware widget' );
hw = this.Configuration.get( 'hardware' );
hwEnabled = this.Configuration.getAttr( 'hardwareName', 'Enabled' );
hwEnabled = hwEnabled && ~isempty( hw );
if hwEnabled
hwEnabled = ~isempty( hw.ParameterInfo.Parameter ) && any( ~cellfun( 'isempty', hw.ParameterInfo.Parameter ) );
end 
this.HwConfigButton.Enabled = hwEnabled;
if ~isempty( this.HwDialog ) && ( ~hwEnabled || ~strcmp( hw.Name, this.HwDialog.Hardware.Name ) )
this.closeHardwareDialog( false );
end 
end 

function onConfigureHardware( this, resultHolder )
this.showHardwareDialog(  );
resultHolder.Passed = true;
end 

function onHardwareDialogClosed( this, data, applied )
this.UiModel.GlobalEnabled = true;
this.HwDialog = coderapp.internal.hw.HardwareDialog.empty(  );
if applied
this.Configuration.import( 'hardwareData', data );
end 
end 

function widget = createToolchainWidget( this, ~ )
this.Logger.trace( 'Creating toolchain widget' );
valButton = codergui.internal.form.model.Button( this.MfzModel );
valButton.Text = message( 'coderApp:config:dialogGui:validateToolchainButton' ).getString(  );
valButton.fire.registerHandler( @( ~, resultHolder )this.onValidateToolchain( resultHolder ) );
valButton.WidgetTag = 'validateToolchainButton';
this.HwConfigButton = valButton;
widget = codergui.internal.form.model.ComboBox( this.MfzModel );
widget.Children.add( valButton );
end 

function onValidateToolchain( this, resultHolder )
[ tc, tcOpts, buildConfig ] = this.Configuration.export(  ...
'toolchain', 'customToolchainOptions', 'buildConfiguration' );
this.UiModel.GlobalEnabled = false;
logCleanup = this.Logger.debug( 'Validating current toolchain: %s', tc );%#ok<NASGU>

try 
coder.make.internal.guicallback.validateToolchain( tc, buildConfig, tcOpts );
resultHolder.Passed = true;
catch me
errMsg = codergui.internal.form.model.UiMessage(  );
errMsg.Type = codergui.internal.form.model.MessageType( 'ERROR' );
errMsg.Message = me.message;
resultHolder.Message = errMsg;
resultHolder.Passed = false;
coder.internal.gui.asyncDebugPrint( me );
this.Logger.warn( 'Error occurred in coder.make.internal.guicallback.validateToolchain: %s', me.message );
end 
this.UiModel.GlobalEnabled = true;
end 

function widget = createToolchainOptionsWidget( this, ~ )
this.Logger.trace( 'Creating toolchain options widget' );
widget = codergui.internal.form.model.Panel( this.MfzModel );
widget.Indent = true;
this.TcOptionPanel = widget;
if this.Configuration.isAwake( { 'toolchain', 'customToolchainOptions', 'buildConfiguration' } )
this.updateToolchainOptionPanel(  );
end 
end 

function updateToolchainOptionPanel( this )
if isempty( this.TcOptionPanel )
return 
end 

logCleanup = this.Logger.trace( 'Updating toolchain options panel' );%#ok<NASGU>
[ opts, buildConfig ] = this.Configuration.get( 'customToolchainOptions', 'buildConfiguration' );
optFields = opts( 1:2:end  );
optValues = opts( 2:2:end  );
enabled = strcmpi( buildConfig, 'Specify' ) && this.Configuration.getAttr( 'toolchain', 'Enabled' );
this.TcOptionPanel.Visible = this.ShowTcOptions;

widgets = this.TcOptionPanel.Children.toArray(  );
for i = 1:numel( widgets )
widgets( i ).destroy(  );
end 
if ~this.ShowTcOptions
return 
end 

for i = 1:numel( optFields )
widget = codergui.internal.form.model.TextField( this.MfzModel );
widget.Label = codergui.internal.form.model.PlainText( this.MfzModel );
widget.commit.registerHandler( @( ~, resultHolder )this.onToolchainOptionChanged( widget, i, resultHolder ) );
this.TcOptionPanel.Children.add( widget );
widget.Enabled = enabled;
widget.Label.Content = optFields{ i };
widget.Value = optValues{ i };
widget.WidgetTag = sprintf( 'customToolchainOptionField%d', i );
this.Logger.trace( 'Creating toolchain option "%s": %s', optFields{ i }, optValues{ i } );
end 
end 

function onToolchainOptionChanged( this, widget, optFieldIdx, resultHolder )
opts = this.Configuration.get( 'customToolchainOptions' );
opts{ optFieldIdx * 2 } = widget.Value;
logCleanup = this.Logger.debug( 'Applying change to toolchain option "%s": %s', opts{ optFieldIdx * 2 - 1:optFieldIdx * 2 } );%#ok<NASGU>
this.Configuration.set( 'customToolchainOptions', opts );
resultHolder.Passed = true;
end 

function widget = createBuildConfigurationWidget( this, ~ )
this.Logger.trace( 'Creating build configuration widget' );
this.TcOptionsLink = this.createHyperlink( 'coderApp:config:dialogGui:validateToolchainButton',  ...
@this.onShowToolchainOptions );
this.TcOptionsLink.WidgetTag = 'showCustomToolchainOptions';
widget = codergui.internal.form.model.ComboBox( this.MfzModel );
widget.Children.add( this.TcOptionsLink );

if this.Configuration.isAwake( { 'buildConfiguration', 'customToolchainOptions' } )
this.updateTcOptionsLink(  );
end 
end 

function updateTcOptionsLink( this )
if ~this.IsFullConfig
return 
end 
this.Logger.trace( 'Updating toolchain options link' );
if this.ShowTcOptions
this.TcOptionsLink.Text = message( 'coderApp:config:dialogGui:hideToolchainOptions' ).getString(  );
else 
this.TcOptionsLink.Text = message( 'coderApp:config:dialogGui:showToolchainOptions' ).getString(  );
end 
this.TcOptionsLink.Enabled = this.Configuration.getAttr( 'buildConfiguration', 'Enabled' ) &&  ...
~isempty( this.Configuration.get( 'customToolchainOptions' ) );
end 

function onShowToolchainOptions( this )
next = ~this.ShowTcOptions;
this.Logger.debug( 'Toggling toolchain option visibility to %g', next );
this.ShowTcOptions = next;
end 

function panel = createCustomSourcePanel( this, ~ )
this.Logger.trace( 'Creating custom source settings panel' );
panel = codergui.internal.form.model.FormPanel( this.MfzModel );
tabPane = codergui.internal.form.model.TabbedPane( this.MfzModel );
tabPane.SelectedIndex = uint32( 0 );
panel.Children.add( tabPane );
this.CustomSourceTabPane = tabPane;
end 

function addCustomSourceTab( this, param, content )
tab = codergui.internal.form.model.Tab( this.MfzModel );
tab.Name = param.Data.Name;
tab.Children.add( content );
this.CustomSourceTabPane.Children.add( tab );
end 

function editor = createCustomSourceEditor( this, bindable )
this.Logger.trace( 'Creating custom source editor for "%s"', bindable.Key );
arg.Resizable = false;
arg.ShowLabel = false;
editor = codergui.internal.form.model.TextEditor( this.MfzModel, arg );
switch bindable.Key
case 'customSourceCode'
this.CustomSourceEditor = editor;
case 'customHeaderCode'
this.CustomHeaderEditor = editor;
case 'customInitializer'
this.CustomInitEditor = editor;
case 'customTerminator'
this.CustomTermEditor = editor;
otherwise 
assert( false, 'Unexpected key "%s"', bindable.Key );
end 
this.addCustomSourceTab( bindable, editor );
end 

function updateTextEditorSyntaxes( this )
if ~this.IsFullConfig
return 
end 
switch this.Configuration.get( 'targetLang' )
case 'C'
syntax = 'C';
case 'C++'
syntax = 'CPP';
otherwise 
assert( false, 'Unexppected targetLang value "%s"',  ...
this.Configuration.get( 'targetLang' ) );
end 
this.Logger.trace( 'Updating custom source editor language to "%s"', syntax );
this.CustomSourceEditor.Syntax = syntax;
this.CustomHeaderEditor.Syntax = syntax;
this.CustomInitEditor.Syntax = syntax;
this.CustomTermEditor.Syntax = syntax;
end 

function widget = createDeepLearningLibWidget( this, ~ )
if ~this.IsFullConfig
return 
end 
this.Logger.trace( 'Creating deep learning widget' );
widget = codergui.internal.form.model.CombobBox( this.MfzModel );


this.updateDeepLearningLink(  );
end 

function updateDeepLearningLink( this )
if ~this.IsFullConfig
return 
end 
end 

function updateTitle( this )
if this.IsProject
title = strtrim( this.Configuration.get( 'name' ) );
else 
if this.IsFullConfig
cfgName = strtrim( this.Configuration.get( 'name' ) );
else 
cfgName = '';
end 
if ~isempty( cfgName )
title = cfgName;
else 
title = this.Owner.ConfigClass;
end 
if ~isempty( this.WorkspaceVariable )
title = sprintf( '%s - %s', this.WorkspaceVariable, title );
end 
end 

this.Logger.trace( @(  )sprintf( 'Changing config dialog title "%s" -> "%s"',  ...
this.UiModel.Title, title ) );
this.UiModel.Title = title;
if ~isempty( this.Owner.Client )
this.Owner.Client.WindowTitle = title;
end 
end 

function link = createHyperlink( this, msgKey, callback )
link = codergui.internal.form.model.Hyperlink( this.MfzModel );
link.Text = message( msgKey ).getString(  );
link.fire.registerHandler( @onLinkFired );

function onLinkFired( ~, resultHolder )
callback(  );
resultHolder.Passed = true;
end 
end 

function onSearchChanged( this )
revertTcVis = false;
revertHwVis = false;
if isempty( this.UiModel.SearchContext )

revertTcVis = ~isempty( this.RealShowTcOptions );
revertHwVis = ~isempty( this.RealShowHwImpl );
else 
matches = this.UiModel.SearchContext.Matches.toArray(  );
matches = [ matches.Binding ];
matches = { matches.Key };
hasTcOpts = any( strcmp( matches, 'customToolchainOptions' ) );
hasHwImpls = ~isempty( intersect( matches, this.HwImplKeys ) );
if hasTcOpts == isempty( this.RealShowTcOptions )
if hasTcOpts
this.RealShowTcOptions = this.ShowTcOptions;
this.ShowTcOptions = true;
else 
revertTcVis = true;
end 
end 
if hasHwImpls == isempty( this.RealShowHwImpl )
if hasHwImpls
this.RealShowHwImpl = this.ShowHardwareImpl;
this.ShowHardwareImpl = true;
else 
revertHwVis = true;
end 
end 
end 
if revertTcVis
this.ShowTcOptions = this.RealShowTcOptions;
this.RealShowTcOptions = [  ];
end 
if revertHwVis
this.ShowHardwareImpl = this.RealShowHwImpl;
this.RealShowHwImpl = [  ];
end 
end 
end 

methods ( Access = private )
function panel = createDevicesPanel( this, category )
if strcmp( category.Key, 'category_devices' )
panel = codergui.internal.form.model.Panel( this.MfzModel );
else 
panel = codergui.internal.form.model.FormPanel( this.MfzModel );
end 
this.DevicesPanel = panel;
end 

function panel = createHwImplPanel( this, cat )
panel = codergui.internal.form.model.FormPanel( this.MfzModel );
if cat.Key == "category_targetDevice"
this.TargetHwImplPanel = panel;
else 
this.ProdHwImplPanel = panel;
end 
end 

function panel = createSingleDevicePanel( this, ~ )
panel = codergui.internal.form.model.FormPanel( this.MfzModel );
end 

function appendHardwareSizeLink( this )
link = this.createHyperlink( 'coderApp:config:dialogGui:showHardwareImplementation',  ...
@this.onShowHardwareSizes );
link.WidgetTag = 'showHardwareImplementation';
this.HwImplLink = link;
this.updateHardwareSizeLink(  );
this.DevicesPanel.Children.add( link );
end 

function updateHardwareSizeLink( this )
if this.ShowHardwareImpl
this.HwImplLink.Text = message( 'coderApp:config:dialogGui:hideHardwareImplementation' ).getString(  );
else 
this.HwImplLink.Text = message( 'coderApp:config:dialogGui:showHardwareImplementation' ).getString(  );
end 
end 

function onShowHardwareSizes( this )
next = ~this.ShowHardwareImpl;
this.Logger.debug( 'Toggling visibility of hardware size widgets to %g', next );
this.ShowHardwareImpl = next;
end 

function panel = createMisraPanel( this, ~ )
this.Logger.trace( 'Creating MISRA panel' );
panel = codergui.internal.form.model.FormPanel( this.MfzModel );
misraPanel = codergui.internal.form.model.ContentPanel( this.MfzModel );
misraPanel.DijitModule = "coderconfigdialog/widgets/MisraAdvisor";
misraPanel.WidgetTag = "misra";
panel.Children.add( misraPanel );
this.MisraPanel = misraPanel;
this.MisraController = coderapp.internal.coderconfig.MisraController(  ...
this.UiModel, this.MfzModel, this.Configuration );
this.UiModel.applyMisraRecommendations.registerHandler( @( ~, resultHolder )this.onApplyMisraRecommendations( resultHolder ) );
end 

function onApplyMisraRecommendations( this, resultHolder )
logCleanup = this.Logger.info( 'Applying MISRA recommendations' );%#ok<NASGU>
this.MisraController.applyRecommendations(  );
resultHolder.Passed = true;
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmp6ZGbrB.p.
% Please follow local copyright laws when handling this file.

