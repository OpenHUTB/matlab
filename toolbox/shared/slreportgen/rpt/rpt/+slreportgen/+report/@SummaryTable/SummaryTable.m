classdef SummaryTable < slreportgen.report.Reporter & mlreportgen.report.internal.SummaryTableBase
















































































    properties










        FinderResults










        Title{ mlreportgen.report.validators.mustBeInline } = [  ];














        Properties string = string.empty;









        SeparateTablesByType( 1, 1 )logical = true;












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

            this = this@slreportgen.report.Reporter( varargin{ : } );


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
                error( message( "slreportgen:report:error:invalidResultObjects" ) );
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

                error( message( "slreportgen:report:error:invalidResultObjects" ) );
            end



            impl = getImpl@slreportgen.report.Reporter( this, rpt );
        end
    end

    methods ( Access = { ?mlreportgen.report.internal.SummaryTableBase } )
        function [ titles, props, content ] = getSummaryTablesData( this, rpt )











            results = this.FinderResults;

            if this.SeparateTablesByType && isprop( results( 1 ), 'Type' )


                allResultTypes = [ results.Type ];
                types = unique( allResultTypes );
                nTypes = numel( types );



                content = cell( 1, nTypes );


                props = cell( 1, nTypes );


                titles = strings( 1, nTypes );
                for typeIdx = 1:nTypes
                    type = types( typeIdx );

                    typeResults = results( strcmp( type, allResultTypes ) );

                    [ typeTitle, typeProps, typeContent ] = compileAndGetSingleSummaryTableData( this, rpt, typeResults );
                    titles( typeIdx ) = typeTitle;
                    props{ typeIdx } = typeProps;
                    content{ typeIdx } = typeContent;
                end
            else


                [ titles, props, content ] = compileAndGetSingleSummaryTableData( this, rpt, this.FinderResults );
                props = { props };
                content = { content };
            end

        end

        function [ title, props, content ] = compileAndGetSingleSummaryTableData( this, rpt, results )





            srcMdls = [  ];

            try


                srcMdls = arrayfun( @( x )slreportgen.utils.getModelHandle( x.Object ), results );

                if numel( unique( srcMdls ) ) > 1



                    compileEachMdl = true;
                else


                    compileEachMdl = false;
                    compileModel( rpt, srcMdls( 1 ) );
                end
            catch ME %#ok<NASGU>



                compileEachMdl = false;
            end
            props = this.Properties;
            if isempty( props ) || isequal( props, "" )
                props = getDefaultSummaryProperties( results( 1 ), TypeSpecificProperties = this.SeparateTablesByType );
            else


                props = props( : )';
            end


            if props ~= ""

                title = getDefaultSummaryTableTitle( results( 1 ), TypeSpecificTitle = this.SeparateTablesByType );
                [ props, content ] = getSingleSummaryTableData( this, rpt, results, props, "Name", compileEachMdl, srcMdls );
            end
        end
    end

    methods ( Hidden )
        function templatePath = getDefaultTemplatePath( ~, rpt )
            path = slreportgen.report.SummaryTable.getClassFolder(  );
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
            path = slreportgen.report.SummaryTable.getClassFolder(  );
            template = mlreportgen.report.ReportForm.createFormTemplate(  ...
                templatePath, type, path );
        end

        function classFile = customizeReporter( toClasspath )
            classFile = mlreportgen.report.ReportForm.customizeClass(  ...
                toClasspath, "slreportgen.report.SummaryTable" );
        end
    end
end
