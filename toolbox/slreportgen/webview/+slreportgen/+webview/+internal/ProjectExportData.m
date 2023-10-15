classdef ProjectExportData < handle























    properties ( SetAccess = private )
        Project slreportgen.webview.internal.Project
    end

    properties





        Version = 3




        HomeHID uint64












        OptionalViews struct




        IconsURL string


        HasInformer logical = false


        HasNotes logical = false


        BaseURL string;
    end

    methods
        function this = ProjectExportData( project )
            this.Project = project;
        end

        function write( this, writer )



            arguments
                this
                writer slreportgen.webview.JSONWriter
            end

            project = this.Project;

            writer.beginObject(  );

            writer.name( "version" );
            writer.value( this.Version );

            writer.name( "baseUrl" );
            writer.value( this.BaseURL );

            writer.name( "homeHid" );
            writer.value( this.HomeHID );

            writer.name( "sections" );
            writer.beginArray(  );
            parts = project.Parts;
            for i = 1:numel( parts )
                parts( i ).ExportData.write( writer );
            end
            writer.endArray(  );

            writer.name( "optViews" );
            writer.beginArray(  );
            for optionalView = this.OptionalViews
                writer.value( optionalView );
            end
            writer.endArray(  );


            writer.name( "display" );
            writer.beginObject(  );
            writer.name( "informer" );
            writer.value( this.HasInformer );
            writer.name( "notes" );
            writer.value( this.HasNotes );
            writer.endObject(  );

            writer.name( "iconsUrl" )
            writer.value( this.IconsURL );

            writer.endObject(  );
        end
    end
end
