


classdef ( Sealed )ReportViewer < dynamicprops


properties ( Constant, Access = private )
SERVICES_PACKAGE = 'codergui.internal.reportws'
REPORT_ID_PREFIX = 'rv'
REPORT_CHANNEL_GROUP = 'report'
REPORT_VIEWER_PROPERTY = 'reportviewer'
REPORT_CHANGE_SEND_CHANNEL = 'reportChanged/send'
REPORT_CHANGE_RECEIVE_CHANNEL = 'reportChanged/receive'
INBOUND_FILE_IO_CHANNEL = 'fileio/request'
OUTBOUND_FILE_IO_CHANNEL = 'fileio/reply'
INBOUND_FILE_ICON_CHANNEL = 'fileicon/request'
OUTBOUND_FILE_ICON_CHANNEL = 'fileicon/reply'
end 

properties ( Hidden, SetAccess = immutable )
Client
ReportType
BlockSid
end 

properties ( Dependent, SetAccess = private )
Disposed
RemoteApi
end 

properties ( Access = private )
FileService
IconService
SuppressChange
RevalidateResources
end 

properties ( SetObservable )
QueryParams
ReportFile = ''
CustomTitle
end 

properties ( SetAccess = private )
Manifest
FileSystem
VirtualReport
end 

methods 
function this = ReportViewer( varargin )










ip = inputParser(  );
ip.KeepUnmatched = true;
ip.PartialMatching = false;
ip.addParameter( 'ReportFile', '', @( r )ischar( r ) || isa( r, 'codergui.internal.VirtualReport' ) || isstruct( r ) );
ip.addParameter( 'ReportType', [  ], @( s )isempty( s ) || isa( s, 'codergui.ReportType' ) );
ip.addParameter( 'ClientFactory', [  ], @( v )isa( v, 'function_handle' ) );
ip.addParameter( 'ClientRoot', '', @( s )validateattributes( s, { 'char' }, { 'scalartext' } ) );
ip.addParameter( 'Debug', coder.internal.gui.globalconfig( 'WebDebugMode' ), @islogical );
ip.addParameter( 'BlockSid', '', @ischar );
ip.parse( varargin{ : } );
opts = ip.Results;

this.BlockSid = opts.BlockSid;
if ~isempty( opts.ClientRoot )
clientRoot = opts.ClientRoot;
elseif ~isempty( opts.ReportType )
clientRoot = opts.ReportType.getRootPage( opts.Debug );
elseif isempty( opts.ReportType )
clientRoot = fileparts( codergui.ReportType.DEFAULT_PAGE );
end 
if ~isempty( opts.ClientFactory )
factory = opts.ClientFactory;
else 
factory = @( varargin )codergui.ReportServices.WebClientFactory.run( varargin{ : } );
end 
this.Client = factory( clientRoot, varargin{ : },  ...
'SubChannelGroup', this.REPORT_CHANNEL_GROUP, 'IdPrefix', this.REPORT_ID_PREFIX,  ...
'RemoteApiDocSources', { fullfile( matlabroot, 'toolbox/coder/coder/web/reportviewer/remoteApiDocs.json' ) } );

this.Client.setProperty( this.REPORT_VIEWER_PROPERTY, this );
this.SuppressChange = false;
this.ReportType = opts.ReportType;

this.initServices(  );
this.addSubscribers(  );

this.ReportFile = opts.ReportFile;
end 

function set.ReportFile( this, reportFile )
if isstruct( reportFile )


fileSystem = reportFile.fileSystem;
manifest = reportFile.manifest;
reportFile = reportFile.file;
else 
manifest = [  ];
fileSystem = [  ];
end 
if isequal( this.ReportFile, reportFile )
return ;
end 
if ~isempty( this.FileSystem )%#ok<*MCSUP>
this.FileSystem.delete(  );
this.FileSystem = [  ];
this.Client.uninstallWebService( this.FileService );
this.FileService = [  ];
end 
virtualReport = [  ];
if ~isempty( reportFile )
if isempty( fileSystem )
fileSystem = codergui.internal.fs.ReportFileSystem.fromReportFile( reportFile );
end 
this.FileSystem = fileSystem;
if isempty( manifest )
manifest = this.loadManifest( fileSystem );
end 
this.FileService = this.FileSystem.createFileIoService(  ...
manifest.DefaultEncoding,  ...
this.Client.channel( this.INBOUND_FILE_IO_CHANNEL ),  ...
this.Client.channel( this.OUTBOUND_FILE_IO_CHANNEL ) );
this.Client.installWebService( this.FileService );
if isa( reportFile, 'codergui.internal.VirtualReport' )
virtualReport = reportFile;
end 
reportFile = this.FileSystem.ReportFile;
end 
this.ReportFile = reportFile;
this.VirtualReport = virtualReport;
this.Manifest = manifest;
this.updateClient(  );
end 

function set.QueryParams( this, QueryParams )
this.QueryParams = QueryParams;
this.updateClient(  );
end 

function set.CustomTitle( this, customTitle )
this.CustomTitle = customTitle;
this.updateWindowTitle(  );
end 

