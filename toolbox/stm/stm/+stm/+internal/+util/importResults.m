function resultSets = importResults( filePath, uniqueImport, partialLoad )
arguments
    filePath( 1, 1 )string;
    uniqueImport( 1, 1 )logical;
    partialLoad( 1, 1 )logical;
end






[ dirPath, ~, ext ] = fileparts( filePath );
if ext == ""
    filePath = filePath + ".mldatx";
end


if dirPath == ""
    fullPath = which( filePath );
    if fullPath ~= ""
        filePath = fullPath;
    end
end

mustBeFile( filePath );


desc = matlabshared.mldatx.internal.getDescription( filePath );
if ~strcmp( desc, message( 'stm:general:ResultFileDescription' ).getString(  ) )

    error( message( 'stm:general:FileCouldNotBeOpenedAsResult' ) );
end


if ( partialLoad && ~uniqueImport )
    error( message( 'stm:general:PartialLoadNotSupported' ) );
end

if ( uniqueImport )
    ids = stm.internal.importUniqueResultSets( filePath, partialLoad );
else
    ids = stm.internal.importResultSets( filePath );
end

resultSets = sltest.internal.getResultSets( ids );
end

