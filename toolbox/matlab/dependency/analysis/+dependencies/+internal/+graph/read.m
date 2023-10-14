function graph = read( file, root )

arguments
    file( 1, 1 )string;
    root( 1, 1 )string = "";
end

i_checkFile( file );

readers = dependencies.internal.Registry.Instance.GraphReaders';
for reader = readers
    if endsWith( file, reader.Extensions )
        try
            graph = reader.read( file, root );
        catch exception
            throw( dependencies.internal.util.wrapException(  ...
                exception,  ...
                "MATLAB:dependency:readwrite:InvalidFileFormat",  ...
                file ) );
        end
        return ;
    end
end

dependencies.internal.util.throwException( "MATLAB:dependency:readwrite:UnknownFileFormat", file );

end


function i_checkFile( file )
if ~dependencies.internal.graph.Node.createFileNode( file ).Resolved
    dependencies.internal.util.throwException( "MATLAB:dependency:readwrite:FileNotFound", file );
end
end

