classdef SummaryTable < mlreportgen.report.Reporter & mlreportgen.report.internal.SummaryTableBase

















































































    properties



        FinderResults










        Title{ mlreportgen.report.validators.mustBeInline } = [  ];














        Properties string = string.empty;












        IncludeLinks( 1, 1 )logical = true;







        ShowEmptyColumns( 1, 1 )logical = false;












        TableReporter
    end

    methods
        function this = SummaryTable( varargin )
            if nargin == 1
                results = varargin{ 1 };
                varargin = { "FinderResults", results };
            end

            this = this@mlreportgen.report.Reporter( varargin{ : } );


            p = inputParser;




            p.KeepUnmatched = true;




            addParameter( p, "TemplateName", "SummaryTable" );

            baseTable = mlreportgen.report.BaseTable(  );
            baseTable.TableStyleName = "SummaryTableTable";
            addParameter( p, "TableReporter", baseTable );


            parse( p, varargin{ : } );


            results = p.Results;
            this.TemplateName = results.TemplateName;
            this.TableReporter = results.TableReporter;
        end

        function set.FinderResults( this, value )

            mustBeVector( value );

            try

                mustBeA( value( 1 ), "mlreportgen.finder.Result" );

                mustBeA( value, class( value( 1 ) ) );
            catch ME
                error( message( "mlreportgen:report:error:invalidResultObjects" ) );
            end

            this.FinderResults = value;
        end

        function set.TableReporter( this, value )


            mustBeNonempty( value );

            mustBeA( value, "mlreportgen.report.BaseTable" );


            mustBeScalarOrEmpty( value );

            this.TableReporter = value;
        end

        function impl = getImpl( this, rpt )
            arguments
                this( 1, 1 )
                rpt( 1, 1 ){ validateReport( this, rpt ) }
            end

            if isempty( this.FinderResults )

                error( message( "mlreportgen:report:error:invalidResultObjects" ) );
            end



            impl = getImpl@mlreportgen.report.Reporter( this, rpt );
        end
    end

    methods ( Access = { ?mlreportgen.report.internal.SummaryTableBase } )
        function [ title, props, content ] = getSummaryTablesData( this, rpt )







            results = this.FinderResults;
            title = "";


            props = this.Properties;
            if isempty( props ) || isequal( props, "" )
                props = getDefaultSummaryProperties( results( 1 ) );
            else


                props = props( : )';
            end


            if props ~= ""

                title = getDefaultSummaryTableTitle( results( 1 ) );

                [ props, content ] = getSingleSummaryTableData( this, rpt, results, props, 'Title', false, [  ] );
                props = { props };
                content = { content };
            end
        end
    end

    methods ( Hidden )
        function templatePath = getDefaultTemplatePath( ~, rpt )
            path = mlreportgen.report.SummaryTable.getClassFolder(  );
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
            path = mlreportgen.report.SummaryTable.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function classFile = customizeReporter( toClasspath )
            classFile = mlreportgen.report.ReportForm.customizeClass(  ...
                toClasspath, "mlreportgen.report.SummaryTable" );
        end
    end
end

