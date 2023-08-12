function varargout = slwebview_cov( sysName, options )










































































R36
sysName
options.SearchScope slreportgen.webview.enum.SearchScope = "CurrentAndBelow";
options.LookUnderMasks slreportgen.webview.enum.LookUnderMasks = true;
options.FollowLinks slreportgen.webview.enum.OnOffSwitchState = false;
options.FollowModelReference slreportgen.webview.enum.OnOffSwitchState = false;
options.IncludeNotes slreportgen.webview.enum.OnOffSwitchState = false;
options.ViewFile slreportgen.webview.enum.OnOffSwitchState = true;
options.ShowProgressBar slreportgen.webview.enum.OnOffSwitchState = true;
options.CovData = [  ]

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
sysName = get_param( sysH, "Name" );
else 
sysName = sysH.Name;
end 
options.PackageName = regexprep( sysName, "\s", "_" );
end 


if ~isempty( options.FileName ) && ( strlength( options.FileName ) > 0 )
[ fPath, fName ] = fileparts( options.FileName );
if isempty( fPath )
fPath = pwd;
end 
options.PackageFolder = fPath;
options.PackageName = fName;
end 


if isempty( options.CovData )
modelH = slreportgen.utils.getModelHandle( sysH );
modelName = get_param( modelH, 'Name' );
options.CovData = cvreportdata( modelName );
end 


if ( slreportgen.webview.internal.version == 3 )
[ out1, out2 ] = exportVersion3( sysH, options );
else 
[ out1, out2 ] = exportVersion2( sysH, options );
end 

varargout{ 1 } = out1;
varargout{ 2 } = out2;
end 

function [ out1, out2 ] = exportVersion3( sysH, options )

modelH = slreportgen.utils.getModelHandle( sysH );
modelName = get_param( modelH, 'Name' );
modelBuilder = slreportgen.webview.internal.ModelBuilder(  );
model = modelBuilder.build( modelName,  ...
"LoadLibraries", options.FollowLinks,  ...
"Cache", false );
model.loadReferencedSubsystems(  );
homeDiagram = model.queryDiagrams( "handle", sysH, "Count", 1 );

project = slreportgen.webview.internal.Project(  );
project.addModel( model );


selector = slreportgen.webview.internal.DiagramSelector(  );
selector.IncludeMaskedSubsystems = options.LookUnderMasks;
selector.IncludeReferencedModels = options.FollowModelReference;
selector.IncludeUserLibraryLinks = options.FollowLinks;
selector.IncludeSimulinkLibraryLinks = options.FollowLinks;
selector.IncludeVariantSubsystems = "All";
selector.IncludeCommentedDiagrams = true;

if strcmpi( options.SearchScope, "All" )
selector.Scope = "CurrentAndBelow";
selector.select( model.RootDiagram );
else 
selector.unselectAll( model );
selector.Scope = options.SearchScope;
selector.select( homeDiagram );
end 


covView = slreportgen.webview.views.ModelCoverageViewExporter(  );
covView.setCoverageData( options.CovData );
covView.HighlightBeforeExport = true;
covView.ViewerDataExporter = slreportgen.webview.ViewerDataExporter(  );
covView.InspectorDataExporter = slreportgen.webview.InspectorDataExporter(  );
covView.ObjectViewerDataExporter = slreportgen.webview.ObjectViewerDataExporter(  );
covView.FinderDataExporter = slreportgen.webview.FinderDataExporter(  );

wvDoc = slreportgen.webview.internal.Document(  ...
fullfile( options.PackageFolder, options.PackageName ),  ...
options.PackageType );
wvDoc.Project = project;
wvDoc.HomeDiagram = homeDiagram;
wvDoc.IncludeNotes = options.IncludeNotes;
wvDoc.SystemView = covView;
wvDoc.IncrementalExport = false;

[ ~, ~ ] = slreportgen.webview.internal.slwebview_cmd( wvDoc,  ...
"StringOutput", isstring( options.PackageFolder ) || isstring( options.PackageName ),  ...
"ShowProgressBar", options.ShowProgressBar,  ...
"ViewFile", options.ViewFile );






switch ( options.PackagingType )
case 'zipped'
out1 = fullfile( options.PackageFolder, strcat( options.PackageName, '.zip' ) );
out2 = '';

case 'unzipped'
out1 = fullfile( options.PackageFolder, options.PackageName, 'webview.html' );
out2 = '';

otherwise 
out1 = fullfile( options.PackageFolder, strcat( options.PackageName, '.zip' ) );
out2 = fullfile( options.PackageFolder, options.PackageName, 'webview.html' );
end 


end 




function [ out1, out2 ] = exportVersion2( sysH, options )

e = slreportgen.webview.ui.Exporter( sysH );

toLogical = @slreportgen.webview.utils.toLogical;
e.Scope = char( options.SearchScope );
e.IncludeReferencedModels = toLogical( options.FollowModelReference );
e.IncludeLibraryLinks = toLogical( options.FollowLinks );
e.IncludeMWLibraryLinks = toLogical( options.FollowLinks );
e.IncludeMaskedSubsystems = toLogical( options.LookUnderMasks );
e.IncludeNotes = toLogical( options.IncludeNotes );
e.DisplayWebView = toLogical( options.ViewFile );
e.ShowProgressBar = toLogical( options.ShowProgressBar );
e.PackagingType = options.PackagingType;
e.ExportFolder = options.PackageFolder;
e.ExportPackageName = options.PackageName;


covView = slreportgen.webview.views.ModelCoverageViewExporter(  );
covView.setCoverageData( options.CovData );
covView.HighlightBeforeExport = true;
covView.ViewerDataExporter = slreportgen.webview.ViewerDataExporter(  );
covView.InspectorDataExporter = slreportgen.webview.InspectorDataExporter(  );
covView.ObjectViewerDataExporter = slreportgen.webview.ObjectViewerDataExporter(  );
e.SystemView = covView;


e.RegisteredViews = [  ];


e.export(  );


switch ( options.PackagingType )
case 'zipped'
out1 = fullfile( options.PackageFolder, strcat( options.PackageName, '.zip' ) );
out2 = '';

case 'unzipped'
out1 = fullfile( options.PackageFolder, options.PackageName, 'webview.html' );
out2 = '';

otherwise 
out1 = fullfile( options.PackageFolder, strcat( options.PackageName, '.zip' ) );
out2 = fullfile( options.PackageFolder, options.PackageName, 'webview.html' );
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpojroVz.p.
% Please follow local copyright laws when handling this file.

