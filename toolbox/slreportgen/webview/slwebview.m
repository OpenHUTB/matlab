function varargout = slwebview( sysName, options )

arguments
    sysName = "-show_dialog"
    options.SearchScope slreportgen.webview.enum.SearchScope = "CurrentAndBelow";
    options.LookUnderMasks slreportgen.webview.enum.LookUnderMasks = "none";
    options.FollowLinks slreportgen.webview.enum.OnOffSwitchState = "off";
    options.FollowModelReference slreportgen.webview.enum.OnOffSwitchState = "off";
    options.IncludeNotes slreportgen.webview.enum.OnOffSwitchState = "off";
    options.OptionalViews( 1, : )string = string.empty(  );

    options.ViewFile slreportgen.webview.enum.OnOffSwitchState = "on";

    options.FileName = '';
    options.PackageName = '';
    options.PackageFolder = pwd(  );
    options.PackageType slreportgen.webview.enum.PackageType = 'both';
    options.PackagingType string = string.empty(  );
    options.RecurseFolder slreportgen.webview.enum.OnOffSwitchState = "off";

    options.IncrementalExport slreportgen.webview.enum.OnOffSwitchState = "off";

    options.ShowProgressBar slreportgen.webview.enum.OnOffSwitchState = true;
    options.ProgressMonitor slreportgen.webview.ProgressMonitor = slreportgen.webview.ProgressMonitor.empty(  );
end


if ~isempty( options.PackagingType )
    options.PackageType = options.PackagingType;
end
options.PackagingType = lower( char( options.PackageType ) );

if ( ischar( sysName ) || isstring( sysName ) )
    if strcmp( sysName, "-show_dialog" )
        slreportgen.webview.ui.Exporter.showDialog( [  ], false );
        return ;

    elseif strcmp( sysName, "-clear_registry" )
        slreportgen.webview.views.getRegisteredViews( true );
        return

    else
        r = slreportgen.webview.utils.ScopedDiagramResolver(  ...
            sysName,  ...
            "RecurseFolder", options.RecurseFolder );
        unresolvedNames = r.UnresolvedNames;
        mustNotExportToSameFolder( unresolvedNames, options );
        n = numel( unresolvedNames );


        options.ViewFile = options.ViewFile && ( n == 1 );

        out1 = cell( n, 1 );
        out2 = cell( n, 1 );
        i = 0;
        while hasNext( r )
            dhid = next( r );
            i = i + 1;
            [ out1{ i }, out2{ i } ] = exportModel( dhid, options );
        end
    end
else
    hs = slreportgen.utils.HierarchyService;
    dhid = hs.getDiagramHID( sysName );
    [ out1, out2 ] = exportModel( dhid, options );
end

if ( iscell( out1 ) && ( numel( out1 ) == 1 ) )
    varargout{ 1 } = out1{ 1 };
    varargout{ 2 } = out2{ 1 };
else
    varargout{ 1 } = out1;
    varargout{ 2 } = out2;
end
end

function [ out1, out2 ] = exportModel( dhid, options )

if isempty( options.PackageName )
    sysH = slreportgen.utils.getSlSfHandle( dhid );
    if isnumeric( sysH )
        sysName = get_param( sysH, "Name" );
    else
        sysName = sysH.Name;
    end
    options.PackageName = regexprep( sysName, "\s", "_" );
end


if ( ~isempty( options.FileName ) && ( strlength( options.FileName ) > 0 ) )
    [ fPath, fName ] = fileparts( options.FileName );
    if isempty( fPath )
        fPath = pwd;
    end
    options.PackageFolder = fPath;
    options.PackageName = fName;
end


if strcmpi( options.PackageFolder, "$model" )
    modelH = slreportgen.utils.getModelHandle( dhid );
    options.PackageFolder = mlreportgen.utils.internal.canonicalPath( fileparts( get_param( modelH, "FileName" ) ) );
end

if ( slreportgen.webview.internal.version == 3 )
    [ out1, out2 ] = exportVersion3( dhid, options );
else
    [ out1, out2 ] = exportVersion2( dhid, options );
end
end

function [ out1, out2 ] = exportVersion3( dhid, options )

modelH = slreportgen.utils.getModelHandle( dhid );
modelName = get_param( modelH, 'Name' );
modelBuilder = slreportgen.webview.internal.ModelBuilder(  );
model = modelBuilder.build( modelName,  ...
    "LoadLibraries", options.FollowLinks,  ...
    "Cache", options.IncrementalExport );
model.loadReferencedSubsystems(  );

dpath = slreportgen.utils.HierarchyService.getPath( dhid );
homeDiagram = model.queryDiagrams( "path", dpath, "Count", 1 );
if isempty( homeDiagram )

    model.loadReferencedModels(  );
    homeDiagram = model.queryDiagrams( "path", dpath, "Count", 1 );
end

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


