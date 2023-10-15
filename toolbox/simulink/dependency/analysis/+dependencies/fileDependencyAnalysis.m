function [ files, missing, depfile, manifestfile ] = fileDependencyAnalysis( modelname, manifestfile, analyzeUnsavedModels )

arguments
    modelname( 1, : )string{ mustBeNonempty, mustBeNonzeroLengthText };
    manifestfile( 1, : )char = '';
    analyzeUnsavedModels( 1, 1 )logical = false;
end

if strlength( manifestfile ) ~= 0
    manifestfile = Simulink.loadsave.resolveNew( manifestfile, ".smf" );
    i_checkWritable( manifestfile );
end

nodes = dependencies.internal.util.getDispatchableNodes( modelname );
results = dependencies.internal.analyze(  ...
    nodes,  ...
    "Traverse", "Test",  ...
    "AnalyzeUnsavedChanges", true,  ...
    "ResultType", "dependencies.internal.graph.Graph" );

fileNodes = results.Nodes( results.Nodes.isFile );
paths = { fileNodes.Path }';
files = paths( [ fileNodes.Resolved ] );
missing = paths( ~[ fileNodes.Resolved ] );

if nargout > 2 && length( modelname ) == 1
    depfile = i_findDepFile( modelname );
else
    depfile = char.empty( 1, 0 );
end

if strlength( manifestfile ) ~= 0
    dependencies.internal.graph.write( results, manifestfile );
end


if ~analyzeUnsavedModels
    i_checkForUnsavedChanges( files );
end

end


function i_checkWritable( file )
[ fid, errorMessage ] = fopen( file, 'w' );
if fid ==  - 1
    error( message( "SimulinkDependencyAnalysis:Generate:CannotWriteManifest", errorMessage ) );
end
fclose( fid );
end


function depfile = i_findDepFile( model )
[ folder, name ] = fileparts( model );
depnode = dependencies.internal.graph.Node.createFileNode( fullfile( folder, name + ".smd" ) );
if depnode.Resolved
    depfile = depnode.Path;
else
    depfile = char.empty( 1, 0 );
end
end


function i_checkForUnsavedChanges( files )
allModels = Simulink.allBlockDiagrams;
dirtyModels = allModels( bdIsDirty( allModels ) );
for model = dirtyModels'
    path = get_param( model, "filename" );
    if ismember( path, files )
        warning( message( "SimulinkDependencyAnalysis:Engine:UnsavedModelsInFileDepAnalysis", path ) );
    end
end
end
