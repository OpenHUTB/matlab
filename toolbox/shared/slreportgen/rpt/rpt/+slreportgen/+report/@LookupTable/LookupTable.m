classdef LookupTable < slreportgen.report.Reporter



















































































    properties











        Object{ mustBeLookupTableObject( Object ) } = [  ];






















        DataReporter{ mustBeBaseTable( DataReporter ) } = [  ];










        IncludeTable{ mustBeLogical } = true;







        IncludePlot{ mustBeLogical } = true;






        PlotType{ mustBeMember( PlotType, [ "Surface Plot", "Mesh Plot" ] ) } = "Surface Plot";


















        PlotReporter{ mustBeFigure( PlotReporter ) } = [  ];
















        MaxTableColumns{ mustBeValidMaxSize( MaxTableColumns ) } = Inf;

    end

    properties ( Hidden, Access = public )
        WarnNumberOfTableSlices = 100;
        Content = [  ];
    end

    properties ( Hidden, Access = private )
        m_src = [  ];
        m_xLabel = [  ];
        m_yLabel = [  ];
        m_compilationError = false;


        m_ShouldNumberTableHierarchically = [  ];


        ReportOutputType;
    end

    properties ( Hidden, Constant, Access = private )
        KnownErrorIdentifiers = [ "slreportgen:LUTDimensionMismatch", "slreportgen:UnResolvableExpression" ];
    end

    methods

        function h = LookupTable( varargin )
            if ( nargin == 1 )
                args = [ { 'Object' }, varargin ];
            else
                args = varargin;
            end

            h = h@slreportgen.report.Reporter( args{ : } );





            p = inputParser;




            p.KeepUnmatched = true;

            addParameter( p, "TemplateName", "LookupTable" );
            addParameter( p, "DataReporter", mlreportgen.report.BaseTable );
            addParameter( p, "PlotReporter", mlreportgen.report.Figure );
            addParameter( p, "PlotType", "Surface Plot" );
            addParameter( p, "MaxTableColumns", Inf );

            parse( p, args{ : } );

            h.TemplateName = p.Results.TemplateName;
            h.DataReporter = p.Results.DataReporter;
            h.PlotReporter = p.Results.PlotReporter;
            h.MaxTableColumns = p.Results.MaxTableColumns;

        end

        function set.Object( h, obj )
            h.Object = obj;
            createLookupTableSource( h );
        end


        function impl = getImpl( h, rpt )
            arguments
                h( 1, 1 )
                rpt( 1, 1 ){ validateReport( h, rpt ) }
            end

            impl = [  ];%#ok<NASGU>

            setOutputType( h, rpt.Type );


            if isempty( h.Object )
                error( message( "slreportgen:report:error:noSourceObjectSpecified", class( h ) ) );
            else


                if isempty( h.LinkTarget )



                    objH = slreportgen.utils.getSlSfHandle( h.Object );
                    parent = get_param( objH, "Parent" );
                    hs = slreportgen.utils.HierarchyService;
                    dhid = hs.getDiagramHID( parent );
                    parentPath = hs.getPath( dhid );

                    if ~isempty( parentPath )
                        parentPath = strrep( parentPath, newline, ' ' );
                        parentDiagram = getContext( rpt, parentPath );
                        if ~isempty( parentDiagram ) && ( parentDiagram.HyperLinkDiagram )
                            h.LinkTarget = slreportgen.utils.getObjectID( h.Object );
                        end
                    end
                end


                modelH = slreportgen.utils.getModelHandle( h.Object );
                compileModel( rpt, modelH );

                h.m_ShouldNumberTableHierarchically = isChapterNumberHierarchical( h, rpt );
                impl = getImpl@slreportgen.report.Reporter( h, rpt );
            end
        end
    end


    methods ( Access = { ?mlreportgen.report.ReportForm } )

        function lutTypesReporter = getLUTDataTypes( h, ~ )




            lutTypesReporter = [  ];
            if ( ~h.m_compilationError )
                try

                    dtProps = getLookupTableDataTypeProperties( h.m_src );

                    if ~isempty( dtProps )
                        tableHeader = { h.m_src.PropTableHeader,  ...
                            getString( message( "slreportgen:report:LookupTable:Value" ) ) };

                        table = mlreportgen.dom.FormalTable( tableHeader, dtProps );

                        titleStr = getPropertiesTableTitle( h.m_src );
                        dataTypeBaseTable = mlreportgen.report.BaseTable(  ...
                            "Title", titleStr,  ...
                            "Content", table );
                        dataTypeBaseTable.TableStyleName = "LUTDataTypeStyle";

                        if mlreportgen.report.Reporter.isInlineContent( dataTypeBaseTable.Title )
                            titleReporter = getTitleReporter( dataTypeBaseTable );
                            titleReporter.TemplateSrc = h;

                            if h.m_ShouldNumberTableHierarchically
                                titleReporter.TemplateName = 'LUTHierNumberedTitle';
                            else
                                titleReporter.TemplateName = 'LUTNumberedTitle';
                            end
                            dataTypeBaseTable.Title = titleReporter;
                        end
                        lutTypesReporter = dataTypeBaseTable;
                    end
                catch ME
                    warning( ME.identifier, "%s", ME.message );
                end
            end
        end

        function content = getContent( h, rpt )
            content = [  ];
            if isInputSimulated( h.m_src )
                simulatedContentStr = getBlockInputStr( h.m_src );
                if ~strcmp( simulatedContentStr, "" )
                    simulatedContentHeading = mlreportgen.dom.Paragraph(  );
                    simulatedContentHeading.StyleName = "LUTSimulatedContentHeadingStyle";
                    simulatedHeadingStr = getDisplayLabel( h.m_src );
                    append( simulatedContentHeading, simulatedHeadingStr );

                    simulatedContent = mlreportgen.dom.Paragraph(  );
                    append( simulatedContent, simulatedContentStr );
                    simulatedContent.StyleName = "LUTSimulatedContentStyle";

                    content = { simulatedContentHeading, simulatedContent };
                end
            else
                try
                    breakPoints = getBreakPoints( h.m_src );
                    tableData = getTableData( h.m_src );
                    assertValidBreakPoints( h.m_src, breakPoints, tableData );

                    if ~isempty( tableData ) || ~isempty( breakPoints )



                        tableTitle = getTableTitle( h.m_src );
                        slicedData = makeMultiTable( h, breakPoints, tableData, tableTitle, [  ], 0, {  } );



                        slicedDataLength = numel( slicedData );
                        content = cell( 1, slicedDataLength );

                        if ( slicedDataLength > h.WarnNumberOfTableSlices )
                            warning( message( "slreportgen:report:LookupTable:LargeLookupTable", getfullname( h.m_src.Handle ) ) );
                        end

                        prevmsg = '';
                        for i = 1:slicedDataLength

                            if ( slicedDataLength > h.WarnNumberOfTableSlices )
                                if ( i > 1 )
                                    fprintf( repmat( '\b', 1, strlength( prevmsg ) ) );
                                end
                                msg = getString( message( "slreportgen:report:LookupTable:LargeLookupTableUpdate", i, slicedDataLength ) );
                                fprintf( '%s', getString( message( "slreportgen:report:LookupTable:LargeLookupTableUpdate", i, slicedDataLength ) ) );
                                prevmsg = msg;
                            end
                            documentPartObj = getDocPartObj( h, rpt, slicedData{ i } );
                            content{ i } = { documentPartObj };
                        end
                    end
                catch ME
                    content = getCompilationErrorMessage( h, ME );
                end
            end
            h.Content = content;

        end

        function content = getFootNoteContent( h, rpt )%#ok<INUSD>

            content = {  };
            if ( ~h.m_compilationError )
                try
                    if ( h.IncludeTable ) || ( h.IncludePlot )
                        items = [  ...
                            getTableDataExpressionContent( h ) ...
                            , getBreakpointExpressionContent( h ) ...
                            , getLookupTableObjExpressionContent( h ) ...
                            , getBreakpointObjExpressionContent( h ) ...
                            , getEvenSpacingInfoContent( h ) ...
                            ];

                        nItems = numel( items );
                        if ( nItems > 0 )
                            footNoteHeading = mlreportgen.dom.Paragraph(  );
                            append( footNoteHeading, getString( message( "slreportgen:report:LookupTable:Note" ) ) );
                            footNoteHeading.StyleName = "LUTFootNoteTitleStyle";

                            footNoteList = mlreportgen.dom.UnorderedList(  );
                            footNoteList.StyleName = "LUTFootNoteContentStyle";
                            for i = 1:nItems
                                append( footNoteList, items{ i } );
                            end
                            content = { footNoteHeading, footNoteList };
                        end
                    end
                catch ME
                    warning( ME.identifier, "%s", ME.message );
                end
            end
        end
    end
    methods ( Access = private )

        function compilationErrorContent = getCompilationErrorMessage( h, ME )
            h.m_compilationError = true;
            compilationErrorContent = {  };

            compilationErrorContent{ 1 } = mlreportgen.dom.Paragraph(  );
            compilationErrorContent{ 1 }.StyleName = "LUTCompiledErrorContentHeadingStyle";
            compilationContentHeadingStr = getDisplayLabel( h.m_src );
            append( compilationErrorContent{ 1 }, compilationContentHeadingStr );

            compilationErrorContent{ 2 } = mlreportgen.dom.Paragraph(  );
            blkName = mlreportgen.utils.normalizeString( get_param( h.Object, 'Name' ) );


            index = find( ismember( h.KnownErrorIdentifiers, ME.identifier ), 1 );


            if isempty( index )
                str = getString( message( "slreportgen:report:error:UnknownCompileError", get_param( h.Object, "Name" ) ) );
                append( compilationErrorContent{ 2 }, str );
            else
                warning( ME.identifier, "%s", ME.message );
                compilationErrorContentStr = getString( message( "slreportgen:report:error:CompileError", blkName ) );
                append( compilationErrorContent{ 2 }, compilationErrorContentStr );
                compilationErrorContent{ 3 } = mlreportgen.dom.UnorderedList(  );
                compilationErrorContent{ 3 }.StyleName = "LUTCompilationErrorListStyle";
                append( compilationErrorContent{ 3 }, mlreportgen.dom.Text( ME.message ) );

            end
        end

        function content = getBreakpointExpressionContent( h )
            bpExpr = getBreakpointExpression( h.m_src );
            n = numel( bpExpr );
            content = cell( 1, n );
            for i = 1:n
                str = getString( message( "slreportgen:report:LookupTable:BreakpointAsExpression", bpExpr{ i }{ 1 },  ...
                    bpExpr{ i }{ 2 } ) );
                content{ i } = mlreportgen.dom.Text( str );
            end
        end

        function content = getTableDataExpressionContent( h )
            tableDataExpr = getTableDataExpression( h.m_src );
            if ~isempty( tableDataExpr )
                str = getString( message( "slreportgen:report:LookupTable:TableDataAsExpression", tableDataExpr ) );
                content = { mlreportgen.dom.Text( str ) };
            else
                content = {  };
            end
        end

        function content = getLookupTableObjExpressionContent( h )
            lutExpr = getLookupTableObjExpression( h.m_src );
            if ~isempty( lutExpr )
                str = getString( message( "slreportgen:report:LookupTable:LookupTableObject", lutExpr ) );
                content = { mlreportgen.dom.Text( str ) };
            else
                content = {  };
            end
        end

        function content = getBreakpointObjExpressionContent( h )
            bpObjExpr = getBreakpointObjExpression( h.m_src );
            if ~isempty( bpObjExpr )
                str = getString( message( "slreportgen:report:LookupTable:BreakpointObject", lutExpr ) );
                content{ 1 } = mlreportgen.dom.Text( str );
            else
                content = {  };
            end
        end

        function content = getEvenSpacingInfoContent( h )
            bpEvenSpacingInfo = getEvenSpacingInfo( h.m_src );
            n = numel( bpEvenSpacingInfo );
            content = cell( 1, n );
            for i = 1:n
                str = getString( message( "slreportgen:report:LookupTable:EvenSpacedBreakpoints", bpEvenSpacingInfo{ i }{ 1 },  ...
                    bpEvenSpacingInfo{ i }{ 2 }, bpEvenSpacingInfo{ i }{ 3 } ) );
                content{ i } = mlreportgen.dom.Text( str );
            end
        end

        function createLookupTableSource( h )
            h.m_src = slreportgen.report.internal.lookuptable.createSource( h.Object );
        end

        function [ xLabel, yLabel ] = generateXYLabel( h, slicedData )

            if isempty( h.m_xLabel ) && isempty( h.m_yLabel )

                if isa( slicedData.breakPoints1, "embedded.fi" )
                    slicedBP1 = getFixedPointValues( slicedData.breakPoints1 );
                else
                    slicedBP1 = slicedData.breakPoints1;
                end
                if isfield( slicedData, 'breakPoints2' )
                    if isa( slicedData.breakPoints2, "embedded.fi" )
                        slicedBP2 = getFixedPointValues( slicedData.breakPoints2 );
                    else
                        slicedBP2 = slicedData.breakPoints2;
                    end
                end

                [ sz, nDims ] = getTableDimensions( slicedData.dataSlice );

                yDim = sz( 1 );
                xDim = sz( 2 );
                if nDims == 1



                    xLabel = cell( 0, 2 );
                    yDim = max( sz );
                else
                    xLabel = getBreakPointsLabel( slicedBP2, xDim, slicedData.zeroBasedIndices );
                    xLabel = [ { '' }, xLabel( : )' ];
                end

                yLabel = getBreakPointsLabel( slicedBP1, yDim, slicedData.zeroBasedIndices );

                h.m_xLabel = xLabel;
                h.m_yLabel = yLabel;
            else
                xLabel = h.m_xLabel;
                yLabel = h.m_yLabel;

            end
        end


        function documentPartObj = getDocPartObj( h, rpt, slicedData )
            figReporter = [  ];
            titleRptrForLUT = [  ];
            slicedTableContent = [  ];



            [ xLabel, yLabel ] = generateXYLabel( h, slicedData );

            if isa( slicedData.dataSlice, "embedded.fi" )
                slicedTableData = getFixedPointValues( slicedData.dataSlice );
            else
                slicedTableData = slicedData.dataSlice;
            end

            if ( h.IncludeTable )
                [ sz, nDims ] = getTableDimensions( slicedTableData );


                if ( nDims == 1 ) ||  ...
                        ( nDims == 2 && sz( 2 ) < h.MaxTableColumns )
                    [ titleRptrForLUT, slicedTableContent ] = generateTable( h, slicedTableData, slicedData.tableTitle,  ...
                        xLabel, yLabel );
                end
            end

            if ( h.IncludePlot )
                if ( slreportgen.report.LookupTable.isOneDimensionalSliceData( slicedData ) )
                    figReporter = generatePlot( h, rpt, slicedData.dataSlice, slicedData.tableTitle,  ...
                        slicedData.breakPoints1 );
                else

                    figReporter = generatePlot( h, rpt, slicedData.dataSlice, slicedData.tableTitle,  ...
                        slicedData.breakPoints1, slicedData.breakPoints2 );
                end
            end
            if isa( h.TemplateSrc, "slreportgen.report.internal.DocumentPart" )
                documentPartObj = slreportgen.report.internal.DocumentPart( h.TemplateSrc, "LookupTableContent" );
            else
                documentPartObj = slreportgen.report.internal.DocumentPart( rpt.Type, h.TemplateSrc, "LookupTableContent" );
            end

            fillDocPartHoles( h, rpt, documentPartObj, titleRptrForLUT, slicedTableContent, figReporter );
        end

        function fillDocPartHoles( h, rpt, documentPartObj, titleRptrForLUT, slicedTableContent, figReporter )

            open( documentPartObj );

            while ~strcmp( documentPartObj.CurrentHoleId, "#end#" )
                switch documentPartObj.CurrentHoleId
                    case "TableContent"
                        if ~isempty( titleRptrForLUT )
                            titleRptrForLUT.TemplateSrc = h;

                            if h.m_ShouldNumberTableHierarchically
                                titleRptrForLUT.TemplateName = 'LUTHierNumberedTitle';
                            else
                                titleRptrForLUT.TemplateName = 'LUTNumberedTitle';
                            end

                            append( documentPartObj, titleRptrForLUT.getImpl( rpt ) );









                            for i = 1:length( slicedTableContent )
                                append( documentPartObj, slicedTableContent{ i } );
                            end
                        end
                    case "FigureContent"
                        if ~isempty( figReporter )






                            figReporter.Snapshot.Image = getSnapshotImage( figReporter, rpt );
                            if mlreportgen.report.Reporter.isInlineContent( figReporter.Snapshot.Image )
                                imageReporter = getImageReporter( figReporter.Snapshot, rpt );
                                imageReporter.TemplateSrc = h;
                                imageReporter.TemplateName = 'LUTImage';
                                figReporter.Snapshot.Image = imageReporter;
                            end

                            if ~isempty( figReporter.Snapshot.Caption ) &&  ...
                                    mlreportgen.report.Reporter.isInlineContent( figReporter.Snapshot.Caption )
                                captionReporter = getCaptionReporter( figReporter.Snapshot );
                                captionReporter.TemplateSrc = h;

                                if h.m_ShouldNumberTableHierarchically
                                    captionReporter.TemplateName = 'LUTHierNumberedCaption';
                                else
                                    captionReporter.TemplateName = 'LUTNumberedCaption';
                                end
                                figReporter.Snapshot.Caption = captionReporter;
                            end

                            figureImpl = figReporter.getImpl( rpt );
                            append( documentPartObj, figureImpl );
                        end
                end
                moveToNextHole( documentPartObj );
            end
            close( documentPartObj );
        end

        function content = generatePlot( h, rpt, tableData, tableTitle, breakPoints1, varargin )
            [ sz, nDims ] = getTableDimensions( tableData );%#ok<ASGLU>
            if nDims == 1

                figH = makeFigureOneD( breakPoints1,  ...
                    h.m_src.BreakpointsHeader,  ...
                    tableData,  ...
                    getString( message( "slreportgen:report:LookupTable:Outputs" ) ) );
            elseif nDims == 2
                figH = makeFigureTwoD( breakPoints1,  ...
                    getString( message( "slreportgen:report:LookupTable:Bp1" ) ),  ...
                    varargin{ 1 },  ...
                    getString( message( "slreportgen:report:LookupTable:Bp2" ) ),  ...
                    tableData,  ...
                    getString( message( "slreportgen:report:LookupTable:Outputs" ) ),  ...
                    h.PlotType );
            else
                figH = [  ];
            end
            if ~isempty( figH )
                captionStr = getDisplayLabel( h.m_src );
                if ischar( tableTitle )
                    tableTitle = string( tableTitle );
                end
                slicingCaption = strjoin( tableTitle );
                captionStr = strjoin( [ captionStr, strtrim( slicingCaption ) ] );
                fig = copy( h.PlotReporter );
                if isempty( fig.Snapshot.Caption )
                    fig.Snapshot.Caption = captionStr;
                else


                    appendCaption( fig.Snapshot, captionStr );
                end
                fig.Source = figH;
                content = fig;
                figureHandles = getContext( rpt, 'figureHandles' );
                figureHandles{ end  + 1 } = figH;
                setContext( rpt, 'figureHandles', figureHandles );
            else
                content = [  ];
            end
        end





        function slicedData = makeMultiTable( h, breakPoints, tableData, tableTitle, history, zeroBasedIndices, slicedData )

            [ sz, nDims ] = getTableDimensions( tableData );
            thisDim = nDims - length( history );

            if thisDim <= 2
                tableTitle = [ tableTitle, ' ',  ...
                    getnDTitle( history, breakPoints, nDims, zeroBasedIndices ) ];
                history = num2cell( history );
                dataSlice = tableData( :, :, history{ : } );

                minDims = min( nDims, 2 );
                slicedInfo.dataSlice = dataSlice;
                slicedInfo.tableTitle = tableTitle;
                slicedInfo.zeroBasedIndices = zeroBasedIndices;
                slicedInfo.breakPoints1 = breakPoints{ 1 };
                if minDims == 2
                    slicedInfo.breakPoints2 = breakPoints{ 2 };
                end
                slicedData{ end  + 1 } = slicedInfo;

            else
                for i = 1:sz( thisDim )
                    slicedData = makeMultiTable( h, breakPoints, tableData, tableTitle, [ i, history ], zeroBasedIndices, slicedData );
                end
            end
        end

        function [ titleRptrForLUT, tableContent ] = generateTable( h, tableData, tableTitle, xLabels, yLabels )
            titleRptrForLUT = [  ];
            [ sz, nDims ] = getTableDimensions( tableData );%#ok<ASGLU>
            if ( nDims == 1 )
                tableData = tableData( : );
            end
            tableData = [ xLabels;[ yLabels( : ), num2cell( tableData ) ] ];
            tableData = cellfun( @mlreportgen.utils.toString, tableData, 'UniformOutput', false );

            titleStr = getDisplayLabel( h.m_src );

            if ischar( tableTitle )
                tableTitle = string( tableTitle );
            end

            slicingTitle = strjoin( tableTitle );
            titleStr = strjoin( [ titleStr, strtrim( slicingTitle ) ] );

            baseTable = copy( h.DataReporter );

            if isempty( baseTable.Title )
                baseTable.Title = titleStr;
            else


                appendTitle( baseTable, titleStr );
            end

            if nDims == 1
                tableContent = generateOneDimensionalTable( h, tableData );
            else
                tableContent = generateTwoDimensionalTable( h, tableData );
            end


            if ~isempty( baseTable ) && mlreportgen.report.Reporter.isInlineContent( baseTable.Title )
                titleRptrForLUT = getTitleReporter( baseTable );
            end

        end

        function oneDimensionalTable = generateOneDimensionalTable( h, tableData )

            table = mlreportgen.dom.FormalTable(  );
            table.StyleName = 'LUTOneDimensionalTableStyle';
            tr = mlreportgen.dom.TableRow(  );
            append( tr, mlreportgen.dom.TableHeaderEntry( h.m_src.BreakpointsHeader ) );
            append( tr, mlreportgen.dom.TableHeaderEntry( getString( message( "slreportgen:report:LookupTable:Outputs" ) ) ) );
            append( table, tr );



            s = size( tableData );
            for row = 1:s( 1 )
                tableRow = mlreportgen.dom.TableRow(  );
                tableEntry = mlreportgen.dom.TableEntry(  );

                append( tableEntry, tableData{ row, 1 } );
                tableEntry.StyleName = 'LUTInnerTableBreakPointStyle';

                append( tableRow, tableEntry );
                values = tableData{ row, 2 };
                tableEntry = mlreportgen.dom.TableEntry( values );
                append( tableRow, tableEntry );
                append( table, tableRow );
            end
            oneDimensionalTable = { table };
        end

        function table = generateTwoDimensionalTable( h, tableData )

            innerTable = slreportgen.report.LookupTable.getInnerTable( tableData );

            if ( h.DataReporter.MaxCols ~= Inf )
                slicer = mlreportgen.utils.TableSlicer(  ...
                    "Table", innerTable,  ...
                    "MaxCols", h.DataReporter.MaxCols,  ...
                    "RepeatCols", 1 );
                slices = slice( slicer );
            else
                slices = [  ];
            end
            if ~isempty( slices )
                table = cell( 1, length( slices ) * 2 );
            else
                table = cell( 1, 1 );
            end

            sliceInd = 1;
            tableInd = 1;

            while ( tableInd <= length( table ) )
                if ~isempty( slices )
                    str = getString( message( "slreportgen:report:LookupTable:slicedContentRepeatColsTitle",  ...
                        1, 1, slices( sliceInd ).StartCol, slices( sliceInd ).EndCol ) );
                    paraTitle = mlreportgen.dom.Paragraph( str );
                    if isempty( h.DataReporter.TableSliceTitleStyleName )
                        paraTitle.StyleName = "LUTSlicedTableContentTitle";
                    else
                        paraTitle.StyleName = h.DataReporter.TableSliceTitleStyleName;
                    end
                    table{ tableInd } = paraTitle;
                    tableInd = tableInd + 1;
                end
                table{ tableInd } = mlreportgen.dom.Table(  );
                table{ tableInd }.StyleName = 'LUTOuterTableStyle';

                OuterTableFirstRow = mlreportgen.dom.TableRow(  );
                OuterTableFirstRow.StyleName = 'LUTOuterTableFirstRowStyle';
                OuterTableFirstEntry = mlreportgen.dom.TableEntry(  );
                append( OuterTableFirstRow, OuterTableFirstEntry );

                outerTableSecondEntry = mlreportgen.dom.TableEntry( 'BP2' );
                append( OuterTableFirstRow, outerTableSecondEntry );
                append( table{ tableInd }, OuterTableFirstRow );

                outerTableSecondRow = mlreportgen.dom.TableRow(  );
                textObj = mlreportgen.dom.Paragraph( 'BP1' );
                textObj.StyleName = 'LUTBreakPointLabelStyle';


                breakPointInnerTable = mlreportgen.dom.Table(  );
                breakPointInnerTable.StyleName = 'LUTBreakPointInnerTableStyle';
                breakPointInnerTableRow = mlreportgen.dom.TableRow(  );






                if ~isempty( getenv( "USE_FOP" ) ) || ~strcmpi( 'pdf', getOutputType( h ) )

                    breakPointInnerTableRow.Height = '0.3in';
                end

                breakPointtableEntry = mlreportgen.dom.TableEntry( textObj );
                breakPointtableEntry.Style = [ breakPointtableEntry.Style, { mlreportgen.dom.TextOrientation( 'up' ) } ];
                append( breakPointInnerTableRow, breakPointtableEntry );
                append( breakPointInnerTable, breakPointInnerTableRow );
                outerTableThirdEntry = mlreportgen.dom.TableEntry( breakPointInnerTable );
                outerTableThirdEntry.StyleName = 'LUTOuterTableThirdCellStyle';
                append( outerTableSecondRow, outerTableThirdEntry );

                if isempty( slices )
                    FourthTableEntry = mlreportgen.dom.TableEntry( innerTable );
                else
                    FourthTableEntry = mlreportgen.dom.TableEntry( slices( sliceInd ).Table );
                end
                FourthTableEntry.StyleName = 'LUTOuterTableFourthCellStyle';
                append( outerTableSecondRow, FourthTableEntry );
                append( table{ tableInd }, outerTableSecondRow );
                sliceInd = sliceInd + 1;
                tableInd = tableInd + 1;
            end
        end

    end

    methods ( Static )

        function path = getClassFolder(  )

            [ path ] = fileparts( mfilename( 'fullpath' ) );
        end

        function template = createTemplate( templatePath, type )






            path = slreportgen.report.LookupTable.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function classfile = customizeReporter( toClasspath )









            classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
                "slreportgen.report.LookupTable" );
        end

        function isOneDimensional = isOneDimensionalSliceData( slicedData )
            isOneDimensional = ( length( fieldnames( slicedData ) ) == 4 );
        end


        function isTwoDimensional = isTwoDimensionalSliceData( slicedData )
            isTwoDimensional = ( length( fieldnames( slicedData ) ) == 5 );
        end


        function table2 = getInnerTable( tableData )
            table2 = mlreportgen.dom.Table(  );
            table2.StyleName = 'LUTInnerTableStyle';
            s = size( tableData );
            for rownum = 1:s( 1 )
                tableRow = mlreportgen.dom.TableRow(  );

                for colnum = 1:s( 2 )
                    tableEntry = mlreportgen.dom.TableEntry( tableData{ rownum, colnum } );
                    if ( rownum == 1 || colnum == 1 )
                        tableEntry.StyleName = 'LUTInnerTableBreakPointStyle';
                    end
                    append( tableRow, tableEntry );
                end
                append( table2, tableRow );
            end
        end
    end


    methods ( Access = protected, Hidden )

        result = openImpl( reporter, impl, varargin )
    end

    methods ( Access = private )
        function setOutputType( h, type )
            h.ReportOutputType = type;
        end

        function format = getOutputType( h )
            format = h.ReportOutputType;
        end

    end
end


function mustBeBaseTable( table )
mlreportgen.report.validators.mustBeInstanceOf( 'mlreportgen.report.BaseTable', table );
end


function mustBeFigure( figure )
mlreportgen.report.validators.mustBeInstanceOf( 'mlreportgen.report.Figure', figure );
end

function mustBeLogical( varargin )
mlreportgen.report.validators.mustBeLogical( varargin{ : } );
end

function mustBeLookupTableObject( object )
if ~isempty( object ) && ~slreportgen.utils.isLookupTable( object )
    error( message( "slreportgen:report:error:invalidSourceObject" ) );
end
end

function mustBeValidMaxSize( size )
if ~isnumeric( size ) || size <= 0
    error( message( "slreportgen:report:error:invalidMaxTableColumns" ) );
end
end
