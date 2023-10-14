classdef EvolutionReporter < evolutions.internal.report.DesignEvolutionReporter

    properties

        Object{ mustBeInstanceOf( 'evolutions.model.EvolutionInfo', Object ) } = [  ];
        ParentObj{ mustBeInstanceOf( 'evolutions.model.EvolutionTreeInfo', ParentObj ) } = [  ];
        ReportTempDir = '';

        IncludeEvolutionNameHeading{ mustBeLogical } = true;
        IncludeEvolutionFileTable{ mustBeLogical } = true;
        IncludeEvolutionParent{ mustBeLogical } = true;
        IncludeEvolutionChildren{ mustBeLogical } = true;
        IncludeEvolutionDetailsTable{ mustBeLogical } = true;
        IncludeEvolutionArtifactHyperlinks{ mustBeLogical } = true;
        IncludeEvolutionBackToEvolutionTreeHyperlink{ mustBeLogical } = true;

    end



    methods ( Access = protected, Hidden )

        result = openImpl( report, impl, varargin )
    end

    methods

        function h = EvolutionReporter( nameValueArgs )
            arguments
                nameValueArgs.Object = [  ];
                nameValueArgs.ParentObj = [  ];
                nameValueArgs.ReportTempDir = tempdir;

                nameValueArgs.TemplateName = "DesignEvolutionReporter";

                nameValueArgs.IncludeEvolutionNameHeading = true;
                nameValueArgs.IncludeEvolutionFileTable = true;
                nameValueArgs.IncludeEvolutionParent = true;
                nameValueArgs.IncludeEvolutionChildren = true;
                nameValueArgs.IncludeEvolutionDetailsTable = true;
                nameValueArgs.IncludeEvolutionArtifactHyperlinks = true;
                nameValueArgs.IncludeEvolutionBackToEvolutionTreeHyperlink = true;

            end

            nameValuePairs = namedargs2cell( nameValueArgs );
            h = h@evolutions.internal.report.DesignEvolutionReporter( nameValuePairs{ : } );

            h.Object = nameValueArgs.Object;
            h.ParentObj = nameValueArgs.ParentObj;
            h.ReportTempDir = nameValueArgs.ReportTempDir;
            h.TemplateName = nameValueArgs.TemplateName;

        end

        function set.Object( h, value )
            h.Object = value;
        end


        function content = getEvolutionNameHeading( h, ~ )
            content = [  ];
            if h.IncludeEvolutionNameHeading

                testObj = h.Object;

                heading = mlreportgen.dom.Heading4( testObj.getName );

                append( heading, mlreportgen.dom.LinkTarget( testObj.Id ) );
                heading.StyleName = 'StyleName_EvolutionNameHeading';
                content = [ content, { heading } ];
            end
        end


        function content = getEvolutionFileTable( h, ~ )
            content = [  ];
            if h.IncludeEvolutionFileTable


                evolutionInfos = contentEvolutionFileTable( h );


                evolutionFileTable = mlreportgen.dom.FormalTable(  );
                evolutionFileTableHeader = mlreportgen.dom.TableRow(  );
                append( evolutionFileTableHeader, mlreportgen.dom.TableHeaderEntry( 'Files' ) );
                append( evolutionFileTableHeader, mlreportgen.dom.TableHeaderEntry( 'Classification' ) );
                append( evolutionFileTable.Header, evolutionFileTableHeader );
                for k = 1:numel( evolutionInfos.evolutionArtifacts )
                    fileTableRow = mlreportgen.dom.TableRow(  );
                    if ~isempty( evolutionInfos.evolutionArtifacts( k ) )
                        fileTableEntry = mlreportgen.dom.TableEntry(  );


                        if h.IncludeEvolutionArtifactHyperlinks
                            append( fileTableEntry, mlreportgen.dom.InternalLink( evolutionInfos.evolutionArtifactsId{ k },  ...
                                evolutionInfos.evolutionsArtifactFileName{ k } ) );
                        elseif ~h.IncludeEvolutionArtifactHyperlinks
                            append( fileTableEntry, evolutionInfos.evolutionsArtifactFileName{ k } );
                        end

                        append( fileTableRow, fileTableEntry );

                        append( fileTableRow, mlreportgen.dom.TableEntry( evolutionInfos.evolutionsArtifactClassification{ k } ) );

                        append( evolutionFileTable, fileTableRow );
                    else
                        append( fileTableRow, mlreportgen.dom.TableEntry( '-' ) );
                        append( fileTableRow, mlreportgen.dom.TableEntry( '-' ) );
                        append( evolutionFileTable, fileTableRow );
                    end
                end
                evolutionFileTable.StyleName = 'StyleName_EvolutionFileTable';
                evolutionFileTable = customizeTableWidthsForTable( h, evolutionFileTable, 50 );
                content = [ content, { evolutionFileTable } ];
            end
        end

        function evolutionInfos = contentEvolutionFileTable( h )
            testObj = h.Object;

            [ bfis, evolutionInfos.evolutionArtifacts ] = evolutions.internal.utils ...
                .getBaseToArtifactsKeyValues( testObj );

            evolutionInfos.evolutionArtifactsId = evolutionInfos.evolutionArtifacts;

            evolutionInfos.projectFiles = testObj.Project.Files;


            for afiIdx = 1:numel( evolutionInfos.evolutionArtifacts )
                if ~isempty( evolutionInfos.evolutionArtifacts( afiIdx ) )


                    afi = evolutions.internal.artifactserver.getArtifactObject ...
                        ( h.ParentObj.ArtifactRootFolder, bfis( afiIdx ), testObj );
                    evolutionInfos.evolutionsArtifactFileName{ afiIdx } = afi.File;


                    for projFileIdx = 1:length( evolutionInfos.projectFiles )
                        [ ~, pFiName, pFiEtxn ] = fileparts( evolutionInfos.projectFiles( projFileIdx ).Path );
                        evolutionInfos.projectFileName{ projFileIdx } = [ char( pFiName ), char( pFiEtxn ) ];

                        if ~isempty( evolutionInfos.projectFiles( projFileIdx ).Labels ) ...
                                && evolutionInfos.evolutionsArtifactFileName{ afiIdx }( 1 ) == evolutionInfos.projectFileName{ projFileIdx }( 1 )
                            evolutionInfos.evolutionsArtifactClassification{ afiIdx } = evolutionInfos.projectFiles( projFileIdx ).Labels.Name;
                            break ;
                        else
                            evolutionInfos.evolutionsArtifactClassification{ afiIdx } = '-';
                        end

                    end

                else
                    evolutionInfos.evolutionsArtifactFileName{ afiIdx } = [  ];
                end
            end




            if ~isempty( evolutionInfos.evolutionArtifactsId{ afiIdx } ) &&  ...
                    length( evolutionInfos.evolutionsArtifactClassification ) ~= afiIdx
                evolutionInfos.evolutionsArtifactClassification{ afiIdx } = [  ];
            end
        end


        function content = getEvolutionParent( h, ~ )
            content = [  ];
            if h.IncludeEvolutionParent

                testObj = h.Object;
                heading = mlreportgen.dom.Heading4( 'Parent' );
                content = [ content, { heading } ];
                heading.StyleName = 'StyleName_EvolutionParentHeading';

                if ~isempty( testObj.Parent )
                    para = mlreportgen.dom.Paragraph( mlreportgen.dom.InternalLink( testObj.Parent.Id, testObj.Parent.getName ) );
                    para.StyleName = 'StyleName_EvolutionParentParagraph';
                else
                    para = mlreportgen.dom.Paragraph( '-' );
                    para.StyleName = 'StyleName_EvolutionParentParagraph';
                end
                content = [ content, { para } ];
            end
        end

        function content = getEvolutionChildren( h, ~ )
            content = [  ];
            if h.IncludeEvolutionChildren

                testObj = h.Object;
                heading = mlreportgen.dom.Heading4( 'Children' );
                content = [ content, { heading } ];
                heading.StyleName = 'StyleName_EvolutionChildrenHeading';




                evolutionChildrenHyperlinksTable = mlreportgen.dom.Table(  );
                if ~isempty( testObj.Children )
                    for k = 1:numel( testObj.Children )
                        fileTableRow = mlreportgen.dom.TableRow(  );
                        fileTableEntry = mlreportgen.dom.TableEntry(  );
                        if ~testObj.Children( k ).IsWorking
                            append( fileTableEntry, mlreportgen.dom.InternalLink( testObj.Children( k ).Id, testObj.Children( k ).getName ) );
                            append( fileTableRow, fileTableEntry );
                            append( evolutionChildrenHyperlinksTable, fileTableRow );
                        else
                            append( fileTableEntry, '-' );
                            append( fileTableRow, fileTableEntry );
                            append( evolutionChildrenHyperlinksTable, fileTableRow );
                        end
                    end
                else
                    fileTableRow = mlreportgen.dom.TableRow(  );
                    fileTableEntry = mlreportgen.dom.TableEntry(  );
                    append( fileTableEntry, '-' );
                    append( fileTableRow, fileTableEntry );
                    append( evolutionChildrenHyperlinksTable, fileTableRow );
                end

                evolutionChildrenHyperlinksTable.StyleName = 'StyleName_EvolutionChildrenHyperlinksTable';
                content = [ content, { evolutionChildrenHyperlinksTable } ];
            end
        end

        function content = getEvolutionDetailsTable( h, ~ )
            content = [  ];
            if h.IncludeEvolutionDetailsTable

                testObj = h.Object;

                heading = mlreportgen.dom.Heading4( 'Details' );
                heading.StyleName = 'StyleName_EvolutionDetailsHeading';
                content = [ content, { heading } ];

                if ~isempty( h.getDescription )
                    evolutionInfos.description = h.getDescription;
                else
                    evolutionInfos.description = '-';
                end

                evoBottomDescriptionTable = mlreportgen.dom.Table( { 'Description: '; ...
                    evolutionInfos.description } );
                evoBottomDescriptionTable.StyleName = 'StyleName_EvolutionBottomDescriptionTable';
                evoBottomDescriptionTable.entry( 1, 1 ).Style = { mlreportgen.dom.Bold( true ) };

                evoBottomInfoTable = mlreportgen.dom.Table( [ { 'Created On: ', string( testObj.Created ) }; ...
                    { 'Created By: ', h.getAuthor }; ...
                    { 'Last Update: ', h.getUpdated }; ...
                    { 'Updated By: ', h.getAuthor } ] );


                evoBottomInfoTable.StyleName = 'StyleName_EvolutionBottomInfoTable';
                for i = 1:4
                    evoBottomInfoTable.entry( i, 1 ).Style = { mlreportgen.dom.Bold( true ) };
                end
                evoBottomInfoTable = customizeTableWidthsForTable( h, evoBottomInfoTable, 35 );


                evoDetailsTable = mlreportgen.dom.Table( { evoBottomDescriptionTable, evoBottomInfoTable } );
                evoDetailsTable.StyleName = 'StyleName_EvolutionDetailsTable';
                evoDetailsTable = customizeTableWidthsForTable( h, evoDetailsTable, 50 );

                content = [ content, { evoDetailsTable } ];
            end
        end

        function content = getEvolutionBackToEvolutionTreeHyperlink( h, ~ )
            content = [  ];
            if h.IncludeEvolutionBackToEvolutionTreeHyperlink


                if ~isempty( h.ParentObj )
                    backToEvoTreeInfoLink = mlreportgen.dom.Paragraph( mlreportgen.dom.InternalLink( h.ParentObj.Id,  ...
                        sprintf( '%s%s', 'Back to Evolution Tree: ', h.ParentObj.getName ) ) );
                    backToEvoTreeInfoLink.StyleName = 'StyleName_EvolutionBackToEvolutionTreeHyperlink';
                    content = [ content, { backToEvoTreeInfoLink } ];
                end
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


        function template = createTemplate( templatePath, type )
            path = EvolutionReporter.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function customizeReporter( toClasspath )
            mlreportgen.report.ReportForm.customizeClass(  ...
                toClasspath, "EvolutionReporter" );
        end

    end
end



function mustBeLogical( varargin )
mlreportgen.report.validators.mustBeLogical( varargin{ : } );
end

function mustBeInstanceOf( varargin )
mlreportgen.report.validators.mustBeInstanceOf( varargin{ : } );
end

