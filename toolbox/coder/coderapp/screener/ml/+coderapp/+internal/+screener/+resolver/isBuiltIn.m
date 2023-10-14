function result = isBuiltIn( filePath )

arguments
    filePath( 1, 1 )string
end
result = ~isfile( filePath );

end


