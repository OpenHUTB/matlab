classdef MATLABVariableResult < mlreportgen.finder.Result





























    properties ( SetAccess = protected )



        Object = [  ];
    end

    properties ( SetAccess = { ?mlreportgen.finder.Result, ?mlreportgen.finder.MATLABVariableFinder } )











        Location






        FileName = string.empty(  );
    end

    properties ( Access = { ?mlreportgen.finder.Result, ?mlreportgen.finder.MATLABVariableFinder } )

        WhosInfo;
    end

    properties ( Access = private )
        Reporter = [  ];
    end

    properties




        Tag;
    end

    methods ( Access = { ?mlreportgen.finder.MATLABVariableFinder } )
        function this = MATLABVariableResult( varargin )
            this = this@mlreportgen.finder.Result( varargin{ : } );
            mustBeNonempty( this.Object );
        end
    end

    methods
        function reporter = getReporter( this )







            if isempty( this.Reporter )
                reporter = mlreportgen.report.MATLABVariable(  );
                reporter.Variable = this.Object;
                reporter.Location = this.Location;
                reporter.FileName = this.FileName;
                reporter.LinkTarget = genLinkID( this );
                this.Reporter = reporter;
            else
                reporter = this.Reporter;
            end
        end

        function value = getVariableValue( this )








            reporter = getReporter( this );
            value = getVariableValue( reporter );
        end

        function title = getDefaultSummaryTableTitle( ~, varargin )






            title = string( getString( message( "mlreportgen:report:SummaryTable:variables" ) ) );
        end

        function props = getDefaultSummaryProperties( ~, varargin )











            props = [ "Name", "Size", "Bytes", "Class" ];
        end

        function propVals = getPropertyValues( this, propNames, options )

            arguments
                this
                propNames string
                options.ReturnType( 1, 1 )string ...
                    { mustBeMember( options.ReturnType, [ "native", "string", "DOM" ] ) } = "native"
            end

            varVal = getVariableValue( this );
            varInfo = this.WhosInfo;


            returnRawValue = strcmp( options.ReturnType, "native" );

            nProps = numel( propNames );
            propVals = cell( 1, nProps );


            for idx = 1:nProps
                prop = propNames( idx );
                normProp = strrep( prop, " ", "" );



                switch lower( normProp )
                    case "value"
                        val = varVal;
                    case "name"
                        val = this.Object;
                    otherwise
                        if isprop( this, prop )

                            val = this.( prop );
                        elseif isfield( varInfo, lower( normProp ) )

                            val = varInfo.( lower( normProp ) );
                        else
                            try
                                val = varVal.( normProp );
                            catch ME %#ok<NASGU>
                                val = "N/A";
                            end
                        end
                end


                if ~returnRawValue && ~isempty( val )
                    val = mlreportgen.utils.toString( val );
                end
                propVals{ idx } = val;
            end
        end

        function id = getReporterLinkTargetID( this )






            id = getReporterLinkTargetID@mlreportgen.finder.Result( this );
            if isempty( id )
                id = genLinkID( this );
            end
        end

        function presenter = getPresenter( this )%#ok<MANU>
            presenter = [  ];
        end
    end

    methods ( Access = private )
        function id = genLinkID( this )
            id = strcat( "MATLABVariable-", this.Object,  ...
                "-", this.Location );
            if ~isempty( this.FileName )
                id = id + "-" + this.FileName;
            end
            id = mlreportgen.utils.normalizeLinkID( id );
        end
    end

end


