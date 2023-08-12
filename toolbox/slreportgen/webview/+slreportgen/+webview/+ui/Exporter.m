classdef Exporter < handle








properties ( Access = public )




StartModelObjHid





StartSysName





















Scope




IncludeReferencedModels





IncludeLibraryLinks





IncludeMWLibraryLinks




IncludeMaskedSubsystems







ExcludedSystems



IncludeNotes





ExportFolder



ExportPackageName





IncrPackageName




DisplayWebView


RegisteredViews







PackagingType



ShowProgressBar





IncrementalExport = false
end 

properties ( Hidden )
SystemView slreportgen.webview.ViewExporter


StartSysId;
end 

properties ( Transient, Access = protected )





HierModel




ExcludeTree


m_optViews

ModelBuilder
end 

properties ( Access = private )
m_dlgTitle;
m_cacheStartSysObj;
m_cacheStartModelObjHid;
end 

properties ( Transient, Access = private )
CachedCurrentExportDiagram
end 


methods ( Access = public )

function this = Exporter( varargin )












if nargin > 0
in = varargin{ 1 };
if ~isempty( in )
if isa( in, 'GLUE2.HierarchyId' )
this.StartModelObjHid = in;
else 
this.StartModelObjHid = slreportgen.utils.HierarchyService.getDiagramHID( in );
end 

this.StartSysName = this.StartSysObj.Handle.getFullName;
this.ExportFolder = pwd;

[ ~, name ] = slreportgen.utils.pathParts( this.StartSysName );

name = char( name );
name = regexprep( name, '//', '/' );
name = regexprep( name, '[/|\n]', '_' );
this.ExportPackageName = name;
else 
this.StartSysName = '';
this.ExportFolder = pwd;
this.ExportPackageName = '';
end 

this.Scope = 'all';
this.ExcludedSystems = {  };

this.IncludeReferencedModels = false;
this.IncludeLibraryLinks = false;
this.IncludeMWLibraryLinks = false;
this.IncludeMaskedSubsystems = false;
this.IncludeNotes = false;

this.IncrPackageName = false;
this.DisplayWebView = true;
this.ShowProgressBar = true;
this.PackagingType = 'zipped';
end 
end 
end 

properties ( Dependent )






StartSysObj

end 

methods 
function obj = get.StartSysObj( h )
if ( ~isempty( h.StartModelObjHid ) &&  ...
( isempty( h.m_cacheStartSysObj ) || ~isequal( h.m_cacheStartModelObjHid, h.StartModelObjHid ) ) )

h.m_cacheStartSysObj = slreportgen.webview.SlProxyObject( h.StartModelObjHid );
h.m_cacheStartModelObjHid = h.StartModelObjHid;
end 

obj = h.m_cacheStartSysObj;
end 

function set.StartSysObj( h, obj )
if ~isempty( obj )
h.StartModelObjHid = slreportgen.utils.HierarchyService.getDiagramHID( obj );
else 
h.StartModelObjHid = [  ];
end 
h.m_cacheStartSysObj = [  ];
h.m_cacheStartModelObjHid = [  ];
end 
end 

methods ( Access = private )
function refreshDialog( this, startHID, dialog )
R36
this
startHID GLUE2.HierarchyId
dialog{ mustBeA( dialog, "DAStudio.Dialog" ) }
end 

e = slreportgen.webview.ui.Exporter.loadExporter(  ...
slreportgen.webview.SlProxyObject( startHID ) );

this.StartSysObj = startHID;
this.StartSysName = this.StartSysObj.Handle.getFullName;
this.ExportFolder = e.ExportFolder;
this.ExportPackageName = e.ExportPackageName;
this.Scope = e.Scope;
this.IncludeReferencedModels = e.IncludeReferencedModels;
this.IncludeLibraryLinks = e.IncludeLibraryLinks;
this.IncludeMWLibraryLinks = e.IncludeMWLibraryLinks;
this.IncludeMaskedSubsystems = e.IncludeMaskedSubsystems;
this.ExcludedSystems = e.ExcludedSystems;
this.IncrPackageName = e.IncrPackageName;
this.PackagingType = e.PackagingType;
this.RegisteredViews = [  ];
this.HierModel = [  ];
this.IncrementalExport = e.IncrementalExport;
this.updateExcludeTree( dialog );
dialog.refresh(  );
delete( e );
end 
end 






methods ( Static, Access = protected )

function child = getChildNode( parent, childName )
child = [  ];
for i = 1:length( parent.Children )
node = parent.Children{ i };
if strcmp( node.DisplayLabel, childName )
child = node;
break ;
end 
end 
end 
end 

methods ( Access = public, Hidden )
function dt = getPropDataType( ~, propName )
dt = 'string';
switch propName
case 'StartSysObj'
dt = 'mxArray';
case 'ExcludedSystems'
dt = 'mxArray';
case 'RegisteredViews'
dt = 'mxArray';
case 'IncludeReferencedModels'
dt = 'bool';
case 'IncludeLibraryLinks'
dt = 'bool';
case 'IncludeMWLibraryLinks'
dt = 'bool';
case 'IncludeMaskedSubsystems'
dt = 'bool';
case 'IncludeNotes'
dt = 'bool';
case 'IncrPackageName'
dt = 'bool';
case 'DisplayWebView'
dt = 'bool';
case 'StartSysName'
dt = 'string';
case 'Scope'
case 'ExportFolder'
dt = 'string';
case 'ExportPackageName'
dt = 'string';
case 'PackagingType'
dt = 'string';
case 'IncrementalExport'
dt = 'bool';
otherwise 
dt = 'string';
end 
end 
end 


methods ( Access = public )


function exportPath = export( this, opts )






if ( isprop( 0, 'TerminalProtocol' ) && ~strcmpi( get( 0, 'TerminalProtocol' ), 'x' ) )

throw(  ...
MException( message( 'slreportgen_webview:exporter:NoExportWithoutDisplay' ) ) );
end 






exportPath = getExportPath( this );

saveExporter( this );

try 

progressBar = slreportgen.webview.ui.ProgressBar(  );

if nargin > 1 && isfield( opts, 'docType' )
docType = opts.docType;
else 
docType = 'InternalDocument';
end 

startHID = this.StartModelObjHid;
initialBlock = [  ];
hs = slreportgen.utils.HierarchyService;
if ~hs.isValid( this.StartModelObjHid )
startHID = hs.getParentDiagramHID( this.StartModelObjHid );
initialBlock = this.StartModelObjHid;
end 

if ( slreportgen.webview.internal.version == 3 )
model = this.getCreateExportModel(  );
if this.IncrementalExport && ~model.isBuiltWithCacheEnabled(  )
model = this.createExportModel(  );
end 

this.updateExportModel(  );
wvDoc = slreportgen.webview.internal.Document( exportPath, this.PackagingType );
prj = slreportgen.webview.internal.Project(  );
prj.addModel( model );
wvDoc.Project = prj;

dpath = slreportgen.utils.HierarchyService.getPath( startHID );
wvDoc.HomeDiagram = model.queryDiagrams( "path", dpath, "Count", 1 );

