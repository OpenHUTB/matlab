function varargout = slwebview_req( sysName, options )

arguments
    sysName
    options.SearchScope slreportgen.webview.enum.SearchScope = "CurrentAndBelow";
    options.LookUnderMasks slreportgen.webview.enum.LookUnderMasks = false;
    options.FollowLinks slreportgen.webview.enum.OnOffSwitchState = false;
    options.FollowModelReference slreportgen.webview.enum.OnOffSwitchState = false;
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


if isempty( options.PackageName )
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

modelH = slreportgen.utils.getModelHandle( sysH );



if rmisl.modelHasEmbeddedReqInfo( modelH )
    [ ~, ~, fext ] = fileparts( get_param( modelH, "Filename" ) );

    if strcmpi( fext, '.slx' )
        error( message( 'Slvnv:slreq:DataNeedsUpdating' ) );
    else
        error( message( 'Slvnv:slreq:ExportOrSaveMdlAsSlx' ) );
    end
end


if ( slreportgen.webview.internal.version(  ) == 3 )
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
homeDiagram = model.queryDiagrams( handle = sysH, Count = 1 );

project = slreportgen.webview.internal.Project(  );
project.addModel( model );


selector = slreportgen.webview.internal.DiagramSelector(  );
selector.IncludeMaskedSubsystems = options.LookUnderMasks;
selector.IncludeReferencedModels = options.FollowModelReference;
selector.IncludeUserLibraryLinks = options.FollowLinks;
selector.IncludeSimulinkLibraryLinks = options.FollowLinks;
selector.IncludeVariantSubsystems = "All";
selector.IncludeCommentedDiagrams = true;

if strcmpi( options.SearchScope, "all" )
    selector.Scope = 'CurrentAndBelow';
    selector.select( model.RootDiagram );
else
    selector.unselectAll( model );
    selector.Scope = options.SearchScope;
    selector.select( homeDiagram );
end


wvDoc = slreportgen.webview.internal.RequirementsDocument(  ...
    fullfile( options.PackageFolder, options.PackageName ),  ...
    options.PackageType );
wvDoc.Project = project;
wvDoc.HomeDiagram = homeDiagram;
wvDoc.IncludeNotes = options.IncludeNotes;
wvDoc.SystemView.IncludeReferencedModels = logical( options.FollowModelReference );
wvDoc.SystemView.IncludeLibraryLinks = logical( options.FollowLinks );

[ out1, out2 ] = slreportgen.webview.internal.slwebview_cmd( wvDoc,  ...
    "StringOutput", isstring( options.PackageFolder ) || isstring( options.PackageName ),  ...
    "ShowProgressBar", options.ShowProgressBar,  ...
    "ViewFile", options.ViewFile );
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


reqView = slreportgen.webview.views.RequirementsViewExporter(  );
reqView.IncludeReferencedModels = e.IncludeReferencedModels;
reqView.IsGeneratingNewReport = true;
reqView.IncludeLibraryLinks = e.IncludeLibraryLinks;
reqView.HighlightBeforeExport = true;
reqView.ViewerDataExporter = slreportgen.webview.ViewerDataExporter(  );
reqView.InspectorDataExporter = slreportgen.webview.InspectorDataExporter(  );
reqView.ObjectViewerDataExporter = slreportgen.webview.ObjectViewerDataExporter(  );
reqView.FinderDataExporter = slreportgen.webview.FinderDataExporter(  );
e.SystemView = reqView;


e.RegisteredViews = [  ];

if reqmgt( 'rmiFeature', 'EnhancedWebViewReq' )
    opts.docType = 'InternalReqDocument';
else
    opts.docType = 'InternalDocument';
end
e.export( opts );


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

