classdef BlockResult < slreportgen.finder.DiagramElementResult

    properties ( SetAccess = { ?slreportgen.finder.DiagramElementResult, ?mlreportgen.finder.Result } )
        BlockPath = string.empty(  );
    end

    methods
        function h = BlockResult( varargin )
            h = h@slreportgen.finder.DiagramElementResult( varargin{ : } );
            initBlockPath( h );
        end

        function title = getDefaultSummaryTableTitle( this, options )

            arguments
                this
                options.TypeSpecificTitle( 1, 1 )logical = true
            end

            if options.TypeSpecificTitle
                title = strcat( this.Type, " Block ",  ...
                    getString( message( "slreportgen:report:SummaryTable:properties" ) ) );
            else
                title = strcat( "Block ",  ...
                    string( getString( message( "slreportgen:report:SummaryTable:properties" ) ) ) );
            end

        end

        function props = getDefaultSummaryProperties( this, options )
            arguments
                this
                options.TypeSpecificProperties( 1, 1 )logical = true
            end

            if options.TypeSpecificProperties
                handle = slreportgen.utils.getSlSfHandle( this.Object );

                blockParams = slreportgen.utils.getSimulinkObjectParameters( handle, 'Block' );
                props = [ "Name", string( blockParams( : )' ) ];
            else


                props = [ "Name", "Block Type", "Parent" ];
            end
        end
    end

    methods ( Access = protected )
        function initObject( h )
            mustBeNonempty( h.Object );
            obj = slreportgen.utils.getSlSfHandle( h.Object );
            if ~isValidSlObject( slroot, obj ) || ~strcmp( get( obj, 'Type' ), 'block' )
                error( message( "slreportgen:finder:error:mustBeSimulinkBlock" ) );
            end
            h.Object = obj;
        end

        function initType( h )
            if isempty( h.Type )
                obj = h.Object;
                h.Type = get_param( obj, 'BlockType' );
            end
        end

        function initBlockPath( h )
            if isempty( h.BlockPath )
                h.BlockPath = replace( h.DiagramPath + "/" + h.Name, newline, " " );
            end
        end
    end
end