if ~isempty( this.SystemView )
wvDoc.SystemView = this.SystemView;
end 
if ~isempty( this.RegisteredViews )
wvDoc.OptionalViews = [ this.RegisteredViews{ : } ];
end 
wvDoc.IncrementalExport = this.IncrementalExport;

else 
model = this.getHierModel(  );
this.updateHierModel(  );
wvDoc = slreportgen.webview.( docType )( exportPath, this.PackagingType );
wvDoc.HomeSystem = model.getItem( startHID );
wvDoc.InitialBlock = initialBlock;
wvDoc.Systems = model;

wvDoc.OptionalViews = this.RegisteredViews;
if ~isempty( this.SystemView )
wvDoc.SystemView = this.SystemView;
end 
end 
wvDoc.IncludeNotes = this.IncludeNotes;

if this.DisplayWebView
webviewWeight = 0.9;
dispWeight = 0.1;
else 
webviewWeight = 1;
dispWeight = 0;
end 

displayProgressMonitor = slreportgen.webview.ProgressMonitor( 0, 1 );

addChild( progressBar, wvDoc.ProgressMonitor, webviewWeight );
addChild( progressBar, displayProgressMonitor, dispWeight );

progressBar.ShowMessagePriority = progressBar.ImportantMessagePriority;
setMessage( progressBar,  ...
message( 'slreportgen_webview:exporter:ExportingSystem', this.StartSysName ),  ...
progressBar.ImportantMessagePriority );

if this.ShowProgressBar
setTitle( progressBar,  ...
getString( message( 'slreportgen_webview:webview:ExportWaitbarMsg', this.StartSysName ) ) );
show( progressBar );
end 

wvDoc.open(  );
wvDoc.fill(  );
wvDoc.close(  );
catch me
done( progressBar );
rethrow( me )
end 



this.HierModel = [  ];
this.ModelBuilder = [  ];

[ folder, name, ~ ] = fileparts( exportPath );

if isCanceled( progressBar )
if strcmp( this.PackagingType, 'zipped' )
if exist( exportPath, 'file' )
delete( exportPath );
end 
end 

if strcmp( this.PackagingType, 'unzipped' ) || strcmp( this.PackagingType, 'both' )
unzipDir = fullfile( folder, name );
if exist( unzipDir, 'dir' )
rmdir( unzipDir, 's' );
end 
done( progressBar );
end 
return 
end 
zipname = fullfile( folder, strcat( name, '.zip' ) );

if strcmpi( this.PackagingType, 'zipped' ) || strcmpi( this.PackagingType, 'both' )
movefile( exportPath, zipname, 'f' );
end 

if this.DisplayWebView
displayWebView( this, exportPath, displayProgressMonitor );
end 

done( progressBar );
end 

function displayWebView( this, exportPath, progressMonitor )
import mlreportgen.dom.*;

[ ~, name, ~ ] = fileparts( exportPath );
mainPart = 'webview.html';

exportFolder = getResolvedExportFolder( this );

if strcmp( this.PackagingType, 'unzipped' ) || strcmp( this.PackagingType, 'both' )
viewdir = fullfile( exportFolder, name );
mainPart = 'webview.html';
else 

viewParentDir = fullfile( tempdir, 'mlreportgen' );
viewdir = fullfile( viewParentDir, 'webview' );
if exist( viewdir, 'dir' )
rmdir( viewdir, 's' );
try 
rmdir( viewParentDir, 's' );
catch 
end 
end 
mkdir( viewdir );
wvPath = fullfile( exportFolder, strcat( name, '.zip' ) );
setMessage( progressMonitor,  ...
message( 'slreportgen_webview:exporter:UnzippingFiles' ),  ...
progressMonitor.ImportantMessagePriority );
unzip( wvPath, viewdir );

if ispc(  )
fileattrib( viewdir, '+w', '', 's' );
else 
fileattrib( viewdir, '+w', 'a', 's' );
end 
end 
setMessage( progressMonitor,  ...
message( 'slreportgen_webview:exporter:DisplayingWebview' ),  ...
progressMonitor.ImportantMessagePriority );
web( fullfile( viewdir, mainPart ), '-browser' );
setValue( progressMonitor, 1 );
done( progressMonitor );
end 
end 

methods ( Access = private )
function exportFolder = getResolvedExportFolder( this )
exportFolder = this.ExportFolder;
if strcmpi( exportFolder, '$model' )
modelH = slreportgen.utils.getModelHandle( this.StartModelObjHid );
exportFolder = fileparts( get_param( modelH, 'FileName' ) );
end 
if isempty( exportFolder )
exportFolder = pwd;
end 

end 

function exportPath = getExportPath( this )
[ ~, name, ~ ] = fileparts( this.ExportPackageName );

exportFolder = getResolvedExportFolder( this );

baseName = fullfile( exportFolder, name );
fullName = baseName;
if this.IncrPackageName
i = 0;
while ( exist( fullName, 'dir' ) || exist( strcat( fullName, '.zip' ), 'file' ) )
i = i + 1;
fullName = strcat( baseName, num2str( i ) );
end 
end 



if strcmp( this.PackagingType, 'unzipped' )
exportPath = fullName;
else 
exportPath = strcat( fullName, '.htmx' );
end 
end 
end 






methods ( Static, Hidden )
function [ exporter, dialog, listener ] = getExporterRegistryProps(  )
exporter = 'slreportgen_WebViewExporter';
dialog = 'slreportgen_WebViewDialog';
listener = 'slreportgen_WebViewListener';
end 

function closeListenerFcn( ~, ~, oStartSys )

[ exporterProp, dialogProp, listenerProp ] =  ...
slreportgen.webview.ui.Exporter.getExporterRegistryProps(  );

try 
dlgHandle = get( oStartSys, dialogProp );
if ~isempty( dlgHandle ) && ishandle( dlgHandle )
delete( dlgHandle );
end 
catch ME
warning( message( 'slreportgen_webview:exporter:cannotCloseDialog', ME.message ) );
end 

delete( findprop( oStartSys, listenerProp ) );
delete( findprop( oStartSys, exporterProp ) );
end 
end 

methods ( Static, Access = public )
function dlgFindSystemCallback( thisDlgH )
src = thisDlgH.getSource(  );
if isa( src, 'slreportgen.WebViewExporterProxy' )
exporter = src.Exporter;
else 
exporter = src;
end 

try 
exporter.updateExcludeTree( thisDlgH );
catch 
exporter.HierModel = [  ];
exporter.updateExcludeTree( thisDlgH );
end 
thisDlgH.refresh(  );
end 

function dialog = showDialog( oStartSys, isStandAlone )













R36
oStartSys
isStandAlone logical = true;
end 

persistent APP_DIALOG

import slreportgen.webview.ui.*;
oStartHid = [  ];

if nargin < 1 || isempty( oStartSys )
oStartSys = [  ];
else 
try 
if isa( oStartSys, 'GLUE2.HierarchyId' )
oStartHid = oStartSys;
else 
oStartHid = slreportgen.utils.HierarchyService.getDiagramHID( oStartSys );
end 
oStartSys = slreportgen.webview.SlProxyObject( oStartHid );
catch ME
errordlg( getString( message( 'slreportgen_webview:exporter:invalidObjectLabel', ME.message ) ) );
end 
end 

