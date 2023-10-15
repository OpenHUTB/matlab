function depview( model, parameters )

arguments
    model{ i_isModelNameOrHandle }
    parameters.FileDependenciesIncludingLibraries( 1, 1 )logical;
    parameters.FileDependenciesExcludingLibraries( 1, 1 )logical = false;
    parameters.ModelReferenceInstance( 1, 1 )logical = false;
    parameters.ShowHorizontal( 1, 1 )logical;
    parameters.FactoryDependencies( 1, 1 )logical = false;
    parameters.ShowFullPath( 1, 1 )logical = false;
    parameters.Debug( 1, 1 )logical = false;
end

if ~feature( "HasDisplay" )
    title = string( message( "MATLAB:dependency:viewer:AppTitle" ) );
    error( message( "MATLAB:dependency:viewer:CannotRunInNoDisplayMode", title ) );
end

modelPath = i_getFullPathOrThrow( model );

[ workflow, hideLibraries ] = i_parseModeOrThrow( parameters );

if isfield( parameters, "ShowHorizontal" )
    showHorizontal = parameters.ShowHorizontal;
else
    showHorizontal = [  ];
end

if parameters.FactoryDependencies
    propertiesTitle = string( message( "MATLAB:dependency:viewer:InspectorTitle" ) );
    productsTitle = string( message( "MATLAB:dependency:viewer:InspectorProductsPaneTitle" ) );
    warning( message( "SimulinkDependencyAnalysis:Viewer:FactoryDependenciesIgnored", productsTitle, propertiesTitle ) );
end
if parameters.ShowFullPath
    propertiesTitle = string( message( "MATLAB:dependency:viewer:InspectorTitle" ) );
    detailsTitle = string( message( "MATLAB:dependency:viewer:InspectorDetailsPaneTitle" ) );
    warning( message( "SimulinkDependencyAnalysis:Viewer:ShowFullPathIgnored", detailsTitle, propertiesTitle ) );
end

i_openUnifiedDependencyViewer( modelPath, parameters.Debug,  ...
    workflow, hideLibraries, showHorizontal );

end

function i_isModelNameOrHandle( value )
valid = ischar( value ) ||  ...
    isscalar( value ) && ( isstring( value ) || is_simulink_handle( value ) );
if ~valid
    error( message( "SimulinkDependencyAnalysis:Viewer:InputMustBeModel" ) );
end
end

function fullPath = i_getFullPathOrThrow( modelNameOrHandle )
if is_simulink_handle( modelNameOrHandle )
    fullPath = get_param( modelNameOrHandle, "FileName" );
    if fullPath == ""
        errorForTemporaryModel( modelNameOrHandle );
    end
else
    if exist( modelNameOrHandle, "file" ) == 0
        trimmedModelNameOrHandle = strtrim( modelNameOrHandle );
        if ~strcmp( trimmedModelNameOrHandle, modelNameOrHandle ) && exist( trimmedModelNameOrHandle, "file" ) ~= 0
            modelNameOrHandle = trimmedModelNameOrHandle;
        else
            error( message( "SimulinkDependencyAnalysis:Viewer:FileMustExist", modelNameOrHandle ) );
        end
    end

    fullPath = which( modelNameOrHandle );
    if fullPath == ""


        fullPath = modelNameOrHandle;
    end
end

if strcmp( fullPath, "new Simulink model" )
    errorForTemporaryModel( modelNameOrHandle );
end
end

function errorForTemporaryModel( modelNameOrHandle )
if "on" == get_param( modelNameOrHandle, "ModelTemplatePlugin" )
    error( message( "SimulinkDependencyAnalysis:Viewer:CannotAnalyzeEditedTemplate" ) );
else
    error( message( "SimulinkDependencyAnalysis:Viewer:CannotAnalyzeUntitledModel" ) );
end
end

function [ workflow, hideLibraries ] = i_parseModeOrThrow( parameters )
includeLibsDefined = isfield( parameters, "FileDependenciesIncludingLibraries" );
includeLibs = includeLibsDefined && parameters.FileDependenciesIncludingLibraries;
excludeLibs = parameters.FileDependenciesExcludingLibraries;
instance = parameters.ModelReferenceInstance;


