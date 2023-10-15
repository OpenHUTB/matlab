function [ originalHeaders, headerGraph ] = getHeaderList( self, options )
arguments
    self( 1, 1 )polyspace.internal.codeinsight.CodeInfo
    options.FilterSystemHeaders( 1, 1 )logical = false
    options.FilterMWIncludes( 1, 1 )logical = false
end




if nargout > 1
    headerGraph = digraph;
end
cUnit = self.AST.Project.Compilations.at( 1 );
srcFiles = cUnit.Files.toArray;
originalHeaders = string( [  ] );
headerFileList = internal.cxxfe.ast.source.SourceFile.empty;
for aFile = srcFiles
    incFiles = getIncludeFilesArray( aFile, 'FilterSystemHeaders', options.FilterSystemHeaders, 'FilterMWIncludes', options.FilterMWIncludes );
    headerFileList = [ headerFileList, incFiles ];%#ok<AGROW>
    originalHeaders = [ originalHeaders, string( { incFiles.WrittenName } ) ];%#ok<AGROW>
end


originalHeaders = unique( originalHeaders, 'stable' );

if nargout > 1
    headerGraph = getHeaderDigraph( headerFileList, 'FilterSystemHeaders', options.FilterSystemHeaders, 'FilterMWIncludes', options.FilterMWIncludes );
end
end


function d = getHeaderDigraph( fileList, options )
arguments
    fileList( 1, : )internal.cxxfe.ast.source.SourceFile
    options.FilterSystemHeaders( 1, 1 )logical = false
    options.FilterMWIncludes( 1, 1 )logical = false
end
d = digraph;
visited = string( [  ] );
    function addEdges( f )
        incFiles = getIncludeFilesArray( f, 'FilterSystemHeaders', options.FilterSystemHeaders, 'FilterMWIncludes', options.FilterMWIncludes );
        if ispc

            currentName = lower( f.WrittenName );
        else
            currentName = f.WrittenName;
        end
        if ~ismember( currentName, visited )
            if ~isempty( incFiles )
                if ispc

                    incFilesNames = lower( { incFiles.WrittenName } );
                else
                    incFilesNames = { incFiles.WrittenName };
                end
                d = d.addedge( currentName, incFilesNames );
            end
            visited( end  + 1 ) = currentName;
            for aIncFile = incFiles
                addEdges( aIncFile );
            end
        end
    end

for aFile = fileList
    addEdges( aFile );
end

d = d.transclosure;
end

function incFiles = getIncludeFilesArray( aFile, options )
arguments
    aFile( 1, 1 )internal.cxxfe.ast.source.SourceFile
    options.FilterSystemHeaders( 1, 1 )logical = false
    options.FilterMWIncludes( 1, 1 )logical = false
end
incFiles = aFile.IncludedFiles.toArray;
if options.FilterSystemHeaders
    incFiles = incFiles( [ incFiles.IsIncludedFromSystemIncludeDir ] == false );
end
if options.FilterMWIncludes
    isNotInMWInc = arrayfun( @( x )~polyspace.internal.codeinsight.CodeInfo.isMWIncludePath( string( x.Path ) ), incFiles );
    incFiles = incFiles( isNotInMWInc );
end
end