if isStandAlone










[ exporterProp, dialogProp, listenerProp ] =  ...
slreportgen.webview.ui.Exporter.getExporterRegistryProps(  );





if ~isempty( findprop( oStartSys.Handle, exporterProp ) )
exporter = get( oStartSys.Handle, exporterProp );
else 
addprop( oStartSys.Handle, exporterProp );
exporter = [  ];
end 


if ~isempty( exporter ) ...
 && ~isempty( exporter.StartSysObj ) ...
 && ~strcmp( exporter.StartSysName, exporter.StartSysObj.Handle.getFullName(  ) )
exporter = [  ];
end 

if isempty( exporter ) || ~isa( exporter, 'slreportgen.webview.ui.Exporter' )
exporter = Exporter.loadExporter( oStartSys );
set( oStartSys.Handle, exporterProp, exporter );
end 

exporter.StartModelObjHid = oStartHid;





if ~isempty( findprop( oStartSys.Handle, dialogProp ) )
dialog = get( oStartSys.Handle, dialogProp );
else 
addprop( oStartSys.Handle, dialogProp );
dialog = [  ];
end 

if isempty( dialog ) || ~ishandle( dialog )
dialog = DAStudio.Dialog( exporter, 'standalone', 'DLG_STANDALONE' );
set( oStartSys.Handle, dialogProp, dialog );
else 
refresh( dialog );
show( dialog );
end 





if ~isempty( findprop( oStartSys.Handle, listenerProp ) )
closeListener = get( oStartSys.Handle, listenerProp );
else 
addprop( oStartSys.Handle, listenerProp );
closeListener = [  ];
end 

if isempty( closeListener )




if isa( oStartSys.Handle, 'Simulink.BlockDiagram' )
eventName = 'CloseEvent';
eventSrc = oStartSys.Handle;
elseif isa( oStartSys.Handle, 'Simulink.SubSystem' )
eventName = 'ModelCloseEvent';
eventSrc = oStartSys.Handle;
else 

eventSrc = oStartSys.Handle;
while ~isempty( eventSrc ) && ~isa( eventSrc, 'Simulink.BlockDiagram' )
eventSrc = up( eventSrc );
end 
eventName = 'CloseEvent';
end 

if ishandle( eventSrc )
closeListener = Simulink.listener( eventSrc,  ...
eventName,  ...
@( src, evt )slreportgen.webview.ui.Exporter.closeListenerFcn( src, evt,  ...
oStartSys.Handle ) );

set( oStartSys.Handle, listenerProp, closeListener );
end 
end 

else 

if isempty( APP_DIALOG ) || ~ishandle( APP_DIALOG )
if ~isempty( oStartSys )
exporter = slreportgen.webview.ui.Exporter.loadExporter( oStartSys );
else 
exporter = slreportgen.webview.ui.Exporter( [  ] );
end 
APP_DIALOG = DAStudio.Dialog( exporter );
else 
if ~isempty( oStartSys )
that = APP_DIALOG.getSource(  );
if slreportgen.utils.HierarchyService.isValid( that.StartModelObjHid )
that.saveExporter(  );
end 
that.refreshDialog( oStartHid, APP_DIALOG );
end 
end 
APP_DIALOG.show(  );
dialog = APP_DIALOG;
end 
end 

end 






methods ( Access = public )

function dlgSchema = getDialogSchema( this, dlgType )
















if isempty( this.RegisteredViews )
this.RegisteredViews = slreportgen.webview.views.getRegisteredViews(  );

n = numel( this.RegisteredViews );
keys = cell( size( this.RegisteredViews ) );
for i = 1:n
keys{ i } = this.RegisteredViews{ i }.Id;
end 

if ~isempty( keys )
map = containers.Map( keys, this.RegisteredViews );

n = size( this.m_optViews, 1 );
for i = 1:n
id = this.m_optViews{ i, 1 };
value = this.m_optViews{ i, 2 };
if map.isKey( id )
optView = map( id );
optView.WidgetEnableValue = value;
end 
end 
end 
end 

scopeSchema = getExportScopeSchema( this );
scopeSchema.ColSpan = [ 1, 1 ];
scopeSchema.RowSpan = [ 2, 2 ];

grpInclude = getIncludeOptionsSchema( this );
grpInclude.ColSpan = [ 1, 1 ];
grpInclude.RowSpan = [ 3, 3 ];

treeExclude = getSystemsToExcludeSchema( this, dlgType );
treeExclude.ColSpan = [ 2, 2 ];
treeExclude.RowSpan = [ 2, 4 ];

exportOptions = getExportOptionSchema( this );
exportOptions.ColSpan = [ 1, 2 ];
exportOptions.RowSpan = [ 5, 5 ];

pnlFileChooser = getFileChooserSchema( this );
pnlFileChooser.ColSpan = [ 1, 2 ];
pnlFileChooser.RowSpan = [ 6, 6 ];

grpPackageType = getPackageTypeSchema( this );
grpPackageType.ColSpan = [ 1, 2 ];
grpPackageType.RowSpan = [ 7, 7 ];



cEmbeddedExportButton = getEmbeddedExportButtonSchema( this, dlgType );
cEmbeddedExportButton.ColSpan = [ 1, 2 ];
cEmbeddedExportButton.RowSpan = [ 1, 1 ];

cMain.LayoutGrid = [ 7, 2 ];

cMain.Items = { 
cEmbeddedExportButton,  ...
scopeSchema,  ...
grpInclude,  ...
treeExclude,  ...
exportOptions,  ...
pnlFileChooser,  ...
grpPackageType };


viewGroups = {  };
viewTabs = {  };
badIdx = [  ];


if ~isempty( this.RegisteredViews ) && ~isempty( this.StartSysObj )
for i = 1:length( this.RegisteredViews )
exporter = this.RegisteredViews{ i };
try 
init( exporter, this.StartSysObj.Handle );
if isWidgetVisible( exporter )
schema = getDialogSchema( exporter );
if strcmp( schema.Type, 'group' )
viewGroups = [ viewGroups, { schema } ];%#ok<AGROW>
else 
if strcmp( schema.Type, 'tab' )
viewTabs = [ viewTabs, { schema } ];%#ok<AGROW>
end 
end 
end 
catch me
warndlg( strcat( exporter.Name, ': ', me.message ),  ...
getString( message( 'slreportgen_webview:exporter:ViewsTabLabel' ) ) );
badIdx = [ badIdx, i ];%#ok
end 
end 
end 
this.RegisteredViews( badIdx ) = [  ];

if isempty( viewGroups ) && isempty( viewTabs )
cTop.Type = 'panel';
cMain.Type = 'panel';
cTop.Items = { cMain };
else 
cTop.Type = 'tab';
cMain.Name = tr( this, 'MainTabLabel' );
cTop.Tabs = { cMain };
end 
cTop.Tag = 'main';


if ~isempty( viewTabs )
cTop.Tabs = [ cTop.Tabs, viewTabs( : ) ];
end 

