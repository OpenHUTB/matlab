classdef CFunction < slreportgen.report.Reporter

    properties

        Object = [  ];

        IncludeObjectProperties( 1, 1 )logical = true;

        IncludeSymbols( 1, 1 )logical = true;

        IncludeOutputCode( 1, 1 )logical = true;

        IncludeStartCode( 1, 1 )logical = true;

        IncludeInitializeConditionsCode( 1, 1 )logical = true;


        IncludeTerminateCode( 1, 1 )logical = true;

        ObjectPropertiesReporter;

        SymbolsReporter;

        CodeTitleFormatter;

        CodeFormatter;
    end

    properties ( Access = private )

        ObjectHandle;
    end

    methods
        function this = CFunction( varargin )
            if ( nargin == 1 )
                varargin = [ { "Object" }, varargin ];
            end
            this = this@slreportgen.report.Reporter( varargin{ : } );





            p = inputParser;




            p.KeepUnmatched = true;




            addParameter( p, 'TemplateName', "CFunction" );
            addParameter( p, 'Object', [  ] );

            para = mlreportgen.dom.Paragraph;
            para.StyleName = "CFunctionCodeTitle";
            addParameter( p, 'CodeTitleFormatter', para );

            para = mlreportgen.dom.Preformatted;
            para.StyleName = "CFunctionCode";
            addParameter( p, 'CodeFormatter', para );

            symbolTbl = mlreportgen.report.BaseTable(  );
            symbolTbl.TableStyleName = "CFunctionSymbolsTable";
            addParameter( p, 'SymbolsReporter', symbolTbl );

            objProps = slreportgen.report.SimulinkObjectProperties;
            objProps.PropertyTable.TableStyleName = "CFunctionSymbolsTable";
            addParameter( p, 'ObjectPropertiesReporter', objProps );


            parse( p, varargin{ : } );



            results = p.Results;
            this.TemplateName = results.TemplateName;
            this.ObjectPropertiesReporter = results.ObjectPropertiesReporter;
            this.CodeTitleFormatter = results.CodeTitleFormatter;
            this.CodeFormatter = results.CodeFormatter;
            this.SymbolsReporter = results.SymbolsReporter;
            this.ObjectPropertiesReporter = results.ObjectPropertiesReporter;
        end

        function set.ObjectPropertiesReporter( this, value )


            mustBeA( value, "slreportgen.report.SimulinkObjectProperties" );


            mustBeScalarOrEmpty( value );

            this.ObjectPropertiesReporter = value;
        end

        function set.CodeTitleFormatter( this, value )


            mustBeA( value, "mlreportgen.dom.Paragraph" );


            mustBeScalarOrEmpty( value );

            this.CodeTitleFormatter = value;
        end

        function set.CodeFormatter( this, value )



            mustBeA( value, "mlreportgen.dom.Paragraph" );


            mustBeScalarOrEmpty( value );

            this.CodeFormatter = value;
        end

        function set.SymbolsReporter( this, value )


            mustBeA( value, "mlreportgen.report.BaseTable" );


            mustBeScalarOrEmpty( value );

            this.SymbolsReporter = value;
        end

        function impl = getImpl( this, rpt )
            arguments
                this( 1, 1 )
                rpt( 1, 1 ){ validateReport( this, rpt ) }
            end

            if isempty( this.Object )
                error( message( "slreportgen:report:error:noSourceObjectSpecified", class( this ) ) );
            else

                objHandle = slreportgen.utils.getSlSfHandle( this.Object );
                if ~strcmpi( get_param( objHandle, "Type" ), "block" ) ||  ...
                        ~strcmpi( get_param( objHandle, "blocktype" ), "CFunction" )
                    error( message( "slreportgen:report:error:invalidCFunctionBlock" ) );
                end
                this.ObjectHandle = objHandle;

                if isempty( this.LinkTarget )

                    this.LinkTarget = slreportgen.utils.getObjectID( this.Object );
                end


                impl = getImpl@slreportgen.report.Reporter( this, rpt );
            end
        end
    end

    methods ( Access = { ?mlreportgen.report.ReportForm, ?slreporten.report.CFunction } )
        function content = getObjectProperties( this, ~ )


            content = [  ];

            if this.IncludeObjectProperties


                content = copy( this.ObjectPropertiesReporter );
                content.Object = this.ObjectHandle;



                if isempty( content.Properties )

                    dialogParam = slreportgen.utils.getSimulinkObjectParameters( this.ObjectHandle, 'Block' );

                    toRemove = { 'OutputCode', 'TerminateCode', 'StartCode', 'InitializeConditionsCode', 'SymbolSpec' };
                    dialogParam = setdiff( dialogParam, toRemove );

                    dialogParam = [ dialogParam;{ 'Description' } ];
                    content.Properties = dialogParam;
                end
            end
        end

        function content = getOutputCodeTitle( this, rpt )%#ok<INUSD>


            content = [  ];

            if this.IncludeOutputCode && ~isempty( get_param( this.ObjectHandle, "OutputCode" ) )

                blkName = mlreportgen.utils.normalizeString( getfullname( this.ObjectHandle ) );
                titleText = blkName ...
                    + " " + getString( message( "slreportgen:report:CFunction:outputCode" ) );
                titleObj = mlreportgen.dom.Text( titleText );

                content = clone( this.CodeTitleFormatter );
                append( content, titleObj );
            end
        end

        function content = getOutputCode( this, ~ )


            content = [  ];

            if this.IncludeOutputCode

                script = deblank( get_param( this.ObjectHandle, "OutputCode" ) );
                if ~isempty( script )

                    content = clone( this.CodeFormatter );
                    append( content, script );
                end
            end
        end

        function content = getStartCodeTitle( this, ~ )


            content = [  ];

            if this.IncludeStartCode && ~isempty( get_param( this.ObjectHandle, "StartCode" ) )

                blkName = mlreportgen.utils.normalizeString( getfullname( this.ObjectHandle ) );
                titleText = blkName ...
                    + " " + getString( message( "slreportgen:report:CFunction:startCode" ) );
                titleObj = mlreportgen.dom.Text( titleText );

                content = clone( this.CodeTitleFormatter );
                append( content, titleObj );
            end
        end

        function content = getStartCode( this, ~ )


            content = [  ];

            if this.IncludeStartCode

                script = deblank( get_param( this.ObjectHandle, "StartCode" ) );
                if ~isempty( script )

                    content = clone( this.CodeFormatter );
                    append( content, script );
                end
            end
        end

        function content = getInitConditionsCodeTitle( this, ~ )


            content = [  ];

            if this.IncludeInitializeConditionsCode && ~isempty( get_param( this.ObjectHandle, "InitializeConditionsCode" ) )

                blkName = mlreportgen.utils.normalizeString( getfullname( this.ObjectHandle ) );
                titleText = blkName ...
                    + " " + getString( message( "slreportgen:report:CFunction:initConditionsCode" ) );
                titleObj = mlreportgen.dom.Text( titleText );

                content = clone( this.CodeTitleFormatter );
                append( content, titleObj );
            end
        end

        function content = getInitConditionsCode( this, ~ )


            content = [  ];

            if this.IncludeInitializeConditionsCode

                script = deblank( get_param( this.ObjectHandle, "InitializeConditionsCode" ) );
                if ~isempty( script )

                    content = clone( this.CodeFormatter );
                    append( content, script );
                end
            end
        end

        function content = getTerminateCodeTitle( this, ~ )


            content = [  ];

            if this.IncludeTerminateCode && ~isempty( get_param( this.ObjectHandle, "TerminateCode" ) )

                blkName = mlreportgen.utils.normalizeString( getfullname( this.ObjectHandle ) );
                titleText = blkName ...
                    + " " + getString( message( "slreportgen:report:CFunction:terminateCode" ) );
                titleObj = mlreportgen.dom.Text( titleText );

                content = clone( this.CodeTitleFormatter );
                append( content, titleObj );
            end
        end

        function content = getTerminateCode( this, ~ )


            content = [  ];

            if this.IncludeTerminateCode

                script = deblank( get_param( this.ObjectHandle, "TerminateCode" ) );
                if ~isempty( script )

                    content = clone( this.CodeFormatter );
                    append( content, script );
                end
            end
        end

        function content = getFunctionSymbols( this, rpt )


            content = [  ];

            if this.IncludeSymbols

                symbolSpec = get_param( this.ObjectHandle, 'SymbolSpec' );
                symbolSpec = symbolSpec.Symbols;
                nSyms = numel( symbolSpec );

                if nSyms > 0

                    props = { getString( message( "Simulink:CustomCode:PortSpec_ArgName" ) ),  ...
                        getString( message( "Simulink:CustomCode:PortSpec_Scope" ) ),  ...
                        getString( message( "Simulink:CustomCode:PortSpec_Label" ) ),  ...
                        getString( message( "Simulink:CustomCode:PortSpec_Type" ) ),  ...
                        getString( message( "Simulink:CustomCode:PortSpec_Size" ) ),  ...
                        getString( message( "Simulink:CustomCode:PortSpec_Index" ) ) };


                    nProps = numel( props );
                    symData = cell( nSyms, nProps );

                    for symIdx = 1:nSyms

                        symData{ symIdx, 1 } = symbolSpec( symIdx ).Name;
                        symData{ symIdx, 2 } = symbolSpec( symIdx ).Scope;
                        symData{ symIdx, 4 } = symbolSpec( symIdx ).Type;
                        symData{ symIdx, 5 } = symbolSpec( symIdx ).Size;

                        switch symbolSpec( symIdx ).Scope
                            case "Persistent"
                                symData{ symIdx, 3 } = "-";
                                symData{ symIdx, 6 } = "-";
                            case "Constant"
                                symData{ symIdx, 3 } = symbolSpec( symIdx ).Label;
                                symData{ symIdx, 6 } = "-";
                            otherwise
                                symData{ symIdx, 3 } = symbolSpec( symIdx ).Label;
                                symData{ symIdx, 6 } = symbolSpec( symIdx ).PortNumber;
                        end
                    end


                    content = copy( this.SymbolsReporter );
                    ft = mlreportgen.dom.FormalTable( props, symData );
                    content.Content = ft;


                    blkName = mlreportgen.utils.normalizeString( getfullname( this.ObjectHandle ) );
                    content.appendTitle( blkName + " " ...
                        + getString( message( "slreportgen:report:CFunction:symbolsTable" ) ) );
                    if mlreportgen.report.Reporter.isInlineContent( content.Title )
                        titleReporter = getTitleReporter( content );
                        titleReporter.TemplateSrc = this;

                        if isChapterNumberHierarchical( this, rpt )
                            titleReporter.TemplateName = 'CFunctionHierNumberedTitle';
                        else
                            titleReporter.TemplateName = 'CFunctionNumberedTitle';
                        end
                        content.Title = titleReporter;
                    end

                end
            end
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
            path = slreportgen.report.CFunction.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function classfile = customizeReporter( toClasspath )
            classfile = mlreportgen.report.ReportForm.customizeClass( toClasspath,  ...
                "slreportgen.report.CFunction" );
        end
    end

end

