function varargout = slwebview_slicer( sysName, options )
















































































































R36
sysName
options.InlineOptions = SlicerConfiguration.getDefaultOptions(  ).InlineOptions;
options.IncludeSystems = [  ]
options.IncludeNotes slreportgen.webview.enum.OnOffSwitchState = false;
options.ViewFile slreportgen.webview.enum.OnOffSwitchState = true;
options.ShowProgressBar slreportgen.webview.enum.OnOffSwitchState = true;

options.FileName = '';
options.PackageName = '';
options.PackageFolder = pwd(  );
options.PackageType slreportgen.webview.enum.PackageType = 'unzipped';
options.PackagingType string = string.empty(  );
end 


if ~isempty( options.PackagingType )
options.PackageType = options.PackagingType;
end 
options.PackagingType = lower( char( options.PackageType ) );


sysH = slreportgen.utils.getSlSfHandle( sysName );


if isempty( options.PackageName ) || ( strlength( options.PackageName ) == 0 )
if isnumeric( sysH )
resolvedSysName = get_param( sysH, "Name" );
else 
resolvedSysName = sysH.Name;
end 
options.PackageName = regexprep( resolvedSysName, "\s", "_" );
end 


if ~isempty( options.FileName ) && ( strlength( options.FileName ) > 0 )
[ fPath, fName ] = fileparts( options.FileName );
if isempty( fPath )
fPath = pwd;
end 
options.PackageFolder = fPath;
options.PackageName = fName;
end 


slicerView = slreportgen.webview.views.SlicerViewExporter(  );
slicerView.HighlightBeforeExport = true;
slicerView.ViewerDataExporter = slreportgen.webview.ViewerDataExporter(  );
slicerView.InspectorDataExporter = slreportgen.webview.InspectorDataExporter(  );
slicerView.ObjectViewerDataExporter = slreportgen.webview.ObjectViewerDataExporter(  );


if ( slreportgen.webview.internal.version(  ) == 3 )

varargout{ 1 } = exportVersion3( sysH, options, slicerView );
else 
varargout{ 1 } = exportVersion2( sysH, options, slicerView );
end 
end 

function out = exportVersion3( sysH, options, slicerView )

modelName = get_param( slreportgen.utils.getModelHandle( sysH ), "Name" );
modelBuilder = slreportgen.webview.internal.ModelBuilder(  );
model = modelBuilder.build( modelName,  ...
"LoadLibraries", options.InlineOptions.Libraries,  ...
"Cache", false );
model.loadReferencedSubsystems(  );

project = slreportgen.webview.internal.Project(  );
project.addModel( model );


selector = slreportgen.webview.internal.DiagramSelector(  );
selector.Scope = "CurrentAndBelow";
selector.IncludeMaskedSubsystems = options.InlineOptions.Masks;
selector.IncludeReferencedModels = options.InlineOptions.ModelBlocks;
selector.IncludeUserLibraryLinks = options.InlineOptions.Libraries;
selector.IncludeSimulinkLibraryLinks = options.InlineOptions.Libraries;
if options.InlineOptions.Variants
selector.IncludeVariantSubsystems = "All";
else 
selector.IncludeVariantSubsystems = "Active";
end 
selector.IncludeCommentedDiagrams = true;
selector.unselectAll( model );

homeDiagram = model.queryDiagrams( "handle", sysH, "Count", 1 );
selector.select( homeDiagram );


selectedDiagrams = selector.getSelectedDiagrams( model );
keepHandles = options.IncludeSystems( : );
keepHandles( end  + 1 ) = sysH;
keepSIDs = Simulink.ID.getSID( keepHandles );
for i = 1:numel( selectedDiagrams )
selectedDiagram = selectedDiagrams( i );
if selectedDiagram.IsModelReference
sid = selectedDiagram.ESID;
else 
sid = selectedDiagram.SID;
end 
selectedDiagram.Selected = ismember( sid, keepSIDs );
end 

wvDoc = slreportgen.webview.internal.Document(  ...
fullfile( options.PackageFolder, options.PackageName ),  ...
options.PackageType );
wvDoc.Project = project;
wvDoc.HomeDiagram = homeDiagram;
wvDoc.IncludeNotes = options.IncludeNotes;
wvDoc.SystemView = slicerView;
wvDoc.IncrementalExport = false;

out = slreportgen.webview.internal.slwebview_cmd( wvDoc,  ...
"StringOutput", isstring( options.PackageFolder ) || isstring( options.PackageName ),  ...
"ShowProgressBar", options.ShowProgressBar,  ...
"ViewFile", options.ViewFile );
end 




