classdef DataDictionaryProvider < matlab.internal.project.unsavedchanges.LoadedFileProvider




    methods ( Access = public )
        function loadedFiles = getLoadedFiles( ~ )
            loadedFiles = matlab.internal.project.unsavedchanges.LoadedFile.empty( 1, 0 );
            paths = Simulink.data.dictionary.getOpenDictionaryPaths(  );
            for n = 1:numel( paths )
                try %#ok<TRYNC> throws if the dictionary doesn't exist on disk
                    loadedFiles( end  + 1 ) = i_makeLoadedFile( paths{ n } );%#ok<AGROW>
                end
            end
        end

        function save( ~, file )
            arguments
                ~
                file( 1, 1 )string
            end

            if ismember( file, Simulink.data.dictionary.getOpenDictionaryPaths(  ) )
                dict = Simulink.data.dictionary.open( file );
                dict.saveChanges;
            end
        end

        function open( ~, file )
            arguments
                ~
                file( 1, 1 )string
            end

            dict = Simulink.data.dictionary.open( file );
            dict.show;
        end

        function discard( ~, file )
            arguments
                ~
                file( 1, 1 )string
            end

            if ismember( file, Simulink.data.dictionary.getOpenDictionaryPaths(  ) )
                [ ~, name, ext ] = fileparts( file );
                Simulink.data.dictionary.closeAll( name + ext, '-discard' );
            end
        end

        function autoClose = isAutoCloseEnabled( ~ )
            autoClose = true;
        end
    end
end

function file = i_makeLoadedFile( path )
dataDict = Simulink.data.dictionary.open( path );

if dataDict.HasUnsavedChanges
    props = matlab.internal.project.unsavedchanges.Property.Unsaved;
else
    props = matlab.internal.project.unsavedchanges.Property.empty;
end

file = matlab.internal.project.unsavedchanges.LoadedFile( path, props );
end
