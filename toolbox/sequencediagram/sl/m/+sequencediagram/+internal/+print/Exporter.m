classdef Exporter < handle




















    properties ( SetAccess = immutable, GetAccess = private )
        ModelName
        SequenceDiagramName
    end

    methods
        function this = Exporter( modelName, sequenceDiagramName )
            arguments
                modelName( 1, : )char
                sequenceDiagramName( 1, : )char
            end

            this.ModelName = modelName;
            this.SequenceDiagramName = sequenceDiagramName;
        end

        function export( this, fileName, options )

            arguments
                this
                fileName( 1, : )char
                options.ImageFormat( 1, : )char = sequencediagram.internal.print.Exporter.getFileFormat( fileName );
            end

            isPDF = strcmpi( options.ImageFormat, 'pdf' );
            if ( isPDF )
                this.exportToPDF( fileName );
            else
                this.exportToRaster( fileName, options.ImageFormat );
            end
        end

        function img = getImage( this )




            editorInterface = this.createEditorInterface(  );
            img = editorInterface.getImage(  );
        end
    end

    methods ( Access = private )
        function editorInterface = createEditorInterface( this )
            editorInterface = sequencediagram.internal.print.internal.EditorInterface( this.ModelName, this.SequenceDiagramName );
        end

        function exportToPDF( this, fullFileName )
            editorInterface = this.createEditorInterface(  );
            editorInterface.saveToPdf( fullFileName );
        end

        function exportToRaster( this, fullFileName, format )
            img = this.getImage(  );
            imwrite( img, fullFileName, format );
        end
    end

    methods ( Static, Access = private )
        function ext = getFileFormat( filename )
            [ ~, ~, ext ] = fileparts( filename );
            if ~isempty( ext )
                ext = ext( 2:end  );
            end
        end
    end
end