if ~isempty( viewGroups )
cViews.Name = tr( this, 'ViewsTabLabel' );
cViews.LayoutGrid = [ length( viewGroups ) + 1, 1 ];
cViews.RowStretch = zeros( length( viewGroups ) + 1 );
cViews.RowStretch( length( viewGroups ) + 1 ) = 1;
cViews.Items = viewGroups;
spacer.Type = 'panel';
cViews.Items = [ cViews.Items, { spacer } ];
cViews.Tag = prefixTag( this, 'ViewsTab' );

cTop.Tabs = [ cTop.Tabs, { cViews } ];
end 

pnlButton = getButtonPanelSchema( this );

isStandAlone = strcmp( dlgType, 'standalone' );
this.m_dlgTitle = getDisplayLabel( this );
dlgSchema.DialogTitle = this.m_dlgTitle;
dlgSchema.DialogTag = prefixTag( this, 'dialog' );
dlgSchema.OpenCallback = @slreportgen.webview.ui.Exporter.dlgFindSystemCallback;
dlgSchema.CloseMethod = 'saveExporter';
if isStandAlone
dlgSchema.StandaloneButtonSet = pnlButton;
end 
dlgSchema.EmbeddedButtonSet = { 'Help' };
dlgSchema.HelpMethod = 'viewHelp';
dlgSchema.HelpArgs = { this };

dlgSchema.IsScrollable = false;
dlgSchema.Items = { cTop };
end 
end 







methods ( Access = private )
function msg = tr( ~, msgid, varargin )
msg = getString( message( strcat( 'slreportgen_webview:exporter:', msgid ), varargin{ : } ) );
end 
end 

methods ( Access = protected )
function disableDialog( this, dlgH )
dlgH.setTitle( tr( this, 'UpdatingSystemsToExcludeMsgText', this.m_dlgTitle ) );
dlgH.setEnabled( 'main', false );
dlgH.setEnabled( prefixTag( this, 'ExportButton' ), false );
dlgH.setEnabled( prefixTag( this, 'CancelButton' ), false );
dlgH.setEnabled( prefixTag( this, 'HelpButton' ), false );
dlgH.setEnabled( prefixTag( this, 'EmbeddedExportButton' ), false );
end 

function enableDialog( this, dlgH )

dlgH.setTitle( this.m_dlgTitle );
dlgH.setEnabled( 'main', true );
dlgH.setEnabled( prefixTag( this, 'CancelButton' ), true );
dlgH.setEnabled( prefixTag( this, 'ExportButton' ), true );
dlgH.setEnabled( prefixTag( this, 'HelpButton' ), true );
dlgH.setEnabled( prefixTag( this, 'EmbeddedExportButton' ), true );
end 

function prefix = getTagPrefix( ~ )
prefix = 'WebViewExporter_';
end 

function prefixedTag = prefixTag( this, tag )
prefixedTag = strcat( getTagPrefix( this ), tag );
end 

function schema = getEmbeddedExportButtonSchema( this, dlgType )




closeDialog = false;
wButton.Type = 'pushbutton';
wButton.Tag = prefixTag( this, 'EmbeddedExportButton' );
wButton.Name = tr( this, 'EmbeddedExportButtonLabel' );
wButton.ToolTip = tr( this, 'EmbeddedExportButtonToolTip' );
wButton.Enabled = ~isempty( this.HierModel );
wButton.ObjectMethod = 'cbkExport';
wButton.MethodArgs = { '%dialog', closeDialog };
wButton.ArgDataTypes = { 'handle', 'bool' };
wButton.ColSpan = [ 1, 1 ];
wButton.RowSpan = [ 1, 1 ];

wText.Type = 'text';
wText.Tag = prefixTag( this, 'EmbeddedExportButtonText' );
wText.Name = tr( this, 'EmbeddedExportButtonText' );
wText.ColSpan = [ 2, 2 ];
wText.RowSpan = [ 1, 1 ];

schema.Type = 'group';
schema.Name = tr( this, 'EmbeddedExportButtonGroupLabel' );
schema.Visible = ~strcmp( dlgType, 'standalone' );
schema.LayoutGrid = [ 1, 2 ];
schema.ColStretch = [ 0, 1 ];
schema.RowStretch = 0;
schema.Items = { wButton, wText };
end 

function grpScope = getExportScopeSchema( this )
rbScope.Type = 'radiobutton';
rbScope.Name = '';
rbScope.Tag = prefixTag( this, 'SystemsToExportRadioButtonGroup' );
rbScope.ToolTip = tr( this, 'SystemsToExportRadioButtonGroupToolTip' );
rbScope.RowSpan = [ 1, 1 ];
rbScope.ColSpan = [ 2, 2 ];

rbScope.Entries = { 
tr( this, 'EntireModelExportButtonLabel' )
tr( this, 'CurrAndBelowExportButtonLabel' )
tr( this, 'CurrAndAboveExportButtonLabel' )
tr( this, 'CurrentExportButtonLabel' )
 };

switch this.Scope
case 'all'
rbScope.Value = 0;
case 'CurrentAndBelow'
rbScope.Value = 1;
case 'CurrentAndAbove'
rbScope.Value = 2;
case 'Current'
rbScope.Value = 3;
end 

rbScope.DialogRefresh = true;
rbScope.ObjectMethod = 'cbkExportSystems';
rbScope.MethodArgs = { '%dialog', '%value' };
rbScope.ArgDataTypes = { 'handle', 'mxArray' };
rbScope.Mode = true;
rbScope.Graphical = true;

if strcmp( this.Scope, 'all' )
scope = 'All';
else 
scope = this.Scope;
end 

imgScope.Type = 'image';
imgScope.Tag = prefixTag( this, 'SystemsToExportIcon' );
imgScope.FilePath =  ...
fullfile( matlabroot,  ...
'toolbox/slreportgen/webview/resources/icons',  ...
strcat( 'Scope', scope, '.png' ) );
imgScope.RowSpan = [ 1, 1 ];
imgScope.ColSpan = [ 1, 1 ];

grpScope.Type = 'group';
grpScope.Name = tr( this, 'SystemsToExportGroupLabel' );
grpScope.Tag = prefixTag( this, 'SystemsToExportGroupLabel' );
grpScope.LayoutGrid = [ 1, 2 ];
grpScope.Items = { rbScope, imgScope };
end 

function hm = getHierModel( this )
if isempty( this.HierModel ) || ~isa( this.HierModel, 'slreportgen.webview.ModelHierarchy' )
hs = slreportgen.utils.HierarchyService;

filter = slreportgen.webview.ModelHierarchyFilter(  );
filter.IncludeMaskSubSystems = this.IncludeMaskedSubsystems;
filter.IncludeMathworksLinks = this.IncludeMWLibraryLinks;
filter.IncludeUserLinks = this.IncludeLibraryLinks;
filter.IncludeReferenceModel = this.IncludeReferencedModels;

switch lower( this.Scope )
case 'current'
if hs.isValid( this.StartModelObjHid )
hm = slreportgen.webview.ModelHierarchy( this.StartModelObjHid );
else 

pHid = hs.getParentDiagramHID( this.StartModelObjHid );
hm = slreportgen.webview.ModelHierarchy( pHid );
end 

case 'currentandabove'
hm = slreportgen.webview.ModelHierarchy(  );
if hs.isValid( this.StartModelObjHid )
hm.addItemsAndTheirAncestors( this.StartModelObjHid );
else 

