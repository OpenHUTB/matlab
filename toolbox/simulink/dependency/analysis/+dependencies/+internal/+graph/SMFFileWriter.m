classdef SMFFileWriter < dependencies.internal.graph.GraphWriter

properties ( Constant )
Extensions = ".smf";
end 

methods 
function write( ~, graph, file, root )
doc = matlab.io.xml.dom.Document( "DependencyReport" );
report = doc.getDocumentElement(  );
report.setAttribute( "Version", "1.2" );

files = i_getFiles( graph.Nodes );
report.appendChild( i_createFileList( doc, files, root ) );

models = i_getModels( graph.Nodes );
fileDeps = i_getFileDependencies( graph );

if ~isempty( models )
for model = models
report.appendChild( i_createMDLDepSet( doc, graph, model, root, fileDeps ) );
fileDeps = dependencies.internal.graph.Dependency.empty;
end 
elseif ~isempty( graph.Nodes )
report.appendChild( i_createMDLDepSet( doc, graph, graph.Nodes( 1 ), root, fileDeps ) );
end 

domwriter = matlab.io.xml.dom.DOMWriter;
domwriter.Configuration.FormatPrettyPrint = true;
domwriter.writeToURI( doc, file )
end 
end 

end 


function filelist = i_createFileList( doc, nodes, root )
filelist = doc.createElement( "FileList" );
filelist.setAttribute( "ProjectRoot", i_serialize( root ) );
for node = nodes
filelist.appendChild( i_createFileState( doc, node, root ) );
end 
end 

function filestate = i_createFileState( doc, node, root )
filestate = doc.createElement( "FileState" );
filestate.appendChild( i_createFileName( doc, node, root ) );

info = dir( node.Location{ 1 } );
if length( info ) == 1
filestate.appendChild( i_createTextElement( doc, "Size", info.bytes ) );
filestate.appendChild( i_createTextElement( doc, "LastModifiedDate", info.date ) );
else 
filestate.appendChild( i_createTextElement( doc, "Size", "0" ) );
filestate.appendChild( i_createTextElement( doc, "LastModifiedDate", "<file not found>" ) );
end 

filestate.appendChild( i_createTextElement( doc, "Exportable", node.Resolved ) );
end 

function depset = i_createMDLDepSet( doc, graph, model, root, nonModelDeps )
depset = doc.createElement( "MDLDepSet" );

path = model.Location{ 1 };
[ ~, name ] = fileparts( path );
islibrary = i_isBlockDiagramType( path, "Library" );

depset.appendChild( i_createTextElement( doc, "MDLName", name, "IsLibrary", islibrary ) );
depset.appendChild( i_createFileName( doc, model, root ) );
depset.appendChild( i_createTextElement( doc, "AnalysisDate", datestr( now ) ) );

refModels = i_getModels( [ graph.getDownstreamDependencies( model ).DownstreamNode ] );
depset.appendChild( i_createReferencedDiagrams( doc, "ReferencedModels", "Model", refModels, root ) );
depset.appendChild( i_createReferencedDiagrams( doc, "ReferencedSubsystems", "Subsystem", refModels, root ) );
depset.appendChild( i_createReferencedDiagrams( doc, "LinkedLibraries", "Library", refModels, root ) );

depset.appendChild( i_createToolboxes( doc, graph, model ) );

depset.appendChild( i_createAllFiles( doc, model, nonModelDeps, root ) );
depset.appendChild( doc.createElement( "AllIncludeDirs" ) );
depset.appendChild( i_createAllReferences( doc, nonModelDeps, root ) );
end 

function element = i_createReferencedDiagrams( doc, element, type, models, root )
element = doc.createElement( element );
for model = models
path = model.Location{ 1 };
[ ~, name ] = fileparts( path );
if i_isBlockDiagramType( path, type )
mdlfile = doc.createElement( "MDLFile" );
mdlfile.appendChild( i_createTextElement( doc, "MDLName", name ) );
mdlfile.appendChild( i_createFileName( doc, model, root ) );
element.appendChild( mdlfile );
end 
end 
end 

function element = i_createToolboxes( doc, graph, model )
element = doc.createElement( "Toolboxes" );

finder = dependencies.internal.analysis.toolbox.ToolboxFinder;
for toolbox = i_getToolboxes( graph, model )
if toolbox.Type == dependencies.internal.graph.Type.PRODUCT
if length( toolbox.Location ) > 1

continue ;
end 

info = finder.fromBaseCode( toolbox.Location{ 1 } );
if ~info.IsInstalled
continue ;
end 

folder = info.DirectoryName;
else 
folder = toolbox.Location{ 1 };
end 

