function result = isAbsolute( file )
arguments
    file{ mustBeText }
end

if ispc(  )
    file = cellstr( strrep( file, '/', '\' ) );
    result = ~cellfun( 'isempty', regexp( file, '^[a-zA-Z]:\\', 'once' ) ) | startsWith( file, '\\' );
else
    result = startsWith( file, '/' );
end
end


