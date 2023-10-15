function paths = getLoadedFiles( properties )

arguments
    properties( 1, : )string = string.empty;
end

files = matlab.internal.project.unsavedchanges.getLoadedFiles( properties );
if isempty( files )
    paths = {  };
else
    paths = cellstr( [ files.Path ] );
end
end