function disposed = get.Disposed( this )
disposed = this.Client.Disposed;
end 

function remoteApi = get.RemoteApi( this )
remoteApi = this.Client.RemoteApi;
end 

function reportType = get.ReportType( this )
if isempty( this.ReportType ) || isempty( this.ReportFile )
reportType = codergui.ReportServices.getReportType( '' );
else 
reportType = this.ReportType;
end 
end 

function show( this )
if this.RevalidateResources
this.RevalidateResources = false;
codergui.dev.regenerateResourceBundles(  );
end 
this.updateWindowTitle(  );
this.Client.show(  );
end 

function hide( this )
this.Client.hide(  );
end 

function minimize( this )
this.Client.minimize(  );
end 

function dispose( this )
this.Client.dispose(  );
end 

function delete( this )
try 
this.dispose(  );
catch 
end 
end 
end 

methods ( Access = private )
function updateClient( this )
if this.Client.Disposed
return ;
end 



queryParams = this.QueryParams;
if ~isempty( this.ReportFile )
queryParams.report = this.ReportFile;
elseif ~isempty( this.VirtualReport )
queryParams.report = this.VirtualReport.Id;
elseif isfield( queryParams, 'report' )
queryParams = rmfield( queryParams, 'report' );
end 
queryParams.licTest = num2str( encode( coderapp.internal.Products.select(  ) ) );
if ~isempty( this.BlockSid )
queryParams.blockSid = this.BlockSid;
end 
if coder.internal.gui.Features.MlfbTraceability.Enabled
queryParams.showMlfbTrace = true;
end 
this.Client.ClientParams = queryParams;

if this.Client.Initialized


if ~this.SuppressChange && isfield( queryParams, 'report' )
this.Client.publish( this.REPORT_CHANGE_SEND_CHANNEL, queryParams.report );
end 
this.updateWindowTitle(  );
end 
end 

function updateWindowTitle( this )
if ~isempty( this.CustomTitle )
title = this.CustomTitle;
else 
title = this.determineDefaultTitle(  );
end 
this.Client.WindowTitle = title;
end 

function initServices( this )

services = codergui.internal.findServiceProviders( this.SERVICES_PACKAGE,  ...
'Invoke', true, 'Args', { this },  ...
'StaticFactoryMethod', 'createInstance',  ...
'Validator', @( x )ismethod( x, 'start' ) && ismethod( x, 'shutdown' ) );
for i = 1:numel( services )
this.Client.installWebService( services{ i } );
end 
end 

function addSubscribers( this )
this.Client.subscribe( this.REPORT_CHANGE_RECEIVE_CHANNEL, @handleReportChanged );

function handleReportChanged( reportPath )
if ~codergui.internal.VirtualReport.isVirtualReportId( reportPath )
this.SuppressChange = true;
this.ReportFile = reportPath;
this.SuppressChange = false;
end 
end 
end 

function title = determineDefaultTitle( this )
reportType = this.ReportType;
title = reportType.getWindowTitle( this.Manifest );
if reportType.AppendFilePathToTitle && ~isempty( this.ReportFile )
title = sprintf( '%s - %s', title, this.ReportFile );
end 
end 
end 

methods ( Static, Access = private )
function manifest = loadManifest( fileSystem )
try 
manifest = fileSystem.loadMatFile( 'manifest.mat', 'manifest' );
manifest = manifest.manifest;
catch me
manifest = [  ];
coder.internal.gui.asyncDebugPrint( me );
end 
end 
end 

methods ( Static )
function viewers = getReportViewers( file )
R36
file char = ''
end 

viewerClients = codergui.WebClient.getWebClients( @( c )c.hasProperty( codergui.ReportViewer.REPORT_VIEWER_PROPERTY ) );
viewers = {  };
for i = 1:numel( viewerClients )
viewer = viewerClients{ i }.getProperty( codergui.ReportViewer.REPORT_VIEWER_PROPERTY );
if isvalid( viewer ) && ( isempty( file ) || ( ispc(  ) && strcmpi( viewer.ReportFile, file ) ) ...
 || ( isunix(  ) && strcmp( viewer.ReportFile, file ) ) || isequal( viewer.ReportFile, file ) )
viewers{ end  + 1 } = viewer;%#ok<AGROW>
end 
end 
end 

function viewer = byId( id )
viewerClients = codergui.WebClient.getWebClients(  ...
@( c )c.hasProperty( codergui.ReportViewer.REPORT_VIEWER_PROPERTY ) &&  ...
isequal( c.Id, id ) );
if ~isempty( viewerClients )
viewer = viewerClients{ 1 }.getProperty( codergui.ReportViewer.REPORT_VIEWER_PROPERTY );
else 
viewer = [  ];
end 
end 

function closeAll( file )
if nargin == 0
file = [  ];
else 
[ ~, file ] = codergui.ReportServices.getReportFilename( file );
end 
cellfun( @( v )v.dispose(  ), codergui.ReportViewer.getReportViewers( file ) );
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpm2isDP.p.
% Please follow local copyright laws when handling this file.