verinfo = ver( folder );
if length( verinfo ) ~= 1
continue ;
end 

details = doc.createElement( "ToolboxDetails" );
details.appendChild( i_createTextElement( doc, "DirectoryName", folder ) );
details.appendChild( i_createTextElement( doc, "Name", verinfo.Name ) );
details.appendChild( i_createTextElement( doc, "Version", verinfo.Version ) );
details.appendChild( i_createTextElement( doc, "Release", verinfo.Release ) );
details.appendChild( i_createTextElement( doc, "Date", verinfo.Date ) );
element.appendChild( details );
end 
end 

function element = i_createAllFiles( doc, model, deps, root )
element = doc.createElement( "AllFiles" );
element.appendChild( i_createFileName( doc, model, root ) );
nodes = [ deps.DownstreamNode ];
if ~isempty( nodes )
for node = unique( nodes )
element.appendChild( i_createFileName( doc, node, root ) );
end 
end 
end 

function element = i_createAllReferences( doc, deps, root )
element = doc.createElement( "AllReferences" );
for dep = deps
fileref = doc.createElement( "FileReference" );
fileref.appendChild( i_createFileName( doc, dep.DownstreamNode, root ) );
fileref.appendChild( i_createTextElement( doc, "ReferenceType", dep.Type.ID ) );
fileref.appendChild( i_createTextElement( doc, "ReferenceLocation", i_getLocation( dep ) ) );
fileref.appendChild( i_createTextElement( doc, "Resolved", dep.DownstreamNode.Resolved ) );
fileref.appendChild( doc.createElement( "ToolboxDetails" ) );
element.appendChild( fileref );
end 
end 

function location = i_getLocation( dep )
if ismember( dep.Type.Base.ID, [ "MATLABFile", "CSource" ] )
location = dep.UpstreamNode.Location{ 1 } + ":" + dep.UpstreamComponent.Path;
elseif strlength( dep.UpstreamComponent.Path ) == 0
if endsWith( dep.UpstreamNode.Location{ 1 }, [ ".slx", ".mdl" ] )
[ ~, location ] = fileparts( dep.UpstreamNode.Location{ 1 } );
else 
location = dep.UpstreamNode.Location{ 1 };
end 
else 
location = regexprep( dep.UpstreamComponent.Path, "\s", " " );
end 
end 

function filename = i_createFileName( doc, node, root )
[ path, relative ] = i_serialize( node.Location{ 1 }, root );

if relative
relativeto = "projectroot";
else 
relativeto = "none";
end 

filename = i_createTextElement( doc,  ...
"FileName", path,  ...
"RelativeTo", relativeto );
end 

function element = i_createTextElement( doc, name, text, attributes, values )
R36
doc( 1, 1 )matlab.io.xml.dom.Document;
name( 1, 1 )string;
text( 1, 1 )string;
end 
R36( Repeating )
attributes( 1, 1 )string;
values( 1, 1 )string;
end 

element = doc.createElement( name );
element.appendChild( doc.createTextNode( text ) );
for n = 1:length( attributes )
element.setAttribute( attributes{ n }, values{ n } );
end 
end 

function [ path, relative ] = i_serialize( path, root )
relative = nargin > 1 && strlength( root ) > 0 && startsWith( path, root );
if relative
path = eraseBetween( path, 1, strlength( root ) + 1 );
end 
path = strrep( path, filesep, '/' );
end 

function nodes = i_getFiles( nodes )
nodes = nodes( nodes.isFile );
end 

function models = i_getModels( nodes )
if isempty( nodes )
models = dependencies.internal.graph.Node.empty;
else 
filter = dependencies.internal.graph.NodeFilter.fileExtension( [ ".slx", ".mdl" ] );
models = nodes( filter.apply( nodes ) );
end 
end 

function toolboxes = i_getToolboxes( graph, node )
filter = dependencies.internal.graph.DependencyFilter.hasRelationship( "Toolbox" );
deps = graph.getDownstreamDependencies( node );
toolboxes = [ deps( filter.apply( deps ) ).DownstreamNode ];
end 

function deps = i_getFileDependencies( graph )
import dependencies.internal.graph.NodeFilter.nodeType;
import dependencies.internal.graph.DependencyFilter.downstream;
filter = downstream( nodeType( "File" ) );
deps = graph.Dependencies( filter.apply( graph.Dependencies ) );
end 

function result = i_isBlockDiagramType( path, type )
try 
result = strcmp( Simulink.MDLInfo( path ).BlockDiagramType, type );
catch 
result = false;
end 
end 

% Decoded using De-pcode utility v1.2 from file /tmp/tmpIPLcCL.p.
% Please follow local copyright laws when handling this file.

