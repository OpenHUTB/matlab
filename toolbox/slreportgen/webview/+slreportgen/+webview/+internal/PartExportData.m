classdef PartExportData < handle



















    properties ( SetAccess = private )
        Part slreportgen.webview.internal.Part
    end

    properties



        DiagramsURL string = string.empty(  );




        SystemView string






        OptionalViews struct
    end

    methods
        function this = PartExportData( part )
            this.Part = part;
        end

        function write( this, writer )



            arguments
                this
                writer slreportgen.webview.JSONWriter
            end

            part = this.Part;
            diagram = part.RootDiagram;

            writer.beginObject(  );

            writer.name( "hid" );
            writer.value( diagram.ExportData.ID );

            writer.name( "sid" );
            writer.value( diagram.SID );

            writer.name( "name" );
            writer.value( diagram.Name );

            writer.name( "fullname" );
            writer.value( diagram.FullName );

            writer.name( "label" );
            writer.value( diagram.DisplayLabel );

            writer.name( "parent" );
            if ~isempty( diagram.Parent )
                writer.value( diagram.Parent.ExportData.ID );
            else
                writer.value( 0 );
            end

            writer.name( "descendantIDs" );
            writer.beginArray(  );
            partDiagrams = part.Diagrams;
            for i = 1:numel( partDiagrams )
                partDiagram = partDiagrams( i );
                if ( partDiagrams( i ) ~= diagram ) ...
                        && partDiagram.ExportData.IsPartOfExportHierarchy
                    writer.value( partDiagram.ExportData.ID );
                end
            end
            writer.endArray(  );

            writer.name( "descendantsURL" );
            writer.value( this.DiagramsURL );

            writer.name( "sysViewURL" )
            writer.value( this.SystemView );

            if ~isempty( this.OptionalViews )
                writer.name( "optViewURLs" );
                writer.beginObject(  );
                viewIDs = fieldnames( this.OptionalViews );
                for i = 1:numel( viewIDs )
                    viewID = viewIDs{ i };
                    writer.name( viewID );
                    writer.value( this.OptionalViews.( viewID ) );
                end
                writer.endObject(  );
            end

            writer.endObject(  );
        end
    end
end


