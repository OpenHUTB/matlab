classdef SystemIO < slreportgen.report.Reporter


























































































    properties




        Object{ mlreportgen.report.validators.mustBeInstanceOfMultiClass(  ...
            { 'numeric', 'slreportgen.finder.DiagramResult', 'slreportgen.finder.BlockResult', 'string', 'char' },  ...
            Object ) };



























        InputSummaryProperties{ mlreportgen.report.validators.mustBeVectorOf( [ "string", "char" ], InputSummaryProperties ) } = [ "Port", "Inport Block", "Source", "Name", "DataType" ];



























        OutputSummaryProperties{ mlreportgen.report.validators.mustBeVectorOf( [ "string", "char" ], OutputSummaryProperties ) } = [ "Port", "Outport Block", "Destination", "Name", "DataType" ];









        ShowInputSummary{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = true;









        ShowOutputSummary{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = true;














        ShowDetails{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = true;








        ShowEmptyColumns{ mlreportgen.report.validators.mustBeLogical, mustBeNonempty } = false;












        InputSummaryReporter{ mlreportgen.report.validators.mustBeInstanceOf( "mlreportgen.report.BaseTable", InputSummaryReporter ) }












        OutputSummaryReporter{ mlreportgen.report.validators.mustBeInstanceOf( "mlreportgen.report.BaseTable", OutputSummaryReporter ) }










        DetailsReporter{ mlreportgen.report.validators.mustBeInstanceOf( "slreportgen.report.SimulinkObjectProperties", DetailsReporter ) }









        ListFormatter{ mlreportgen.report.validators.mustBeInstanceOfMultiClass( { 'mlreportgen.dom.UnorderedList', 'mlreportgen.dom.OrderedList' }, ListFormatter ) }
    end

    properties ( Hidden )

        ObjectPath;



        IsBlockDiagram;




        PortHandles;





        Inputs;
        Outputs;
    end

    properties ( Access = private )

        FirstColLabel;
    end

    methods
        function this = SystemIO( varargin )
            if nargin == 1
                container = varargin{ 1 };
                varargin = { "Object", container };
            end

            this = this@slreportgen.report.Reporter( varargin{ : } );


            p = inputParser;




            p.KeepUnmatched = true;




            addParameter( p, "TemplateName", "SystemIO" );

            ul = mlreportgen.dom.UnorderedList(  );
            ul.StyleName = "SystemIOList";
            addParameter( p, "ListFormatter", ul );

            baseTable = mlreportgen.report.BaseTable(  );
            baseTable.TableStyleName = "SystemIOTable";
            addParameter( p, "InputSummaryReporter", baseTable );
            addParameter( p, "OutputSummaryReporter", copy( baseTable ) );

            objRptr = slreportgen.report.SimulinkObjectProperties(  );
            objRptr.PropertyTable = baseTable.copy(  );
            addParameter( p, "DetailsReporter", objRptr );


            parse( p, varargin{ : } );


            results = p.Results;
            this.TemplateName = results.TemplateName;
            this.ListFormatter = results.ListFormatter;
            this.InputSummaryReporter = results.InputSummaryReporter;
            this.OutputSummaryReporter = results.OutputSummaryReporter;
            this.DetailsReporter = results.DetailsReporter;
        end

        function impl = getImpl( this, rpt )
            arguments
                this( 1, 1 )
                rpt( 1, 1 ){ validateReport( this, rpt ) }
            end

            if isempty( this.Object )

                error( message( "slreportgen:report:error:noSourceObjectSpecified", class( this ) ) );
            else
                object = this.Object;
                if isa( object, "slreportgen.finder.DiagramResult" ) ...
                        || isa( object, "slreportgen.finder.BlockResult" )
                    object = object.Object;
                    if isa( object, "Stateflow.Chart" )
                        object = this.Object.Path;
                    end
                end

                if ~isValidSlObject( slroot, object )
                    error( message( "slreportgen:report:error:invalidSystemIOObject" ) );
                end
                this.ObjectPath = getfullname( object );


                if ~isempty( this.ListFormatter.Children )
                    error( message( "slreportgen:report:error:nonemptyListFormatter" ) );
                end

                preparePortData( this, object );


                modelH = slreportgen.utils.getModelHandle( bdroot( this.ObjectPath ) );
                compileModel( rpt, modelH );



                impl = getImpl@slreportgen.report.Reporter( this, rpt );
            end

        end

        function preparePortData( this, object )


            if strcmpi( get_param( object, "Type" ), "block" )
                this.IsBlockDiagram = false;
                this.FirstColLabel = "Port";


                pc = get_param( this.ObjectPath, "PortConnectivity" );




                portNums = str2double( { pc( : ).Type } );
                pc( isnan( portNums ) ) = [  ];


                outputIdx = arrayfun( @( x )isempty( x.SrcBlock ), pc );
                this.Outputs = pc( outputIdx );
                this.Inputs = pc( ~outputIdx );

                this.PortHandles = get_param( this.ObjectPath, "PortHandles" );
            elseif strcmpi( get_param( object, "Type" ), "block_diagram" )
                this.IsBlockDiagram = true;
                this.FirstColLabel = "Block";


                this.Inputs = find_system( object, "FindAll", 'on', "SearchDepth", 1, "Type", "block", "BlockType", "Inport" );
                this.Outputs = find_system( object, "FindAll", 'on', "SearchDepth", 1, "Type", "block", "BlockType", "Outport" );


                portHandles = get_param( [ this.Inputs;this.Outputs ], "PortHandles" );
                if ~isempty( portHandles )
                    if iscell( portHandles )
                        portHandles = cell2mat( portHandles );
                    end


                    this.PortHandles.Inport = [ portHandles.Outport ];

                    this.PortHandles.Outport = [ portHandles.Inport ];
                else
                    this.PortHandles.Inport = [  ];
                    this.PortHandles.Outport = [  ];
                end
            else
                error( message( "slreportgen:report:error:invalidSystemIOObject" ) );
            end
        end

        function set.ListFormatter( this, value )

            mustBeNonempty( value );


            if ~isempty( value.Children )
                error( message( "slreportgen:report:error:nonemptyListFormatter" ) );
            end

            this.ListFormatter = value;
        end

        function set.InputSummaryReporter( this, value )

            mustBeNonempty( value );
            this.InputSummaryReporter = value;
        end

        function set.OutputSummaryReporter( this, value )

            mustBeNonempty( value );
            this.OutputSummaryReporter = value;
        end

        function set.DetailsReporter( this, value )

            mustBeNonempty( value );
            this.DetailsReporter = value;
        end
    end

    methods ( Access = { ?mlreportgen.report.ReportForm, ?slreportgen.report.SystemIO } )
        function content = getInputsContent( this, rpt )
            if this.ShowInputSummary
                portHandles = this.PortHandles.Inport;
                inputs = this.Inputs;
                nInputs = numel( inputs );


                props = this.InputSummaryProperties;
                nProps = numel( props );


                tableData = cell( nInputs, nProps );
                for inputIdx = 1:nInputs
                    input = inputs( inputIdx );
                    portHandle = portHandles( inputIdx );
                    portStr = num2str( inputIdx );



                    if this.IsBlockDiagram
                        objID = slreportgen.utils.getObjectID( input, "Hash", false );
                        inportBlk = input;
                    else
                        objID = slreportgen.utils.getObjectID( portHandle, "Hash", false );
                        inportBlk = find_system( this.ObjectPath, 'LookUnderMasks', 'all', 'FollowLinks', 'on',  ...
                            'FirstResultOnly', 'on', 'SearchDepth', 1,  ...
                            'type', 'block', 'blocktype', 'Inport', 'port', portStr );
                        if iscell( inportBlk ) && ~isempty( inportBlk )
                            inportBlk = inportBlk{ 1 };
                        end
                    end


                    for propIdx = 1:nProps
                        prop = props( propIdx );
                        if strcmp( prop, "Source" )
                            tableData{ inputIdx, propIdx } = getSource( this, input, portHandle );
                        elseif strcmp( prop, "Port" )
                            if this.ShowDetails

                                para = mlreportgen.dom.Paragraph(  );


                                summaryLinkTarget = mlreportgen.dom.LinkTarget( mlreportgen.utils.normalizeLinkID( objID + "Summary" ) );
                                append( para, summaryLinkTarget );

                                detailsLink = mlreportgen.dom.InternalLink( mlreportgen.utils.normalizeLinkID( objID ), portStr );
                                append( para, detailsLink );
                                tableData{ inputIdx, propIdx } = para;
                            else
                                tableData{ inputIdx, propIdx } = portStr;
                            end
                        elseif ~isempty( inportBlk ) && startsWith( prop, [ "InportBlock", "Inport Block" ] )

                            tableData{ inputIdx, propIdx } = getPortBlockProperty( inportBlk, prop );
                        else
                            tableData{ inputIdx, propIdx } = slreportgen.utils.internal.getSignalProperty( portHandle, prop );
                        end
                    end
                end


                content = createTable( this, rpt, props,  ...
                    strcat( get_param( this.ObjectPath, "Name" ), " ", getString( message( "slreportgen:report:SystemIO:inputSummary" ) ) ),  ...
                    tableData, this.InputSummaryReporter );
            else
                content = [  ];
            end

        end

        function content = getOutputsContent( this, rpt )

            if this.ShowOutputSummary
                portHandles = this.PortHandles.Outport;
                outputs = this.Outputs;
                nOutputs = numel( outputs );


                props = this.OutputSummaryProperties;
                nProps = numel( props );


                tableData = cell( nOutputs, nProps );
                for outputIdx = 1:nOutputs
                    output = outputs( outputIdx );
                    portHandle = portHandles( outputIdx );
                    portStr = num2str( outputIdx );



                    if this.IsBlockDiagram
                        objID = slreportgen.utils.getObjectID( output, "Hash", false );
                        outportBlk = output;
                    else
                        objID = slreportgen.utils.getObjectID( portHandle, "Hash", false );
                        outportBlk = find_system( this.ObjectPath, 'LookUnderMasks', 'all', 'FollowLinks', 'on',  ...
                            'FirstResultOnly', 'on', 'SearchDepth', 1,  ...
                            'type', 'block', 'blocktype', 'Outport', 'port', portStr );
                        if iscell( outportBlk ) && ~isempty( outportBlk )
                            outportBlk = outportBlk{ 1 };
                        end
                    end


                    for propIdx = 1:nProps
                        prop = props( propIdx );
                        if strcmp( prop, "Destination" )
                            tableData{ outputIdx, propIdx } = getDestination( this, output, portHandle );
                        elseif strcmp( prop, "Port" )
                            if this.ShowDetails

                                para = mlreportgen.dom.Paragraph(  );


                                summaryLinkTarget = mlreportgen.dom.LinkTarget( mlreportgen.utils.normalizeLinkID( objID + "Summary" ) );
                                append( para, summaryLinkTarget );

                                detailsLink = mlreportgen.dom.InternalLink( mlreportgen.utils.normalizeLinkID( objID ), portStr );
                                append( para, detailsLink );
                                tableData{ outputIdx, propIdx } = para;
                            else
                                tableData{ outputIdx, propIdx } = portStr;
                            end
                        elseif ~isempty( outportBlk ) && startsWith( prop, [ "OutportBlock", "Outport Block" ] )

                            tableData{ outputIdx, propIdx } = getPortBlockProperty( outportBlk, prop );
                        else
                            tableData{ outputIdx, propIdx } = slreportgen.utils.internal.getSignalProperty( portHandle, prop );
                        end
                    end
                end


                content = createTable( this, rpt, props,  ...
                    strcat( get_param( this.ObjectPath, "Name" ), " ", getString( message( "slreportgen:report:SystemIO:outputSummary" ) ) ),  ...
                    tableData, this.OutputSummaryReporter );
            else
                content = [  ];
            end
        end

        function content = getDetailsContent( this, rpt )
            if this.ShowDetails
                if this.IsBlockDiagram

                    ioHandles = [ this.Inputs;this.Outputs ];
                else

                    portHandles = this.PortHandles;
                    ioHandles = [ portHandles.Inport, portHandles.Outport ];
                end

                nObjs = numel( ioHandles );
                content = cell( 1, nObjs );

                for objIdx = 1:nObjs
                    ioHandle = ioHandles( objIdx );
                    obj = slreportgen.utils.getSlSfObject( ioHandle );
                    objID = slreportgen.utils.getObjectID( obj, "Hash", false );

                    if this.IsBlockDiagram
                        objName = strrep( obj.Name, newline, ' ' );
                        titleStr = string( objName ) + " " + getString( message( "slreportgen:report:SystemIO:properties" ) );
                    else


                        [ ~, objParent, ~ ] = fileparts( strrep( obj.Parent, newline, ' ' ) );
                        titleStr = strcat( objParent, " ",  ...
                            mlreportgen.utils.capitalizeFirstChar( obj.PortType ), ":",  ...
                            num2str( obj.PortNumber ), " ",  ...
                            getString( message( "slreportgen:report:SystemIO:properties" ) ) );
                    end

                    target = mlreportgen.utils.normalizeLinkID( objID + "Summary" );
                    titleLink = mlreportgen.dom.InternalLink( target, titleStr );



                    rptr = this.DetailsReporter.copy(  );
                    rptr.Object = ioHandle;
                    rptr.LinkTarget = mlreportgen.utils.normalizeLinkID( objID );
                    rptr.PropertyTable.Title = titleLink;
                    content{ objIdx } = rptr;
                end
            else
                content = [  ];
            end

        end

    end

    methods ( Access = private )
        function val = getSource( this, ioHandle, portHandle )


            if this.IsBlockDiagram

                if strcmp( get_param( this.ObjectPath, "LoadExternalInput" ), "off" )
                    val = [  ];
                else


                    inputs = get_param( this.ObjectPath, "ExternalInput" );
                    inputs = strsplit( inputs, [ " ", "," ] );


                    portNum = str2double( get_param( ioHandle, "Port" ) );
                    val = inputs( portNum );
                    val = val{ 1 };


                    elemVal = get_param( ioHandle, "Element" );
                    if ~isempty( elemVal )
                        val = strcat( val, ".", elemVal );
                    end
                end

                if strcmp( val, "[]" )
                    val = "(unconnected)";
                end
            else

                line = get_param( portHandle, "line" );
                if line ==  - 1
                    val = "(unconnected)";
                else

                    srcPort = get_param( line, "NonVirtualSrcPorts" );

                    if isscalar( srcPort )

                        val = createSrcOrDstLink( this, srcPort, true );
                    else

                        nSrc = numel( srcPort );
                        val = clone( this.ListFormatter );
                        for k = 1:nSrc
                            srcLink = createSrcOrDstLink( this, srcPort( k ), true );
                            append( val, srcLink );
                        end
                    end

                end
            end
        end

        function val = getDestination( this, ioHandle, portHandle )



            if this.IsBlockDiagram


                portNum = get_param( ioHandle, "Port" );
                val = get_param( this.ObjectPath, "OutputSaveName" );
                val = strcat( val, "{", portNum, "}" );



                elemVal = get_param( ioHandle, "Element" );
                if ~isempty( elemVal )
                    val = strcat( val, ".", elemVal );
                end
            else

                line = get_param( portHandle, "line" );
                if line ==  - 1
                    val = "(unconnected)";
                else

                    dstPort = get_param( line, "NonVirtualDstPorts" );

                    if isscalar( dstPort )


                        val = createSrcOrDstLink( this, dstPort, false );
                    else

                        nDst = numel( dstPort );
                        val = clone( this.ListFormatter );
                        for k = 1:nDst
                            dstLink = createSrcOrDstLink( this, dstPort( k ), false );
                            append( val, dstLink );
                        end
                    end

                end
            end
        end

        function link = createSrcOrDstLink( ~, port, isSource )

            blk = get_param( port, "Parent" );

            str = getfullname( blk );

            numPorts = get_param( blk, "Ports" );
            if isSource
                numPorts = numPorts( 2 );
            else
                numPorts = numPorts( 1 );
            end
            if numPorts > 1
                portNum = get_param( port, "PortNumber" );
                str = str + " (Port " + num2str( portNum ) + ")";
            end

            link = mlreportgen.dom.InternalLink( slreportgen.utils.getObjectID( blk ), str );
        end


        function tblRptr = createTable( this, rpt, props, tableTitle, tableData, reporter )

            if ~isempty( tableData )
                if ~this.ShowEmptyColumns

                    empty = cellfun( @isempty, tableData );
                    emptyCols = all( empty, 1 );
                    tableData( :, emptyCols ) = [  ];
                    props( emptyCols ) = [  ];
                end

                tbl = mlreportgen.dom.FormalTable( props, tableData );

                title = strrep( tableTitle, newline, " " );

                tblRptr = copy( reporter );
                tblRptr.Content = tbl;
                tblRptr.LinkTarget = mlreportgen.utils.normalizeLinkID( title );
                appendTitle( tblRptr, title );

                titleReporter = getTitleReporter( tblRptr );
                titleReporter.TemplateSrc = this;

                if isChapterNumberHierarchical( this, rpt )
                    titleReporter.TemplateName = "SystemIOHierNumberedTitle";
                else
                    titleReporter.TemplateName = "SystemIONumberedTitle";
                end
                tblRptr.Title = titleReporter;
            else
                tblRptr = [  ];
            end
        end
    end

    methods ( Hidden )
        function templatePath = getDefaultTemplatePath( ~, rpt )
            path = slreportgen.report.SystemIO.getClassFolder(  );
            templatePath =  ...
                mlreportgen.report.ReportForm.getFormTemplatePath(  ...
                path, rpt.Type );
        end

    end


    methods ( Access = protected, Hidden )
        result = openImpl( reporter, impl, varargin )
    end


    methods ( Static )
        function path = getClassFolder(  )
            [ path ] = fileparts( mfilename( 'fullpath' ) );
        end


        function template = createTemplate( templatePath, type )
            path = slreportgen.report.SystemIO.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function classFile = customizeReporter( toClasspath )
            classFile = mlreportgen.report.ReportForm.customizeClass(  ...
                toClasspath, "slreportgen.report.SystemIO" );
        end

    end
end


function val = getPortBlockProperty( blk, prop )

blkProp = strip( extractAfter( prop, "Block" ) );
if blkProp == ""
    val = mlreportgen.dom.InternalLink( slreportgen.utils.getObjectID( blk ), get_param( blk, "Name" ) );
else
    try
        val = get_param( blk, blkProp );
        if ~isempty( val ) && ~isscalar( val )
            val = mlreportgen.utils.toString( val );
        end
    catch
        val = "";
    end
end
end