workflow = string( message( "SimulinkDependencyAnalysis:Viewer:ModelHierarchyTitle" ) );
hideLibraries = false;

numSelected = length( find( [ includeLibs, excludeLibs, instance ] ) );
if numSelected > 1
    error( message( "SimulinkDependencyAnalysis:Viewer:TooManyModesSelected" ) );
elseif excludeLibs
    hideLibraries = true;
elseif instance
    workflow = string( message( "SimulinkDependencyAnalysis:Viewer:ModelInstancesTitle" ) );
elseif includeLibsDefined && numSelected == 0
    workflow = "";
end
end

function root = i_getProjectRoot(  )
project = matlab.project.currentProject(  );
if isempty( project )
    root = "";
else
    root = project.RootFolder;
end
end

function i_openUnifiedDependencyViewer( filePath, debug, workflow, hideLibraries, showHorizontal )
import dependencies.internal.viewer.postEvent;
import dependencies.internal.graph.NodeFilter;

[ ~, filename, ext ] = fileparts( filePath );

if i_isASerializedGraph( filePath )
    projectRoot = i_getProjectRoot(  );
    graph = dependencies.internal.graph.read( filePath, projectRoot );
    nodes = graph.Nodes;
    sessionPropertyEntry.Name = string( message( "SimulinkDependencyAnalysis:Viewer:FullPathLabel" ) );
    sessionPropertyEntry.Value = filePath;
    sessionPropertyEntry.Type = dependencies.internal.viewer.StringPropertyType.PATH;
    analysisName = string( filename ) + string( ext );
else
    sessionPropertyEntry.Name = string( message( "SimulinkDependencyAnalysis:Viewer:ModelNameLabel" ) );
    sessionPropertyEntry.Value = filename;
    analysisName = filename;
    if ~any( strcmp( ext, [ ".slx", ".mdl" ] ) )
        error( message( "SimulinkDependencyAnalysis:Viewer:FileMustBeModelOrLibrary", filePath ) );
    end
    graph = dependencies.internal.graph.Graph.empty;
    nodes = dependencies.internal.graph.Node.createFileNode( filePath );
    if NodeFilter.fileWithin( string( matlabroot ) ).apply( nodes )
        warning( message( "SimulinkDependencyAnalysis:Viewer:NoResultsForBuiltInFiles" ) );
    end
end

viewer = dependencies.internal.viewer.DependencyViewer(  ...
    "Nodes", nodes,  ...
    "Debug", debug,  ...
    "Name", analysisName,  ...
    "Workflow", workflow,  ...
    "Tag", 'SimulinkDependencyAnalyzer' );

if hideLibraries
    libraryName = string( message( "SimulinkDependencyAnalysis:Viewer:Library" ) );
    nodeColors = viewer.View.CurrentWorkflow.NodeColors.toArray;
    colorToFilter = nodeColors( strcmp( { nodeColors.Name }, libraryName ) ).Color;
    postEvent( viewer, "EnabledColorRequestEvent", "Color", colorToFilter, "Enabled", false );
end

if ~isempty( showHorizontal )
    if showHorizontal
        postEvent( viewer, "LayoutRequestEvent", "Layout", dependencies.internal.viewer.Layout.HORIZONTAL );
    else
        postEvent( viewer, "LayoutRequestEvent", "Layout", dependencies.internal.viewer.Layout.VERTICAL );
    end
end

entry = dependencies.internal.viewer.StringProperty( viewer.View.getViewModel, sessionPropertyEntry );
viewer.View.SessionProperties.add( entry );

wm = dependencies.internal.widget.WindowManager.Instance;

if isempty( graph )
    wm.launchAndRegister( viewer );
    if ~isempty( nodes )
        viewer.analyze( nodes );
    end
else
    viewer.setGraph( graph );
    wm.launchAndRegister( viewer );
end
end

function isSerializedGraph = i_isASerializedGraph( file )
graphExtensions = dependencies.internal.Registry.Instance.getGraphReaderExtensions(  );
isSerializedGraph = endsWith( file, graphExtensions );
end