pHid = hs.getParentDiagramHID( this.StartModelObjHid );
hm.addItemsAndTheirAncestors( pHid );
end 

hm = slreportgen.webview.ModelHierarchy(  );
hm.addItemsAndTheirAncestors( this.StartModelObjHid );

case 'currentandbelow'
hm = slreportgen.webview.ModelHierarchy(  );
if hs.isValid( this.StartModelObjHid )
hm.addItemsAndTheirDescendants( this.StartModelObjHid, filter );
else 

pHid = hs.getParentDiagramHID( this.StartModelObjHid );
hm.addItems( pHid );
end 

otherwise 
model = slreportgen.utils.getModelHandle( this.StartModelObjHid );
hm = slreportgen.webview.ModelHierarchy(  );
hm.addItemsAndTheirDescendants( model, filter );
end 

this.HierModel = hm;
end 

hm = this.HierModel;
end 

function updateHierModel( this )
for i = 1:length( this.ExcludedSystems )
hierModel = this.getHierModel(  );
item = hierModel.getItem( this.ExcludedSystems{ i } );
item.uncheck(  );
end 
end 

function model = getCreateExportModel( this )
if isempty( this.HierModel ) || ~isa( this.HierModel, 'slreportgen.webview.internal.Model' )
this.createExportModel(  );
end 
model = this.HierModel;
end 

function model = createExportModel( this, options )
R36
this
options.LoadLibraries logical = ( this.IncludeMWLibraryLinks || this.IncludeLibraryLinks )
end 

modelH = slreportgen.utils.getModelHandle( this.StartModelObjHid );
modelName = get_param( modelH, 'Name' );
if isempty( this.ModelBuilder )
this.ModelBuilder = slreportgen.webview.internal.ModelBuilder(  );
end 
model = this.ModelBuilder.build( modelName,  ...
LoadLibraries = options.LoadLibraries,  ...
Cache = this.IncrementalExport );
model.loadReferencedSubsystems(  );
this.HierModel = model;
end 

function out = getCurrentExportDiagram( this )
model = this.getCreateExportModel(  );
if isempty( this.CachedCurrentExportDiagram ) || ( this.CachedCurrentExportDiagram.Model ~= model )
this.CachedCurrentExportDiagram = model.queryDiagrams( hid = this.StartModelObjHid, Count = 1 );
end 
out = this.CachedCurrentExportDiagram;
end 

function updateExportModel( this )
hs = slreportgen.utils.HierarchyService;
if ~hs.isValid( this.StartModelObjHid )
return 
end 

model = this.getCreateExportModel(  );
if ( ~model.isBuiltWithLibrariesLoaded && ( this.IncludeMWLibraryLinks || this.IncludeLibraryLinks ) )
model = this.createExportModel(  );
end 

selector = slreportgen.webview.internal.DiagramSelector(  );
selector.IncludeMaskedSubsystems = this.IncludeMaskedSubsystems;
selector.IncludeSimulinkLibraryLinks = this.IncludeMWLibraryLinks;
selector.IncludeUserLibraryLinks = this.IncludeLibraryLinks;
selector.IncludeReferencedModels = this.IncludeReferencedModels;
selector.unselectAll( model );

if strcmpi( this.Scope, 'all' )
selector.Scope = 'CurrentAndBelow';
selector.select( model.RootDiagram );
else 
selector.Scope = this.Scope;
diagram = this.getCurrentExportDiagram(  );
selector.select( diagram );
end 

for i = 1:numel( this.ExcludedSystems )
diagram = model.queryDiagrams( path = this.ExcludedSystems{ i }, Count = 1 );
diagram.Selected = false;
end 
end 

function rootNodes = updateExcludeTree( this, dialog )
import slreportgen.webview.*;
import slreportgen.webview.getters.*;
import slreportgen.webview.ui.*;

this.disableDialog( dialog );

if isempty( this.StartModelObjHid )
rootNodes = {  };
else 
if ( slreportgen.webview.internal.version == 3 )
model = this.getCreateExportModel(  );
this.updateExportModel(  );
rootNodes = { slreportgen.webview.ui.ExportTree( model.RootDiagram ) };
else 
hm = this.getHierModel(  );
rootItems = hm.getRootItems(  );
nRoots = numel( rootItems );
rootNodes = cell( nRoots );
for i = 1:nRoots
rootNodes{ i } = slreportgen.webview.ui.ExportTree( rootItems( i ) );
end 
end 
end 
this.ExcludeTree = rootNodes;
this.enableDialog( dialog );
end 

function schema = getSystemsToExcludeSchema( this, dlgType )
wSys.Type = 'tree';
wSys.Tag = prefixTag( this, 'ExcludeTree' );
wSys.ToolTip = tr( this, 'ExcludeTreeToolTip' );
wSys.TreeMultiSelect = true;
wSys.ExpandTree = true;
wSys.ObjectMethod = 'cbkExcludeTreeNodeSelected';
wSys.MethodArgs = { '%dialog', prefixTag( this, 'ExcludeTree' ) };
wSys.ArgDataTypes = { 'handle', 'string' };
wSys.RowSpan = [ 2, 2 ];
wSys.ColSpan = [ 1, 2 ];
wSys.Name = tr( this, 'ExcludeTreeLabel' );
wSys.Mode = true;

if isempty( this.ExcludeTree )
wSys.Value = {  };
wSys.TreeModel = { slreportgen.webview.ui.ExportTree(  ) };
else 
wSys.Value = this.ExcludedSystems;
wSys.TreeModel = this.ExcludeTree;
end 

wRefreshButton.Type = 'pushbutton';
wRefreshButton.Name = tr( this, 'RefreshLabel' );
wRefreshButton.Visible = ~strcmp( dlgType, 'standalone' );
wRefreshButton.ObjectMethod = 'cbkRefreshDialog';
wRefreshButton.MethodArgs = { '%dialog' };
wRefreshButton.ArgDataTypes = { 'handle' };
wRefreshButton.RowSpan = [ 3, 3 ];
wRefreshButton.ColSpan = [ 2, 2 ];

wButtonSpacer.Type = 'panel';
wButtonSpacer.RowSpan = [ 3, 3 ];
wButtonSpacer.ColSpan = [ 1, 1 ];

schema.Type = 'panel';
schema.Tag = prefixTag( this, 'SystemsToExcludePanel' );
schema.LayoutGrid = [ 3, 2 ];
schema.ColStretch = [ 1, 0 ];
schema.Items = { wSys, wButtonSpacer, wRefreshButton };
end 

function grpInclude = getIncludeOptionsSchema( this )

chkRefModels.Type = 'checkbox';
chkRefModels.Name = tr( this, 'ReferencedModelsCheckBoxLabel' );
chkRefModels.Tag = prefixTag( this, 'ReferencedModelsCheckBox' );
chkRefModels.ObjectProperty = 'IncludeReferencedModels';
chkRefModels.ToolTip = tr( this, 'ReferencedModelsCheckBoxToolTip' );
chkRefModels.DialogRefresh = true;
chkRefModels.ObjectMethod = 'cbkIncludeReferencedModels';
chkRefModels.MethodArgs = { '%dialog', '%value' };
chkRefModels.ArgDataTypes = { 'handle', 'mxArray' };
chkRefModels.Mode = true;
chkRefModels.Graphical = true;

