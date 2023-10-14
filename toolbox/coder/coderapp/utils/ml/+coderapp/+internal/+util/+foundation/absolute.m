function result = absolute( aFile )

arguments
    aFile( 1, 1 )string
end

if isAbsolute( aFile )
    result = aFile;
else
    result = fullfile( pwd, aFile );
end

if exist( result, 'file' )
    try
        result = builtin( "_canonicalizepath", result );
    catch
    end
end
end

function result = isAbsolute( aFile )
arguments
    aFile( 1, 1 )string
end

result = aFile == matlab.io.internal.filesystem.absolutePath( aFile );
end



