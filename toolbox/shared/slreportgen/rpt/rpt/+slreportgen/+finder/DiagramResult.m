classdef DiagramResult < mlreportgen.finder.Result
































    properties ( SetAccess = protected )



        Object = [  ];
    end

    properties ( SetAccess = { ?mlreportgen.finder.Result } )




        Name = string.empty(  );




        Type = string.empty(  );





        Path = string.empty(  );
    end

    properties





        Tag = [  ];
    end

    properties ( Access = private )
        m_dhid;
        m_parentElements = string.empty(  );
    end

    methods
        function h = DiagramResult( varargin )
            h = h@mlreportgen.finder.Result( varargin{ : } );
            initObject( h );
            initType( h );
            initName( h );
            initPath( h );
        end

        function reporter = getReporter( h )











            reporter = slreportgen.report.Diagram(  ...
                'Source', h.m_dhid );

            if ~isempty( h.Name )
                reporter.Snapshot.Caption =  ...
                    mlreportgen.utils.normalizeString( h.Name );
            end
        end

        function title = getDefaultSummaryTableTitle( this, options )












            arguments
                this
                options.TypeSpecificTitle( 1, 1 )logical = true
            end

            if options.TypeSpecificTitle
                objType = slreportgen.utils.getObjectType( this.Object );



                if strcmpi( objType, "Block" )
                    objType = "System";
                end
                title = strcat( objType, " ",  ...
                    getString( message( "slreportgen:report:SummaryTable:properties" ) ) );
            else
                title = strcat( "System ", getString( message( "slreportgen:report:SummaryTable:properties" ) ) );
            end

        end

        function props = getDefaultSummaryProperties( this, options )
















            arguments
                this
                options.TypeSpecificProperties( 1, 1 )logical = true
            end

            if options.TypeSpecificProperties
                objType = slreportgen.utils.getObjectType( this.Object );
                if isa( this.Object, "Stateflow.Object" )
                    props = slreportgen.utils.getStateflowObjectParameters( this.Object, objType );
                else



                    if strcmpi( objType, "Block" )
                        objType = "System";
                    end
                    props = slreportgen.utils.getSimulinkObjectParameters( this.Object, objType );
                end
                props = string( props );
                props = [ "Name", props( : )' ];
            else
                props = [ "Name", "Description" ];
            end
        end

        function propVals = getPropertyValues( this, propNames, options )
            arguments
                this
                propNames string
                options.ReturnType( 1, 1 )string ...
                    { mustBeMember( options.ReturnType, [ "native", "string", "DOM" ] ) } = "native"
            end

            returnRawValue = strcmp( options.ReturnType, "native" );
            returnDOMValue = strcmp( options.ReturnType, "DOM" );


            nProps = numel( propNames );
            propVals = cell( 1, nProps );
            isStateflow = isa( this.Object, "Stateflow.Object" );
            for idx = 1:nProps

                prop = strrep( propNames( idx ), " ", "" );

                if isprop( this, prop )

                    val = this.( prop );
                else

                    if isStateflow
                        val = slreportgen.utils.getStateflowObjectValue( this.Object, prop );
                    else
                        val = mlreportgen.utils.safeGet( this.Object, prop, 'get_param' );
                    end

                    if ~isempty( val )
                        val = val{ 1 };
                    end
                end

                if ~returnRawValue
                    nEntries = numel( val );
                    if nEntries > 1 && startsWith( class( val ), [ "Stateflow", "Simulink" ] )




                        valStrings = string.empty( 0, nEntries );
                        for valIdx = 1:nEntries
                            valStrings( valIdx ) = mlreportgen.utils.toString( val( valIdx ) );
                        end
                        if returnDOMValue

                            val = mlreportgen.dom.UnorderedList( valStrings );
                            val.StyleName = this.SummaryTableListStyle;
                        else
                            val = valStrings;
                        end
                    else
                        val = mlreportgen.utils.toString( val );
                    end

                end

                propVals{ idx } = val;
            end
        end

        function id = getReporterLinkTargetID( this )




            id = getReporterLinkTargetID@mlreportgen.finder.Result( this );
            if isempty( id )
                id = slreportgen.utils.getObjectID( this.Object );
            end
        end
    end

    methods ( Hidden )
        function presenter = getPresenter( h )%#ok<MANU>
            presenter = [  ];
        end
    end


    methods ( Access = protected )
        function initObject( h )
            mustBeNonempty( h.Object );
            hs = slreportgen.utils.HierarchyService;
            dhid = hs.getDiagramHID( h.Object );
            h.m_dhid = dhid;
            h.Object = slreportgen.utils.getSlSfHandle( dhid );
        end

        function initType( h )
            if isempty( h.Type )
                obj = slreportgen.utils.getSlSfObject( h.Object );
                h.Type = string( class( obj ) );
            end
        end

        function initName( h )
            if isempty( h.Name )
                obj = h.Object;
                try
                    name = string( get( obj, 'Name' ) ).replace( newline, " " );
                catch
                    name = "";
                end
                h.Name = name;
            end
        end

        function initPath( h )
            if isempty( h.Path )
                hs = slreportgen.utils.HierarchyService;
                h.Path = string( hs.getPath( h.m_dhid ) );
            end
        end

        function initParents( h )
            if isempty( h.Parents )
                hs = slreportgen.utils.HierarchyService;
                ehid = hs.getParent( h.m_dhid );
                if ~isempty( ehid )
                    phid = hs.getParent( ehid );
                    h.Parents = string( hs.getPath( phid ) );
                end
            end
        end
    end

    methods ( Hidden )
        function dhid = getDiagramHID( h )
            dhid = h.m_dhid;
        end
    end
end