chkLibLinks.Type = 'checkbox';
chkLibLinks.Name = tr( this, 'LibraryLinksCheckBoxLabel' );
chkLibLinks.Tag = prefixTag( this, 'LibraryLinksCheckBox' );
chkLibLinks.ObjectProperty = 'IncludeLibraryLinks';
chkLibLinks.ToolTip = tr( this, 'LibraryLinksCheckBoxToolTip' );
chkLibLinks.DialogRefresh = true;
chkLibLinks.ObjectMethod = 'cbkIncludeLibraryLinks';
chkLibLinks.MethodArgs = { '%dialog', '%value' };
chkLibLinks.ArgDataTypes = { 'handle', 'mxArray' };
chkLibLinks.Mode = true;
chkLibLinks.Graphical = true;

chkMWLibLinks.Type = 'checkbox';
chkMWLibLinks.Name = tr( this, 'MWLibraryLinksCheckBoxLabel' );
chkMWLibLinks.Tag = prefixTag( this, 'MWLibraryLinksCheckBox' );
chkMWLibLinks.ObjectProperty = 'IncludeMWLibraryLinks';
chkMWLibLinks.ToolTip = tr( this, 'MWLibraryLinksCheckBoxToolTip' );
chkMWLibLinks.DialogRefresh = true;
chkMWLibLinks.ObjectMethod = 'cbkIncludeMWLibraryLinks';
chkMWLibLinks.MethodArgs = { '%dialog', '%value' };
chkMWLibLinks.ArgDataTypes = { 'handle', 'mxArray' };
chkMWLibLinks.Mode = true;
chkMWLibLinks.Graphical = true;

chkMaskedSystems.Type = 'checkbox';
chkMaskedSystems.Name = tr( this, 'MaskedSubsystemsCheckBoxLabel' );
chkMaskedSystems.Tag = prefixTag( this, 'MaskedSubsystemsCheckBox' );
chkMaskedSystems.ObjectProperty = 'IncludeMaskedSubsystems';
chkMaskedSystems.ToolTip = tr( this, 'MaskedSubsystemsCheckBoxToolTip' );
chkMaskedSystems.DialogRefresh = true;
chkMaskedSystems.ObjectMethod = 'cbkIncludeMaskedSubsystems';
chkMaskedSystems.MethodArgs = { '%dialog', '%value' };
chkMaskedSystems.ArgDataTypes = { 'handle', 'mxArray' };
chkMaskedSystems.Mode = true;
chkMaskedSystems.Graphical = true;

hasNotes = slreportgen.webview.NotesExporter.hasNotes( this.StartModelObjHid );

chkNotes.Type = 'checkbox';
chkNotes.Name = tr( this, 'NotesCheckBoxLabel' );
chkNotes.Tag = prefixTag( this, 'NotesCheckBox' );
chkNotes.ObjectProperty = 'IncludeNotes';
chkNotes.Enabled = hasNotes;
if hasNotes
chkNotes.ToolTip = tr( this, 'NotesCheckBoxToolTip' );
else 
chkNotes.ToolTip = tr( this, 'NotesCheckBoxToolTipNoneFound' );
end 
chkNotes.DialogRefresh = false;
chkNotes.ObjectMethod = 'cbkIncludeNotes';
chkNotes.MethodArgs = { '%value' };
chkNotes.ArgDataTypes = { 'mxArray' };
chkNotes.Mode = true;
chkNotes.Graphical = true;

grpInclude.Type = 'group';
grpInclude.Name = tr( this, 'IncludeOptionsGroupLabel' );
grpInclude.Tag = prefixTag( this, 'IncludeOptionsGroup' );
grpInclude.ToolTip = tr( this, 'IncludeOptionsGroupToolTip' );
grpInclude.Enabled = true;
grpInclude.Items = { 
chkRefModels,  ...
chkLibLinks,  ...
chkMWLibLinks,  ...
chkMaskedSystems,  ...
chkNotes
 };
end 

function schema = getButtonPanelSchema( this )





closeDialog = true;
btnExport.Type = 'pushbutton';
btnExport.Name = tr( this, 'ExportButtonLabel' );
btnExport.Tag = prefixTag( this, 'ExportButton' );
btnExport.ToolTip = tr( this, 'ExportButtonToolTip' );
btnExport.ColSpan = [ 1, 1 ];
btnExport.ObjectMethod = 'cbkExport';
btnExport.MethodArgs = { '%dialog', closeDialog };
btnExport.ArgDataTypes = { 'handle', 'bool' };


btnCancel.Type = 'pushbutton';
btnCancel.Name = tr( this, 'CancelButtonLabel' );
btnCancel.Tag = prefixTag( this, 'CancelButton' );
btnCancel.ToolTip = tr( this, 'CancelButtonToolTip' );
btnCancel.ColSpan = [ 2, 2 ];
btnCancel.ObjectMethod = 'cbkCancelExport';


btnHelp.Type = 'pushbutton';
btnHelp.Name = tr( this, 'HelpButtonLabel' );
btnHelp.Tag = prefixTag( this, 'HelpButton' );
btnHelp.ToolTip = tr( this, 'HelpButtonToolTip' );
btnHelp.ColSpan = [ 3, 3 ];
btnHelp.ObjectMethod = 'cbkHelp';


pnlButton.Type = 'panel';


pnlSpacer.Type = 'panel';

pnlButton.LayoutGrid = [ 1, 4 ];
pnlButton.ColStretch = [ 1, 0, 0, 0 ];

pnlButton.Items = { pnlSpacer, btnExport, btnCancel, btnHelp };

pnlButton.Tag = prefixTag( this, 'ButtonPanel' );

schema = pnlButton;
end 

function schema = getFileChooserSchema( this )




editPackageName.Type = 'edit';
editPackageName.Name = tr( this, 'ExportPackageNameEditFieldLabel' );
editPackageName.Tag = prefixTag( this, 'ExportPathEditField' );
editPackageName.ToolTip = tr( this, 'ExportPackageNameEditFieldToolTip' );
editPackageName.ObjectProperty = 'ExportPackageName';
editPackageName.ColSpan = [ 1, 2 ];
editPackageName.RowSpan = [ 1, 1 ];
editPackageName.Mode = true;
editPackageName.Graphical = true;

editFolder.Type = 'edit';
editFolder.Name = tr( this, 'ExportFolderEditFieldLabel' );
editFolder.Tag = prefixTag( this, 'ExportFolderEditField' );
editFolder.ToolTip = tr( this, 'ExportFolderEditFieldToolTip' );
editFolder.ObjectProperty = 'ExportFolder';
editFolder.ColSpan = [ 1, 1 ];
editFolder.RowSpan = [ 2, 2 ];
editFolder.Mode = true;
editFolder.Graphical = true;

