classdef EvolutionTreeReporter < evolutions.internal.report.DesignEvolutionReporter

    properties

        Object{ mustBeInstanceOf( 'evolutions.model.EvolutionTreeInfo', Object ) } = [  ];
        ReportTempDir = '';

        IncludeEvolutionTreeNameHeading{ mustBeLogical } = true;
        IncludeEvolutionTreeTopInfoTable{ mustBeLogical } = true;
        IncludeEvolutionTreePlot{ mustBeLogical } = true;
        IncludeEvolutionTreeEvolutionHyperlinks{ mustBeLogical } = true;
        IncludeEvolutionTreeDetailsTable{ mustBeLogical } = true;

    end



    methods ( Access = protected, Hidden )

        result = openImpl( report, impl, varargin )
    end


    methods
        function h = EvolutionTreeReporter( nameValueArgs )

            arguments
                nameValueArgs.Object = [  ];
                nameValueArgs.ReportTempDir = tempdir;

                nameValueArgs.TemplateName = "DesignEvolutionTreeReporter";

                nameValueArgs.IncludeEvolutionTreeNameHeading = true;
                nameValueArgs.IncludeEvolutionTreeTopInfoTable = true;
                nameValueArgs.IncludeEvolutionTreePlot = true;
                nameValueArgs.IncludeEvolutionTreeEvolutionHyperlinks = true;
                nameValueArgs.IncludeEvolutionTreeDetailsTable = true;

            end

            nameValuePairs = namedargs2cell( nameValueArgs );
            h = h@evolutions.internal.report.DesignEvolutionReporter( nameValuePairs{ : } );

            h.Object = nameValueArgs.Object;
            h.ReportTempDir = nameValueArgs.ReportTempDir;
            h.TemplateName = nameValueArgs.TemplateName;

        end

        function set.Object( h, value )
            h.Object = value;
        end


        function content = getEvolutionTreeNameHeading( h, ~ )
            content = [  ];
            if h.IncludeEvolutionTreeNameHeading

                testObj = h.Object;
                heading = mlreportgen.dom.Heading4( testObj.getName );

                append( heading, mlreportgen.dom.LinkTarget( testObj.Id ) );
                heading.StyleName = 'StyleName_EvolutionTreeNameHeading';
                content = [ content, { heading } ];
            end
        end

        function content = getEvolutionTreeTopInfoTable( h, ~ )
            content = [  ];
            if h.IncludeEvolutionTreeTopInfoTable

                testObj = h.Object;

                evolutionTreeInfos.evolutionTreeName = testObj.getName;

                evolutionTreeInfos.evolutionTreeAuthor = h.getAuthor;

                evoTreeTopInfoTable = mlreportgen.dom.Table( [ { 'Design Tree: ', evolutionTreeInfos.evolutionTreeName }; ...
                    { 'Created By: ', evolutionTreeInfos.evolutionTreeAuthor }; ...
                    { 'Report Date: ', string( datetime(  ) ) } ] );

                evoTreeTopInfoTable.StyleName = 'StyleName_EvolutionTreeTopInfoTable';
                for i = 1:3
                    evoTreeTopInfoTable.entry( i, 1 ).Style = { mlreportgen.dom.Bold( true ) };
                end
                evoTreeTopInfoTable = customizeTableWidthsForTable( h, evoTreeTopInfoTable, 35 );
                content = [ content, { evoTreeTopInfoTable } ];

            end
        end


        function content = getEvolutionTreePlot( h, ~ )
            content = [  ];
            if h.IncludeEvolutionTreePlot

                testObj = h.Object;
                heading = mlreportgen.dom.Heading4( 'Evolution Tree' );
                heading.StyleName = 'StyleName_EvolutionTreePlotHeading';
                content = [ content, { heading } ];


                imageTempDir = exportTreePlot( h );


                imageHyperlink = mlreportgen.dom.Paragraph(  ...
                    mlreportgen.dom.ExternalLink( fullfile( '.', 'ExternalLinks', 'Images', sprintf( '%s%s', testObj.getName, '.png' ) ),  ...
                    'Open image outside this document' ) );

                imageHyperlink.StyleName = 'StyleName_EvolutionTreePlotImageHyperlink';
                content = [ content, { imageHyperlink } ];


                evoTreeImg = mlreportgen.dom.Image( fullfile( imageTempDir, sprintf( '%s%s', testObj.getName, '.png' ) ) );
                evoTreeImg.Style = [ evoTreeImg.Style, { mlreportgen.dom.ScaleToFit } ];
                evoTreeImg.StyleName = 'StyleName_EvolutionTreePlotImage';




                imageContainerDiv = mlreportgen.dom.Container( 'div' );
                append( imageContainerDiv, evoTreeImg );
                imageContainerDiv.StyleName = 'StyleName_EvolutionTreeImageContainerDiv';
                content = [ content, { imageContainerDiv } ];

            end
        end

        function imageTempDir = exportTreePlot( h )
            testObj = h.Object;
            tp = evolutions.internal.report.EvolutionTreePlotter( testObj.EvolutionManager.RootEvolution );

            imageTempDir = fullfile( h.ReportTempDir, 'ExternalLinks', 'Images' );
            mkdir( imageTempDir );
            exportgraphics( tp.TreeAxes,  ...
                fullfile( imageTempDir, sprintf( '%s%s', testObj.getName, '.png' ) ) );
        end


        function content = getEvolutionTreeEvolutionHyperlinks( h, ~ )
            content = [  ];
            if h.IncludeEvolutionTreeEvolutionHyperlinks

                evolutionTreeInfos.evolutionSequential = sortEvolutionsSequential( h );


                evolutionTreeEvolutionHyperlinks = mlreportgen.dom.Table(  );
                for j = 1:numel( evolutionTreeInfos.evolutionSequential )
                    fileTableRow = mlreportgen.dom.TableRow(  );
                    fileTableEntry = mlreportgen.dom.TableEntry(  );
                    append( fileTableEntry, mlreportgen.dom.InternalLink( evolutionTreeInfos.evolutionSequential( j ).Id,  ...
                        sprintf( '%s%s', 'Go to: ', evolutionTreeInfos.evolutionSequential( j ).getName ) ) );
                    append( fileTableRow, fileTableEntry );
                    append( evolutionTreeEvolutionHyperlinks, fileTableRow );

                end
                evolutionTreeEvolutionHyperlinks.StyleName = 'StyleName_EvolutionTreeEvolutionHyperlinks';
                content = [ content, { evolutionTreeEvolutionHyperlinks } ];

            end
        end

        function evolutionsSequential = sortEvolutionsSequential( h )
            testObj = h.Object;
            evolutionTreeIterator = evolutions.internal.tree.EvolutionTreeIterator( testObj.EvolutionManager.RootEvolution );
            count = 1;
            evolutionsSequential = testObj.EvolutionManager.Infos.empty(  );
            while ~isempty( evolutionTreeIterator.current )
                if ~evolutionTreeIterator.current.IsWorking
                    evolutionsSequential( count ) = evolutionTreeIterator.current;
                    count = count + 1;
                end
                evolutionTreeIterator.next;
            end
            evolutionsSequential = flip( evolutionsSequential );
        end


        function content = getEvolutionTreeDetailsTable( h, ~ )
            content = [  ];
            if h.IncludeEvolutionTreeDetailsTable

                testObj = h.Object;

                heading = mlreportgen.dom.Heading4( 'Details' );
                heading.StyleName = 'StyleName_EvolutionTreeDetailsHeading';
                content = [ content, { heading } ];


                if ~isempty( h.getDescription )
                    evolutionTreeInfos.evolutionTreeDescription = h.getDescription;
                else
                    evolutionTreeInfos.evolutionTreeDescription = '-';
                end

                evolutionTreeInfos.evolutionTreeAuthor = h.getAuthor;
                evolutionTreeInfos.evolutionTreeCreatedOn = string( testObj.Created );
                evolutionTreeInfos.evolutionTreeUpdatedOn = h.getUpdated;
                evolutionTreeInfos.projectName = testObj.Project.Name;

                evoTreeBottomDescriptionTable = mlreportgen.dom.Table( { 'Description: '; ...
                    evolutionTreeInfos.evolutionTreeDescription } );
                evoTreeBottomDescriptionTable.StyleName = 'StyleName_EvolutionTreeBottomDescriptionTable';
                evoTreeBottomDescriptionTable.entry( 1, 1 ).Style = { mlreportgen.dom.Bold( true ) };

                evoTreeBottomInfoTable = mlreportgen.dom.Table( [ { 'Project: ', evolutionTreeInfos.projectName }; ...
                    { 'Created On: ', evolutionTreeInfos.evolutionTreeCreatedOn }; ...
                    { 'Created By: ', evolutionTreeInfos.evolutionTreeAuthor }; ...
                    { 'Last Update: ', evolutionTreeInfos.evolutionTreeUpdatedOn }; ...
                    { 'Updated By: ', evolutionTreeInfos.evolutionTreeAuthor } ] );

                evoTreeBottomInfoTable.StyleName = 'StyleName_EvolutionTreeBottomInfoTable';
                for i = 1:5
                    evoTreeBottomInfoTable.entry( i, 1 ).Style = { mlreportgen.dom.Bold( true ) };
                end
                evoTreeBottomInfoTable = customizeTableWidthsForTable( h, evoTreeBottomInfoTable, 35 );

                evoTreeDetailsTable = mlreportgen.dom.Table( { evoTreeBottomDescriptionTable, evoTreeBottomInfoTable } );
                evoTreeDetailsTable.StyleName = 'StyleName_EvolutionTreeDetailsTable';
                evoTreeDetailsTable = customizeTableWidthsForTable( h, evoTreeDetailsTable, 50 );

                content = [ content, { evoTreeDetailsTable } ];
            end


        end


        function author = getAuthor( h )
            author = h.Object.Author;
        end

        function description = getDescription( h )
            description = h.Object.Description;
        end

        function updated = getUpdated( h )
            updated = char( h.Object.Updated );
        end

    end


    methods ( Static )
        function path = getClassFolder(  )
            [ path ] = fileparts( mfilename( 'fullpath' ) );
        end

        function createTemplate( templatePath, type )
            path = EvolutionTreeReporter.getClassFolder(  );
            mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function customizeReporter( toClasspath )
            mlreportgen.report.ReportForm.customizeClass(  ...
                toClasspath, "EvolutionTreeReporter" );
        end

    end
end



function mustBeLogical( varargin )
mlreportgen.report.validators.mustBeLogical( varargin{ : } );
end

function mustBeInstanceOf( varargin )
mlreportgen.report.validators.mustBeInstanceOf( varargin{ : } );
end


