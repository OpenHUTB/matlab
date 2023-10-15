classdef EditorDiagramExporter < diagram.editor.print.Exporter

    properties
        modelName( 1, 1 )string
    end

    properties ( Access = private )
        modelHandle( 1, 1 )double
    end

    methods
        function obj = EditorDiagramExporter( modelHandle, options )
            arguments
                modelHandle( 1, 1 )double
                options.Legend( 1, 1 )logical = false
            end

            sltp.internal.EditorDiagramExporter.validateHandle( modelHandle );

            graphEditor = sltp.GraphEditor( modelHandle );
            syntax = graphEditor.syntax(  );

            [ sltpIndexFilename, sltpIndexParams ] = sltp.internal.URLBuilder.getURLInformation( modelHandle );
            sltpIndex = [ sltp.internal.URLBuilder.BaseDirectory,  ...
                sltpIndexFilename ];

            sltpIndexParams( end  + 1 ) = { 'export=1' };

            if ( options.Legend )
                sltpIndexParams( end  + 1 ) = { 'exportLegend=1' };
            end

            obj = obj@diagram.editor.print.Exporter( syntax,  ...
                'AppIndex', sltpIndex,  ...
                'IndexParams', sltpIndexParams );
            obj.modelName = get_param( modelHandle, 'Name' );
            obj.modelHandle = modelHandle;
        end

        function appIndex = getAppIndex( obj )
            appIndex = obj.appIndex;
        end

        function indexParams = getIndexParams( obj )
            indexParams = obj.indexParams;
        end

        function url = getUrl( obj )
            url = obj.generateUrl(  );
        end
    end

    methods ( Static )
        function validateHandle( modelHandle )
            if ( ~ishandle( modelHandle ) )
                msg = 'Simulink:Commands:InvSimulinkObjHandle';
                error( message( msg ) )
            end

            isConfiguredForMds =  ...
                ( strcmp( get_param( modelHandle, 'ConcurrentTasks' ), 'on' ) ) &&  ...
                ( strcmp( get_param( modelHandle, 'ExplicitPartitioning' ), 'on' ) );
            if ( isConfiguredForMds )
                msg = 'SimulinkPartitioning:Config:InvalidModelMds';
                error( message( msg ) )
            end

            if ( bdIsLibrary( modelHandle ) )
                msg = 'SimulinkPartitioning:Config:InvalidModelLibrary';
                error( message( msg ) )
            end

            if ( bdIsSubsystem( modelHandle ) )
                msg = 'SimulinkPartitioning:Config:InvalidModelSubsystemReference';
                error( message( msg ) )
            end
        end
    end
end


