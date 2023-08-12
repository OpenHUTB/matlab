function fromFile( sourceFiles, options )




R36
sourceFiles( 1, : )string
options.Debug( 1, 1 )logical = false
options.Graph( 1, 1 )dependencies.internal.graph.Graph
options.Shortcuts( 1, : )string{ mustBeMember( options.Shortcuts, sourceFiles ) }
options.OpenProject( 1, 1 )logical = true
options.ProjectCreatedCallback( 1, 1 )function_handle
end 

sourceFiles = unique( string( sourceFiles ) );
i_ensureExist( sourceFiles );
i_ensureNotUnderProjectRoot( sourceFiles );
arrayfun(  ...
@matlab.internal.project.creation.validateIsNotInMatlabRoot,  ...
sourceFiles );

if matlab.internal.project.util.getCommonParentFolder( sourceFiles ) == ""
error( message( "MATLAB:project:creation:NoValidRoot" ) )
end 

if isfield( options, "Shortcuts" )
shortcuts = options.Shortcuts;
options = rmfield( options, "Shortcuts" );
else 
if numel( sourceFiles ) == 1
shortcuts = sourceFiles;
else 
shortcuts = string.empty;
end 
end 

if isfield( options, "Graph" )
graph = options.Graph;
options = rmfield( options, "Graph" );
else 
nodes = dependencies.internal.graph.Node.createFileNode( sourceFiles );
progressDialog =  ...
dependencies.internal.widget.launchProgressDialog(  ...
"projectFromFileDependencyAnalysisProgress", Debug = options.Debug );
[ graph, wasCancelled ] =  ...
matlab.internal.project.creation.analyzeWithProgress( nodes );
progressDialog.close(  );

if wasCancelled
return 
end 
end 

sourceFiles = i_sortByNumberOfImpacted( sourceFiles, graph );
requiredFiles = i_getRequiredFiles( sourceFiles, graph );

optionsAsCell = namedargs2cell( options );
windowHandle = matlab.internal.project.creation.FromFileUi(  ...
sourceFiles, requiredFiles, shortcuts, optionsAsCell{ : } );

windowManager = dependencies.internal.widget.WindowManager.Instance;
windowManager.launchAndRegister( windowHandle );
end 


function requiredFiles = i_getRequiredFiles( sourceFiles, graph )
import dependencies.internal.graph.NodeFilter
sourceFilesNodes =  ...
dependencies.internal.graph.Node.createFileNode( sourceFiles );
requiredFilesFilter =  ...
NodeFilter.requiredBy( graph, sourceFilesNodes ) &  ...
NodeFilter.nodeType( "File" ) &  ...
NodeFilter.isResolved &  ...
~NodeFilter.fileExtension( i_getDerivedExtensions(  ) );
requiredFilesNodes = requiredFilesFilter.filter( graph.Nodes );
requiredFiles = string( [ requiredFilesNodes.Location ] );
end 

function extensions = i_getDerivedExtensions(  )
extensions = "." + matlab.internal.project.creation.getDerivedExtensions(  );
end 

function files = i_sortByNumberOfImpacted( files, graph )
nodes = dependencies.internal.graph.Node.createFileNode( files );
numberOfImpacted = arrayfun(  ...
@( node )i_getNumberOfImpacted( node, graph ), nodes );
[ ~, indices ] = sort( numberOfImpacted );
files = files( indices );
end 

function number = i_getNumberOfImpacted( node, graph )
import dependencies.internal.graph.NodeFilter
filter =  ...
NodeFilter.impactedBy( graph, node ) &  ...
NodeFilter.nodeType( "File" ) &  ...
NodeFilter.isResolved;
number = sum( filter.apply( graph.Nodes ), "all" );
end 

function i_ensureExist( files )
existFlags = isfile( files );
if all( existFlags )
return 
end 

missingFiles = strjoin( files( ~existFlags ), newline );
error( message(  ...
"MATLAB:project:view_fromfile:SourceFilesNoExistMessage",  ...
missingFiles ) )
end 

function i_ensureNotUnderProjectRoot( files )
flags = matlab.internal.project.util.isUnderProjectRoot( files );
if ~any( flags )
return 
end 

flaggedFiles = strjoin( files( flags ), newline );
error( message(  ...
"MATLAB:project:view_fromfile:SourceFilesInsideExistingProjectMessage",  ...
flaggedFiles ) )
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpnXFcjF.p.
% Please follow local copyright laws when handling this file.