btnFolderBrowser.Type = 'pushbutton';
btnFolderBrowser.Name = tr( this, 'FolderBrowserButtonLabel' );
btnFolderBrowser.Tag = prefixTag( this, 'FileBrowserButton' );
btnFolderBrowser.ToolTip = tr( this, 'FolderBrowserButtonToolTip' );
btnFolderBrowser.ColSpan = [ 2, 2 ];
btnFolderBrowser.RowSpan = [ 2, 2 ];
btnFolderBrowser.ObjectMethod = 'cbkSelectExportFolder';
btnFolderBrowser.MethodArgs = { '%dialog', editFolder.Tag };
btnFolderBrowser.ArgDataTypes = { 'handle', 'string' };

chkIncrementPackageName.Type = 'checkbox';
chkIncrementPackageName.Name = tr( this, 'IncrementPackageNameCheckBoxLabel' );
chkIncrementPackageName.Tag = prefixTag( this, 'IncrementPackageNameCheckBox' );
chkIncrementPackageName.ToolTip = tr( this, 'IncrementPackageNameCheckBoxToolTip' );
chkIncrementPackageName.ObjectProperty = 'IncrPackageName';
chkIncrementPackageName.ColSpan = [ 1, 2 ];
chkIncrementPackageName.RowSpan = [ 3, 3 ];
chkIncrementPackageName.Mode = true;
chkIncrementPackageName.Graphical = true;

schema.Type = 'group';
schema.Name = tr( this, 'ExportPathGroupLabel' );
schema.Tag = prefixTag( this, 'ExportPathGroup' );
schema.LayoutGrid = [ 3, 2 ];
schema.Items = { 
editPackageName,  ...
editFolder,  ...
btnFolderBrowser,  ...
chkIncrementPackageName
 };
end 

function schema = getExportOptionSchema( this )
chkIncrementExportName.Type = 'checkbox';
chkIncrementExportName.Name = tr( this, 'IncrementalExportLabel' );
chkIncrementExportName.Tag = prefixTag( this, 'IncrementalExport' );
chkIncrementExportName.ToolTip = tr( this, 'IncrementalExportToolTip' );
chkIncrementExportName.ObjectProperty = 'IncrementalExport';



enabled = true;
for i = 1:numel( this.RegisteredViews )
if this.RegisteredViews{ i }.WidgetEnableValue
enabled = false;
break ;
end 
end 
chkIncrementExportName.Enabled = enabled;

chkIncrementExportName.ColSpan = [ 1, 2 ];
chkIncrementExportName.RowSpan = [ 1, 1 ];
chkIncrementExportName.Mode = true;
chkIncrementExportName.Graphical = true;

schema.Type = 'group';
schema.Name = tr( this, 'ExportOptionsTitle' );
schema.Tag = prefixTag( this, 'ExportOptionGroup' );
schema.LayoutGrid = [ 1, 2 ];
schema.Items = { 
chkIncrementExportName
 };
end 

function schema = getPackageTypeSchema( this )
schema.Type = 'radiobutton';
schema.Name = tr( this, 'PackagingTypeGroupLabel' );
schema.Tag = prefixTag( this, 'PackagingTypeGroup' );
schema.ToolTip = tr( this, 'PackagingTypeGroupToolTip' );
schema.OrientHorizontal = true;
schema.Mode = true;
schema.Graphical = true;

schema.Entries = { 
tr( this, 'PackagingTypeZippedLabel' )
tr( this, 'PackagingTypeUnzippedLabel' )
tr( this, 'PackagingTypeBothLabel' )
 };

switch this.PackagingType
case 'zipped'
schema.Value = 0;
case 'unzipped'
schema.Value = 1;
case 'both'
schema.Value = 2;
end 

schema.ObjectMethod = 'cbkPackageType';
schema.MethodArgs = { '%value' };
schema.ArgDataTypes = { 'mxArray' };
end 
end 






methods ( Access = public )
function cbkExport( this, dialog, closeDialog )



apply( dialog );

if closeDialog
delete( dialog );
end 

this.DisplayWebView = true;
this.ShowProgressBar = true;



t = timer(  ...
'ExecutionMode', 'singleShot',  ...
'StartDelay', 0.1,  ...
'TimerFcn', @( t, evt )export( this ),  ...
'StopFcn', @( t, evt )delete( t ) );
start( t );
end 

function cbkCancelExport( this )




[ ~, dialogProp, ~ ] =  ...
slreportgen.webview.ui.Exporter.getExporterRegistryProps(  );


dlgHandle = get( this.StartSysObj.Handle, dialogProp );
if ~isempty( dlgHandle ) && ishandle( dlgHandle )
delete( dlgHandle );
end 

end 

function viewHelp( ~ )




mapFile = RptgenML.getHelpMapfile(  ...
fullfile( docroot, 'toolbox', 'rptgenext', 'ug', 'sl_rptgen_ug.map' ) );

helpview( mapFile, 'obj.RptgenSL.WebViewExporter' );
end 

function cbkHelp( ~ )


helpview( 'mapkey:Exporter.WebViewExporter_dialog', 'help_button', 'CSHelpWindow' );
end 

function cbkExcludeTreeNodeSelected( this, dialog, treeTag )




value = getWidgetValue( dialog, treeTag );
if isempty( value )
this.ExcludedSystems = {  };
else 
this.ExcludedSystems = reshape( value, 1, [  ] );
end 
end 

function cbkIncludeReferencedModels( this, dialog, value )
this.IncludeReferencedModels = value;
this.ExcludedSystems = {  };
if ( slreportgen.webview.internal.version(  ) == 2 )
this.HierModel = [  ];
end 
this.updateExcludeTree( dialog );
end 

function cbkIncludeLibraryLinks( this, dialog, value )
this.IncludeLibraryLinks = value;
this.ExcludedSystems = {  };
if ( slreportgen.webview.internal.version(  ) == 2 )
this.HierModel = [  ];
end 
this.updateExcludeTree( dialog );
end 

function cbkIncludeMWLibraryLinks( this, dialog, value )
this.IncludeMWLibraryLinks = value;
this.ExcludedSystems = {  };
if ( slreportgen.webview.internal.version(  ) == 2 )
this.HierModel = [  ];
end 
this.updateExcludeTree( dialog );
end 

function cbkIncludeMaskedSubsystems( this, dialog, value )
this.IncludeMaskedSubsystems = value;
this.ExcludedSystems = {  };
if ( slreportgen.webview.internal.version(  ) == 2 )
this.HierModel = [  ];
end 
this.updateExcludeTree( dialog );
end 

function cbkIncludeNotes( this, value )
this.IncludeNotes = value;
end 

function cbkExportSystems( this, dialog, value )







switch value
case 0
this.Scope = 'all';
case 1
this.Scope = 'CurrentAndBelow';
case 2
this.Scope = 'CurrentAndAbove';
case 3
this.Scope = 'Current';
otherwise 
this.Scope = 'all';
end 

this.ExcludedSystems = {  };
if ( slreportgen.webview.internal.version(  ) == 2 )
this.HierModel = [  ];
end 
this.updateExcludeTree( dialog );
end 

function cbkPackageType( this, value )
switch value
case 0
this.PackagingType = 'zipped';
case 1
this.PackagingType = 'unzipped';
case 2
this.PackagingType = 'both';
otherwise 
this.PackagingType = 'zipped';
end 
end 