regViews = slreportgen.webview.views.getRegisteredViews(  );
regViews = [ regViews{ : } ];
regViewIDs = string( { regViews.Id } );
idx = false( 1, numel( regViews ) );
for optViewID = options.OptionalViews
    matches = strcmpi( optViewID, regViewIDs );
    if ~any( matches )
        warning( message( 'slreportgen_webview:webview:InvalidOptionalView',  ...
            optViewID,  ...
            strjoin( regViewIDs, ", " ) ) );
    else
        idx = idx | matches;
    end
end
optViews = regViews( idx );
for i = 1:numel( optViews )
    optViews( i ).WidgetEnableValue = true;
end


wvDoc = slreportgen.webview.internal.Document(  ...
    fullfile( options.PackageFolder, options.PackageName ),  ...
    options.PackageType );
wvDoc.Project = project;
wvDoc.HomeDiagram = homeDiagram;
wvDoc.IncludeNotes = options.IncludeNotes;
wvDoc.OptionalViews = optViews;
wvDoc.IncrementalExport = options.IncrementalExport;

if ~isempty( options.ProgressMonitor )
    options.ShowProgressBar = false;
    options.ProgressMonitor.addChild( wvDoc.ProgressMonitor );
end


[ out1, out2 ] = slreportgen.webview.internal.slwebview_cmd( wvDoc,  ...
    "StringOutput", isstring( options.PackageFolder ) || isstring( options.PackageName ),  ...
    "ShowProgressBar", options.ShowProgressBar,  ...
    "ViewFile", options.ViewFile );
end

function mustNotExportToSameFolder( names, options )
if ( options.RecurseFolder && ~strcmp( options.PackageFolder, '$model' ) )

    idx = cellfun( @( x )isstring( x ) ...
        && ( endsWith( x, '.slx' ) || endsWith( x, '.mdl' ) ), names );
    modelFiles = string( names( idx ) );

    modelNameToFile = struct(  );
    hasDupModels = false;

    nModels = numel( modelFiles );
    for i = 1:nModels
        modelFile = modelFiles( i );
        [ ~, name ] = fileparts( modelFile );
        if ~isfield( modelNameToFile, name )
            modelNameToFile.( name ) = modelFile;
        else
            hasDupModels = true;
            modelNameToFile.( name ) = [ modelNameToFile.( name ), modelFile ];
        end
    end

    if hasDupModels
        modelNames = string( fieldnames( modelNameToFile ) );
        nModelNames = numel( modelNames );
        dupModelsMsg = '';
        for j = 1:nModelNames
            name = modelNames( j );
            modelFiles = modelNameToFile.( name );
            if ( numel( modelFiles ) > 1 )
                dupFolderMsg = strjoin(  ...
                    cellfun( @( x )sprintf( '\t%s', x ), modelFiles, 'UniformOutput', false ),  ...
                    newline );
                dupModelMsg = sprintf( '%s:\n%s',  ...
                    name,  ...
                    dupFolderMsg );
                dupModelsMsg = [ dupModelsMsg, dupModelMsg, newline ];%#ok
            end
        end

        error( message( 'slreportgen_webview:webview:DuplicateModels', dupModelsMsg ) );
    end
end
end




function [ out1, out2 ] = exportVersion2( dhid, options )
objH = slreportgen.utils.getSlSfHandle( dhid );
e = slreportgen.webview.ui.Exporter( dhid );

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

registeredViews = slreportgen.webview.views.getRegisteredViews(  );
registeredViewIds = strjoin(  ...
    cellfun( @( x )x.Id, registeredViews, 'UniformOutput', false ),  ...
    ', ' );
nRegisteredViews = numel( registeredViews );
nViews = numel( options.OptionalViews );

optViews = cell( 1, nViews );
for i = 1:nViews
    found = false;
    for j = 1:nRegisteredViews
        regView = registeredViews{ j };
        if strcmpi( regView.Id, options.OptionalViews( i ) )
            init( regView, objH );
            regView.WidgetEnableValue = true;
            optViews{ i } = regView;
            found = true;
            break ;
        end
    end

    if ~found
        warning( message( 'slreportgen_webview:webview:InvalidOptionalView',  ...
            options.OptionalViews{ i },  ...
            registeredViewIds ) );
    end
end
optViews( cellfun( @isempty, optViews ) ) = [  ];
e.RegisteredViews = optViews;


exportPath = e.export(  );
basePath = fileparts( exportPath );


switch options.PackagingType
    case 'zipped'
        out1 = fullfile( basePath, strcat( options.PackageName, '.zip' ) );
        out2 = '';

    case 'unzipped'
        out1 = fullfile( basePath, options.PackageName, 'webview.html' );
        out2 = '';

    otherwise
        out1 = fullfile( basePath, strcat( options.PackageName, '.zip' ) );
        out2 = fullfile( basePath, options.PackageName, 'webview.html' );
end
end



