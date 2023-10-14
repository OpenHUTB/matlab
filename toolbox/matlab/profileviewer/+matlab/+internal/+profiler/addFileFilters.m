function addFileFilters( files )

arguments
    files( 1, : )cell
end
cellfun( @( file )iAddFile( file ), files );
end

function iAddFile( file )
if ~isempty( file )
    filePath = which( file );

    if ~any( contains( callstats( 'pffilter' ), filePath ) )
        callstats( 'pffilter', 'add', filePath );
    end
end

end