function cbkSelectExportFolder( this, dlg, folderEditField )
pathName = uigetdir(  ...
getResolvedExportFolder( this ),  ...
tr( this, 'ExportFolderBrowserTitle' ) );

if pathName ~= 0
setWidgetValue( dlg, folderEditField, pathName );
end 
end 

function cbkRefreshDialog( this, dialog )

currentHid = slreportgen.utils.getCurrentHID(  );

if slreportgen.utils.HierarchyService.isValid( this.StartModelObjHid )
this.saveExporter(  );
end 

if isempty( currentHid )
this.StartSysName = '';
this.StartSysObj = [  ];
this.ExportFolder = pwd;
this.ExportPackageName = '';
else 
if isempty( this.StartModelObjHid ) ...
 || ~( this.StartModelObjHid == currentHid ) ...
 || ~strcmp( this.StartSysName, this.StartSysObj.Handle.getFullName(  ) )

this.refreshDialog( currentHid, dialog )
end 
end 


this.HierModel = [  ];
this.updateExcludeTree( dialog );

ed = DAStudio.EventDispatcher;
ed.broadcastEvent( 'HierarchyChangedEvent', dialog.getSource );
refresh( dialog );
end 

function dLabel = getDisplayLabel( this )


if isempty( this.StartSysObj ) || ~ishandle( this.StartSysObj.Handle )
printScope = getString( message( 'slreportgen_webview:exporter:currentSystemLabel' ) );

elseif isa( this.StartSysObj.Handle, 'DAStudio.Object' ) || isa( this.StartSysObj.Handle, 'Simulink.DABaseObject' )
printScope = getDisplayLabel( this.StartSysObj.Handle );
printScope = strrep( printScope, newline, ' ' );
else 
printScope = getString( message( 'slreportgen_webview:exporter:unknownLabel' ) );
end 

title = getString( message( 'slreportgen_webview:exporter:webViewLabel' ) );

dLabel = sprintf( '%s - %s', title, printScope );

end 

end 






methods ( Access = public )

function saveExporter( this )






try 
if isempty( this.StartModelObjHid ) ...
 || ~strcmp( this.StartSysName, this.StartSysObj.Handle.getFullName(  ) )
return 
end 
this.StartSysId = slreportgen.utils.HierarchyService.getStringID( this.StartModelObjHid );

savePath = slreportgen.webview.ui.Exporter.getExportersPath(  );
if exist( savePath, 'file' )
load( savePath, 'exporters' );
i = cellfun( @( a )strcmp( a{ 1 }, this.StartSysName ), exporters );
if isempty( exporters( i ) )
exporters = [ exporters, { { this.StartSysName, this } } ];
else 
exporters{ i }{ 2 } = this;
end 
save( savePath, 'exporters' );

else 
exporters = { { this.StartSysName, this } };
save( savePath, 'exporters' );
end 


slreportgen.webview.internal.CacheManager.instance(  ).close(  );
catch 


end 

end 

end 

methods ( Access = protected )

function so = saveobj( this )



so.StartSysName = this.StartSysName;
so.StartSysId = this.StartSysId;
so.Scope = this.Scope;
so.ExcludedSystems = this.ExcludedSystems;
so.IncludeReferencedModels = this.IncludeReferencedModels;
so.IncludeLibraryLinks = this.IncludeLibraryLinks;
so.IncludeMWLibraryLinks = this.IncludeMWLibraryLinks;
so.IncludeMaskedSubsystems = this.IncludeMaskedSubsystems;
so.IncludeNotes = this.IncludeNotes;
so.ExportFolder = this.ExportFolder;
so.ExportPackageName = this.ExportPackageName;
so.IncrPackageName = this.IncrPackageName;
so.DisplayWebView = this.DisplayWebView;
so.ShowProgressBar = this.ShowProgressBar;
so.PackagingType = this.PackagingType;
so.IncrementalExport = this.IncrementalExport;

n = numel( this.RegisteredViews );
optViews = cell( n, 2 );
for i = 1:n
optViews{ i, 1 } = this.RegisteredViews{ i }.Id;
optViews{ i, 2 } = this.RegisteredViews{ i }.WidgetEnableValue;
end 
so.m_optViews = optViews;
end 
end 

methods ( Static, Access = public )
function exporter = loadExporter( oStartSys )







import slreportgen.webview.ui.*;

if isempty( oStartSys )
currentHid = slreportgen.utils.getCurrentHID(  );

if isempty( currentHid )
exporter = Exporter( [  ] );
return ;
else 
oStartSys = slreportgen.webview.SlProxyObject( currentHid );
end 
end 
sysName = oStartSys.Handle.getFullName;

savePath = Exporter.getExportersPath(  );
exporters = [  ];%#ok used during save operation

if exist( savePath, 'file' )
load( savePath, 'exporters' );
i = cellfun( @( a )strcmp( a{ 1 }, sysName ), exporters );
if isempty( exporters( i ) )
exporter = Exporter( oStartSys.Handle );
exporters = [ exporters, { { sysName, exporter } } ];
save( savePath, 'exporters' );
else 
exporter = exporters{ i }{ 2 };

if ( ~exporter.isvalid || isempty( exporter.StartSysId ) )
exporter = Exporter( oStartSys.Handle );
else 
exporter.StartModelObjHid = slreportgen.utils.HierarchyService.getHIDFromStringID( exporter.StartSysId );
end 
end 
else 
exporter = Exporter( oStartSys.Handle );
exporters = { { sysName, exporter } };
save( savePath, 'exporters' );
end 
end 
end 

methods ( Static, Access = protected )
function path = getExportersPath(  )





path = fullfile( prefdir, 'WebViewExporters.mat' );
end 

function lo = loadobj( so )
import slreportgen.webview.ui.*;
lo = Exporter;
lo.StartSysName = so.StartSysName;
lo.StartSysId = so.StartSysId;
lo.Scope = so.Scope;
lo.ExcludedSystems = so.ExcludedSystems;
lo.IncludeReferencedModels = so.IncludeReferencedModels;
lo.IncludeLibraryLinks = so.IncludeLibraryLinks;
lo.IncludeMWLibraryLinks = so.IncludeMWLibraryLinks;
lo.IncludeMaskedSubsystems = so.IncludeMaskedSubsystems;
lo.ExportFolder = so.ExportFolder;
lo.ExportPackageName = so.ExportPackageName;
lo.IncrPackageName = so.IncrPackageName;
lo.DisplayWebView = so.DisplayWebView;
lo.ShowProgressBar = so.ShowProgressBar;
lo.PackagingType = so.PackagingType;

if isfield( so, 'IncrementalExport' )
lo.IncrementalExport = so.IncrementalExport;
else 
lo.IncrementalExport = false;
end 

if ~isfolder( lo.ExportFolder )
lo.ExportFolder = pwd(  );
end 

if isfield( so, 'IncludeNotes' )
lo.IncludeNotes = so.IncludeNotes;
else 
lo.IncludeNotes = false;
end 

if isfield( so, 'm_optViews' )
lo.m_optViews = so.m_optViews;
else 
lo.m_optViews = {  };
end 
end 
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmplTKuFF.p.
% Please follow local copyright laws when handling this file.

