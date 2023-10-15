classdef ReferenceDiagramInterface < handle


















    methods ( Static )
        function saveReferencedModel( parentDiagram, blockH )







            modelName = get_param( blockH, "ModelName" );
            info = struct(  ...
                "ReferenceName", modelName,  ...
                "Name", sprintf( "%s (%s)", get_param( blockH, "Name" ), modelName ),  ...
                "ESID", Simulink.ID.getSID( blockH ) );
            parentDiagram.addReferencedModel( info );
            parentDiagram.Model.setHasReferencedModels( true );
        end

        function saveReferencedSubsystem( parentDiagram, blockH )







            referencedSubsystem = get_param( blockH, "ReferencedSubsystem" );
            info = struct(  ...
                "ReferenceName", referencedSubsystem,  ...
                "Name", sprintf( "%s (%s)", get_param( blockH, "Name" ), referencedSubsystem ),  ...
                "ESID", Simulink.ID.getSID( blockH ) );
            parentDiagram.addReferencedSubsystem( info );
            parentDiagram.Model.setHasReferencedSubsystems( true );
        end

        function referencedDiagram = loadReferencedModel( parentDiagram, link, options )

















            arguments
                parentDiagram
                link
                options.Force logical = false;
            end
            referencedDiagram =  ...
                slreportgen.webview.internal.ReferenceDiagramInterface.loadReference( parentDiagram, link, options );
            referencedDiagram.setClassName( "Simulink.ModelReference" );
            referencedDiagram.setESID( link.ESID );
            referencedDiagram.setIsModelReference( true );
            referencedDiagram.setDisplayIcon( "$matlabroot" + "\toolbox\shared\dastudio\resources\MdlRefBlockIcon.png" );
        end

        function referencedDiagram = loadReferencedSubsystem( parentDiagram, link, options )


            arguments
                parentDiagram
                link
                options.Force logical = false;
            end

            [ referencedDiagram, referencedModel ] =  ...
                slreportgen.webview.internal.ReferenceDiagramInterface.loadReference( parentDiagram, link, options );



            prefixSID = regexprep( referencedDiagram.Parent.SID, ":[^:]*$", "" );
            suffixSID = regexprep( link.ESID, "[^:]*:", "" );
            sid = prefixSID + ":" + suffixSID;
            referencedDiagram.setESID( sid );
            referencedDiagram.setSID( sid );
            referencedDiagram.setClassName( "Simulink.SubSystem" );
            referencedDiagram.setDisplayIcon( "$matlabroot" + "\toolbox\shared\dastudio\resources\SubsystemReference_16.png" );
            referencedDiagram.setIsSubsystemReference( true );

            diagrams = referencedModel.Diagrams;
            for i = 2:numel( diagrams )
                diagram = diagrams( i );
                suffixSID = strrep( diagram.RSID, referencedDiagram.RSID, "" );
                sid = referencedDiagram.SID + suffixSID;
                diagram.setSID( sid );
                diagram.setESID( sid );
            end

            for i = 1:numel( diagrams )


                diagram = diagrams( i );
                diagram.setSlProxyObject( [  ] );
                diagram.setHandle( [  ] );
                diagram.setEHandle( [  ] );
            end
        end
    end

    methods ( Static, Access = private )
        function [ referencedDiagram, referencedModel ] = loadReference( parentDiagram, link, options )

            modelBuilder = slreportgen.webview.internal.ModelBuilder(  );
            referencedModel = modelBuilder.build( link.ReferenceName,  ...
                "Force", options.Force,  ...
                "Cache", parentDiagram.Model.isBuiltWithCacheEnabled(  ) );
            referencedDiagram = referencedModel.RootDiagram;
            referencedDiagram.setParent( parentDiagram );
            referencedDiagram.setName( link.Name );
            referencedDiagram.setDisplayLabel( regexprep( link.Name, "\s", " " ) );

            parentModel = parentDiagram.Model;
            referenceDiagrams = referencedModel.Diagrams;
            for i = 1:numel( referenceDiagrams )
                diagram = referenceDiagrams( i );
                diagram.setModel( parentModel );
                diagram.setEHID( GLUE2.HierarchyId.empty(  ) );
                diagram.setHID( GLUE2.HierarchyId.empty(  ) );
                diagram.setRSID( diagram.SID );
                parentModel.addDiagram( diagram );
            end

            for i = 1:numel( referencedModel.Parts )
                parentModel.addPart( referencedModel.Parts( i ) );
            end
        end
    end
end