function mainFile = exportVersion2( sysH, options, slicerView )
mainFile = '';
options.ExportFolder = options.PackageFolder;
exportPath = strcat( options.ExportFolder, filesep, options.PackageName );
filter = slreportgen.webview.views.SlicerModelHierarchyFilter;
filter.IncludeSystems = options.IncludeSystems;
filter.IncludeReferenceModel = options.InlineOptions.ModelBlocks;
filter.IncludeUserLinks = options.InlineOptions.Libraries;
filter.IncludeMathworksLinks = options.InlineOptions.Libraries;
filter.IncludeMaskSubSystems = options.InlineOptions.Masks;
filter.IncludeVariants = options.InlineOptions.Variants;
hierModel = slreportgen.webview.ModelHierarchy(  );
hierModel.addItemsAndTheirDescendants( sysH, filter );
try 

if isnumeric( sysH )
sysName = get_param( sysH, "Name" );
else 
sysName = sysH.Name;
end 


progressBar = slreportgen.webview.ui.ProgressBar(  );
setTitle( progressBar,  ...
getString( message( 'slreportgen_webview:webview:ExportWaitbarMsg', sysName ) ) );

wvDoc = slreportgen.webview.InternalDocument( exportPath, options.PackagingType );
wvDoc.HomeSystem = getItem( hierModel, sysH );
wvDoc.Systems = hierModel;
wvDoc.IncludeNotes = slreportgen.webview.utils.toLogical( options.IncludeNotes );
wvDoc.SystemView = slicerView;

webviewWeight = 0.9;
dispWeight = 0.1;

displayProgressMonitor = slreportgen.webview.ProgressMonitor( 0, 1 );
addChild( progressBar, wvDoc.ProgressMonitor, webviewWeight );
addChild( progressBar, displayProgressMonitor, dispWeight );

progressBar.ShowMessagePriority = progressBar.ImportantMessagePriority;
setMessage( progressBar,  ...
message( 'slreportgen_webview:exporter:ExportingSystem', sysName ),  ...
progressBar.ImportantMessagePriority );

if options.ShowProgressBar
show( progressBar );
end 

wvDoc.open(  );
wvDoc.fill(  );
wvDoc.close(  );
catch mex
done( progressBar );
rethrow( mex );
end 

[ folder, name, ~ ] = fileparts( exportPath );

if isCanceled( progressBar )
if strcmp( options.PackagingType, 'zipped' )
if exist( exportPath, 'file' )
delete( exportPath );
end 
end 

if strcmp( options.PackagingType, 'unzipped' ) || strcmp( options.PackagingType, 'both' )
unzipDir = fullfile( folder, name );
if exist( unzipDir, 'dir' )
rmdir( unzipDir, 's' );
end 
done( progressBar );
end 
return 
end 
zipname = fullfile( folder, strcat( name, '.zip' ) );

if strcmp( options.PackagingType, 'zipped' ) || strcmp( options.PackagingType, 'both' )
movefile( exportPath, zipname );
end 

mainFile = displayWebView( options, exportPath, displayProgressMonitor );

done( progressBar );
end 

function mainFile = displayWebView( options, exportPath, progressMonitor )
import mlreportgen.dom.*;

[ ~, name, ~ ] = fileparts( exportPath );
mainPart = 'webview.html';
if strcmp( options.PackagingType, 'unzipped' ) || strcmp( options.PackagingType, 'both' )
viewdir = fullfile( options.ExportFolder, name );
mainPart = 'webview.html';
else 
viewdir = fullfile( tempdir, 'mlreportgen' );
if exist( viewdir, 'dir' )
rmdir( viewdir, 's' );
end 
mkdir( viewdir );
wvPath = fullfile( options.ExportFolder, strcat( name, '.zip' ) );
setMessage( progressMonitor,  ...
message( 'slreportgen_webview:exporter:UnzippingFiles' ),  ...
progressMonitor.ImportantMessagePriority );
unzip( wvPath, viewdir );
end 
setMessage( progressMonitor,  ...
message( 'slreportgen_webview:exporter:DisplayingWebview' ),  ...
progressMonitor.ImportantMessagePriority );
mainFile = fullfile( viewdir, mainPart );

if options.ViewFile
web( mainFile, '-browser' );
end 

setValue( progressMonitor, 1 );
done( progressMonitor );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmp981fRY.p.
% Please follow local copyright laws when handling this file.

