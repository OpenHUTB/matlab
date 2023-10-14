function project = extractProject( archive, path )

arguments
    archive( 1, 1 )string{ mustBeNonzeroLengthText };
    path( 1, 1 )string{ i_mustBeMissingNotOnDiskOrAnEmptyFolder } = missing;
end

import matlab.internal.project.archive.extractArchive;
import matlab.internal.project.api.makePathAbsoluteAndNormalize;

archive = makePathAbsoluteAndNormalize( i_ensureFileWithExtensionNonOmitted( archive ) );
if ~ismissing( path )
    path = makePathAbsoluteAndNormalize( path );
end

[ ~, project ] = extractArchive( archive, ExtractionFolder = path, ExtractToSubFolder = false );
end

function i_ensureFolderIsEmpty( folder )
d = dir( folder );
if length( d ) > 2
    error( message( "MATLAB:project:api:ExtractionFolderMustBeEmpty" ) );
end
end

function i_mustBeMissingNotOnDiskOrAnEmptyFolder( path )
if ismissing( path )
    return ;
end
mustBeNonzeroLengthText( path );
switch exist( path, 'file' )
    case 0
        return ;
    case 7
        i_ensureFolderIsEmpty( path );
        return ;
    otherwise
        error( message( "MATLAB:project:api:ExtractionFolderMustNotBeFile" ) );
end
end

function fileWithExt = i_findFileWithMlprojExtension( file )
ignoreCase = ispc;
if ignoreCase
    candidates = dir( file + ".*" );
    [ ~, ~, ext ] = fileparts( { candidates.name } );
    matching = strcmpi( ext, ".mlproj" );
    candidates = candidates( matching );
    if isempty( candidates )
        fileWithExt = file;
    else
        selected = candidates( 1 );
        fileWithExt = fullfile( selected.folder, selected.name );
    end
else
    fileWithExt = file + ".mlproj";
end

end

function file = i_ensureFileWithExtensionNonOmitted( file )
if isfile( file )
    return ;
end

fileWithExt = i_findFileWithMlprojExtension( file );
if isfile( fileWithExt )
    file = fileWithExt;
else
    mustBeFile( file );
end
end

