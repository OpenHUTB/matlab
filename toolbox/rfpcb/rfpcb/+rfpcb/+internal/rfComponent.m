classdef rfComponent < em.PCBStructures &  ...
        em.EmStructures &  ...
        em.MeshGeometry &  ...
        em.SharedPortAnalysis &  ...
        rfpcb.SurfaceAnalysis

    properties
        Name
        Revision
        BoardShape
        FeedDiameter
        ViaDiameter
        FeedViaModel = 'strip'
    end


    properties ( Access = protected )
        privateSubstrate = dielectric( 'Name', 'Air' )
    end


    properties ( Dependent, SetObservable )
        Layers
        BoardLength
        BoardWidth
        BoardThickness
        FeedLocations
        ViaLocations
        FeedVoltage
        FeedPhase
    end


    properties ( Dependent, Access = protected )
        NumFeeds
    end


    properties ( GetAccess = public, SetAccess = protected )

        FeedWidth
        FeedLocation
    end


    properties ( Hidden, Dependent )
        MetalLayers
        Substrate
        LayerZCoordinates
        NumFeedViaModelSides = 6
    end


    properties ( Hidden )
        IsRefiningPolygon
        PortConnections = containers.Map
    end


    methods
        function obj = rfComponent( varargin )
            parseRfComponent( obj, varargin{ : } );
            obj.SolverStruct.Source.type = 'voltage';
        end
    end


    methods
        function set.Name( obj, propVal )
            if ~( ( ischar( propVal ) || isStringScalar( propVal ) ) && strlength( propVal ) > 0 )
                error( message( 'rfpcb:rfpcberrors:ExpectedNonEmpty' ) );
            end
            if isPropertyChanged( obj, obj.Name, propVal )
                obj.Name = propVal;
            end
        end


        function set.Revision( obj, propVal )
            validateattributes( propVal, { 'char', 'string' }, { 'nonempty', 'scalartext' } );
            if isPropertyChanged( obj, obj.Revision, propVal )
                obj.Revision = propVal;
            end
        end


        function set.BoardShape( obj, propVal )
            if ~isa( propVal, 'antenna.Shape' )
                error( message( 'rfpcb:rfpcberrors:InvalidPcbStackBoardShapeProperty' ) );
            else
                obj.BoardShape = propVal;
                if isa( propVal, 'antenna.Rectangle' )
                    obj.privateSubstrate.Shape = 'box';
                    obj.privateSubstrate.Length = obj.BoardShape.Length;
                    obj.privateSubstrate.Width = obj.BoardShape.Width;
                elseif isa( propVal, 'antenna.Circle' )
                    obj.privateSubstrate.Shape = 'cylinder';
                    obj.privateSubstrate.Radius = obj.BoardShape.Radius;
                elseif isa( propVal, 'antenna.Polygon' )
                    obj.privateSubstrate.Shape = 'polyhedron';
                    obj.privateSubstrate.Vertices = obj.BoardShape.Vertices;
                end

                setHasStructureChanged( obj );
            end
        end


        function set.BoardLength( obj, propVal )
            validateattributes( propVal, { 'numeric' },  ...
                { 'scalar', 'nonempty', 'real', 'nonnan', 'positive' },  ...
                'set.BoardLength', '''BoardLength'' of rfComponent' );
            if isPropertyChanged( obj, obj.BoardLength, propVal )
                obj.protectedBoardLength = propVal;
            end
        end

        function propVal = get.BoardLength( obj )
            propVal = obj.protectedBoardLength;
        end

        function set.BoardWidth( obj, propVal )
            validateattributes( propVal, { 'numeric' },  ...
                { 'scalar', 'nonempty', 'real', 'nonnan', 'positive' },  ...
                'set.BoardWidth', '''BoardWidth'' of rfComponent' );
            if isPropertyChanged( obj, obj.BoardWidth, propVal )
                obj.protectedBoardWidth = propVal;
            end
        end

        function propVal = get.BoardWidth( obj )
            propVal = obj.protectedBoardWidth;
        end

        function set.BoardThickness( obj, propVal )
            validateattributes( propVal, { 'numeric' },  ...
                { 'scalar', 'nonempty', 'real', 'nonnan', 'positive' },  ...
                'set.BoardThickness', '''BoardThickness'' of rfComponent' );
            if isPropertyChanged( obj, obj.BoardThickness, propVal )
                obj.protectedBoardThickness = propVal;


                if ~isempty( obj.Layers )
                    dielectricLayerIndx = cellfun( @( x )isa( x, 'dielectric' ), obj.Layers );
                    nSub = numel( dielectricLayerIndx( dielectricLayerIndx == 1 ) );
                else
                    nSub = 0;
                end
                if nSub <= 1
                    obj.privateSubstrate.Thickness = propVal;
                end
            end
        end

        function propVal = get.BoardThickness( obj )
            propVal = obj.protectedBoardThickness;
        end

        function set.Substrate( obj, propVal )






            if ~isequal( obj.privateSubstrate, propVal )

                temp = copy( propVal );


                checkDielectricMaterialDimensions( temp );

                flipPcbSubstrateProperties( obj, temp );

                setPcbSubstrateDimensions( obj, temp );

                obj.privateSubstrate = temp;

                obj.privateSubstrate.Parent = obj;

                setHasStructureChanged( obj );

                clearGeometryData( obj );
            end
        end

        function propVal = get.Substrate( obj )
            propVal = obj.privateSubstrate;
        end








        function set.Layers( obj, propVal )
            if ~isempty( propVal )
                tf = all( cellfun( @( x )isa( x, 'antenna.Shape' ) || isa( x, 'dielectric' ), propVal ) );
                if tf


                    metalLayerIndx = cellfun( @( x )isa( x, 'antenna.Shape' ), propVal );
                    dielectricLayerIndx = cellfun( @( x )isa( x, 'dielectric' ), propVal );



                    nMetal = numel( metalLayerIndx( metalLayerIndx == 1 ) );
                    nSub = numel( dielectricLayerIndx( dielectricLayerIndx == 1 ) );
                    if ( nMetal > 2 ) && ~( nSub >= 2 )
                        error( message( 'rfpcb:rfpcberrors:PcbStackLayersGreaterThan2NeedDielectricDefined' ) );
                    end
                    obj.protectedLayers = propVal;
                    obj.MetalLayers = propVal( metalLayerIndx );

                    if nSub == 0
                        obj.Substrate = dielectric( 'Air' );
                        obj.Substrate.Thickness = obj.BoardThickness;
                    else
                        checkDielectricVsBoardThickness( obj, propVal, metalLayerIndx, dielectricLayerIndx );
                        tempSub = propVal( dielectricLayerIndx );
                        subNames = cellfun( @( x )( x.Name ), tempSub, 'UniformOutput', false );
                        subEpsilonR = cellfun( @( x )( x.EpsilonR ), tempSub );
                        subLossTangent = cellfun( @( x )( x.LossTangent ), tempSub );
                        subThickness = cellfun( @( x )( x.Thickness ), tempSub );
                        pcbSub = dielectric( 'Name', subNames,  ...
                            'EpsilonR', subEpsilonR,  ...
                            'LossTangent', subLossTangent,  ...
                            'Thickness', subThickness );
                        if isa( obj.BoardShape, 'antenna.Rectangle' )
                            pcbSub.Shape = 'box';
                        elseif isa( obj.BoardShape, 'antenna.Circle' )
                            pcbSub.Shape = 'cylinder';
                        elseif isa( obj.BoardShape, 'antenna.Polygon' )
                            pcbSub.Shape = 'polyhedron';
                        end
                        obj.Substrate = pcbSub;
                    end
                    setHasStructureChanged( obj );
                else
                    error( message( 'rfpcb:rfpcberrors:InvalidPcbStackLayersProperty' ) );
                end
            end
        end

        function propVal = get.Layers( obj )
            propVal = obj.protectedLayers;
        end

        function set.MetalLayers( obj, propVal )
            obj.protectedMetalLayers = propVal;
        end

        function propVal = get.MetalLayers( obj )
            propVal = obj.protectedMetalLayers;
        end

        function set.FeedLocations( obj, propVal )
            validateattributes( propVal, { 'numeric' },  ...
                { 'nonempty', 'real', 'finite', 'nonnan' } );

            if ( ~isequal( size( propVal, 2 ), 3 ) ) && ( ~isequal( size( propVal, 2 ), 4 ) ) && ( ~isequal( size( propVal, 2 ), 6 ) )
                error( message( 'rfpcb:rfpcberrors:InvalidPcbStackFeedLocationsProperty' ) );
            end
            checkFeedLocationLayerOnMetal( obj, propVal );
            if isPropertyChanged( obj, obj.FeedLocations, propVal )
                obj.protectedFeedLocations = propVal;

                obj.modifiedFeedLocations = calculateModifiedFeedLocations( obj );
                setTotalArrayElems( obj, size( propVal, 1 ) )
            end
        end

        function propVal = get.FeedLocations( obj )
            propVal = obj.protectedFeedLocations;
        end

        function set.FeedDiameter( obj, propVal )
            if numel( propVal ) > 1
                N = numel( propVal );
                validateattributes( propVal, { 'numeric' },  ...
                    { 'nonempty', 'real', 'nonnan', 'finite', 'numel', N },  ...
                    'set.FeedDiameter', 'FeedDiameter'' of rfComponent' );
                for i = 1:N
                    obj.FeedDiameter( i ) = propVal( i );
                end
            else
                validateattributes( propVal, { 'numeric' },  ...
                    { 'scalar', 'nonempty', 'real', 'nonnan', 'positive' },  ...
                    'set.FeedDiameter', '''FeedDiameter'' of rfComponent' );
                if isPropertyChanged( obj, obj.FeedDiameter, propVal )
                    obj.FeedDiameter = propVal;
                end
            end
        end

        function set.ViaLocations( obj, propVal )
            validateattributes( propVal, { 'numeric' }, { 'real', 'finite', 'nonnan' } );
            if ~isempty( propVal )

                if ~isequal( size( propVal, 2 ), 4 )
                    error( message( 'rfpcb:rfpcberrors:InvalidPcbStackViaLocationsProperty' ) );
                end


                if ~all( propVal( :, 3 ) < propVal( :, 4 ) )
                    error( message( 'rfpcb:rfpcberrors:InvalidPcbStackViaLayerOrdering' ) );
                end
            end
            if ~isempty( propVal )
                checkViaLocationLayerOnMetal( obj, propVal );
            end
            if isPropertyChanged( obj, obj.ViaLocations, propVal )
                obj.protectedViaLocations = propVal;
            end
        end

        function propVal = get.ViaLocations( obj )
            propVal = obj.protectedViaLocations;
        end

        function set.ViaDiameter( obj, propVal )
            validateattributes( propVal, { 'numeric' },  ...
                { 'real', 'nonnan', 'positive' },  ...
                'set.ViaDiameter', '''ViaDiameter'' of rfComponent' );
            if isPropertyChanged( obj, obj.ViaDiameter, propVal )
                obj.ViaDiameter = propVal;
            end
        end

        function set.FeedVoltage( obj, propVal )

            numelements = obj.NumFeeds;

            if isscalar( propVal )
                validateattributes( propVal, { 'numeric' }, { 'vector', 'nonempty',  ...
                    'real', 'finite', 'nonnan', 'nonnegative' },  ...
                    class( obj ), 'FeedVoltage' );
            else
                validateattributes( propVal, { 'numeric' }, { 'vector', 'nonempty',  ...
                    'real', 'finite', 'nonnan', 'nonnegative',  ...
                    'numel', numelements }, class( obj ), 'FeedVoltage' );
            end

            if ~any( propVal )
                error( message( 'rfpcb:rfpcberrors:AllZeroAmplitudetaper' ) );
            end
            if isPropertyChanged( obj, obj.FeedVoltage, propVal )
                obj.protectedFeedVoltage = propVal;
                if numelements > 1
                    if isscalar( propVal )
                        setSourceVoltage( obj, propVal, numelements );
                    else
                        setSourceVoltage( obj, propVal );
                    end
                end
            end
        end

        function propVal = get.FeedVoltage( obj )
            propVal = obj.protectedFeedVoltage;
        end

        function set.FeedPhase( obj, propVal )

            numelements = obj.NumFeeds;

            if isscalar( propVal )
                validateattributes( propVal, { 'numeric' }, { 'vector', 'nonempty',  ...
                    'real', 'finite', 'nonnan', 'nonnegative' },  ...
                    class( obj ), 'FeedPhase' );
            else
                validateattributes( propVal, { 'numeric' }, { 'vector', 'nonempty',  ...
                    'real', 'finite', 'nonnan', 'nonnegative',  ...
                    'numel', numelements }, class( obj ), 'FeedPhase' );
            end
            if isPropertyChanged( obj, obj.FeedPhase, propVal )
                obj.protectedFeedPhase = propVal;
                if numelements > 1
                    if isscalar( propVal )
                        setPhaseShift( obj, propVal .* pi / 180, numelements );
                    else
                        setPhaseShift( obj, propVal .* pi / 180 );
                    end
                end
            end
        end

        function propVal = get.FeedPhase( obj )
            propVal = obj.protectedFeedPhase;
        end

        function propVal = get.FeedWidth( obj )
            propVal = obj.FeedWidth;
        end

        function set.FeedWidth( obj, propVal )
            obj.FeedWidth = propVal;
        end

        function propVal = get.FeedLocation( obj )
            propVal = calculateFeedLocation( obj );
            propVal = orientGeom( obj, propVal' )';
        end

        function propVal = get.NumFeeds( obj )
            propVal = size( obj.FeedLocations, 1 );
        end

        function propVal = get.LayerZCoordinates( obj )
            propVal = calculateLayerZCoords( obj );
        end

        function set.FeedViaModel( obj, propVal )
            validatestring( propVal, { 'strip', 'square', 'hexagon', 'octagon' } );
            obj.FeedViaModel = propVal;
            setHasStructureChanged( obj );
        end

        function propVal = get.NumFeedViaModelSides( obj )
            modelChoice = upper( string( obj.FeedViaModel ) );
            switch modelChoice
                case 'STRIP'
                    propVal = 1;
                case 'SQUARE'
                    propVal = 4;
                case 'HEXAGON'
                    propVal = 6;
                case 'OCTAGON'
                    propVal = 8;
            end
        end
    end

    methods
        function layout( obj )
            pcblayout( obj );
            title( 'PCB Component Layout' )
        end
    end


    methods ( Hidden )

        function [ edgeLength, growthRate ] = calculateMeshParams( obj, lambda )
            [ edgeLength, ~, growthRate ] = calcMeshParamsCore( obj, lambda );
        end

        function createGeometry( obj, varargin )

            numFeeds = obj.NumFeeds;
            numVias = size( obj.ViaLocations, 1 );
            if isscalar( obj.FeedVoltage )
                setSourceVoltage( obj, obj.FeedVoltage, numFeeds );
            else
                setSourceVoltage( obj, obj.FeedVoltage );
            end

            if isscalar( obj.FeedPhase )
                setPhaseShift( obj, obj.FeedPhase .* pi / 180, numFeeds );
            else
                setPhaseShift( obj, obj.FeedPhase .* pi / 180 );
            end


            for i = 1:numel( obj.MetalLayers )
                createGeometry( obj.MetalLayers{ i } );
                setFillAndHolePolygons( obj.MetalLayers{ i } );
            end


            temp = cellfun( @getGeometry, obj.MetalLayers, 'UniformOutput', false );



            layer_heights = calculateLayerZCoords( obj );


            if numel( temp ) > numel( layer_heights )
                error( message( 'rfpcb:rfpcberrors:PcbStackNumLayersGreaterThanSubstrate' ) );
            end


            feed_width = cylinder2strip( obj.FeedDiameter / 2 ) .* ones( 1, numFeeds );
            obj.FeedWidth = feed_width;





























            if isDielectricSubstrate( obj )
                [ SubVertices, SubPolygons, SubBoundaryEdges, SubBoundaryVertices ] = makeSubstrateGeometry( obj );
            else
                SubVertices = [  ];
                SubPolygons = [  ];
                SubBoundaryEdges = [  ];
                SubBoundaryVertices = [  ];
            end

            for i = 1:numel( temp )
                temp{ i }.BorderVertices( :, 3 ) = layer_heights( i );
                temp{ i }.BorderVertices = orientGeom( obj, temp{ i }.BorderVertices.' ).';
            end


            if ~isempty( obj.ViaLocations )


                checkViaLocationLayerOnMetal( obj, obj.ViaLocations );
                obj.modifiedViaLocations = calculateModifiedViaLocations( obj );
            else
                obj.modifiedViaLocations = [  ];
            end


            checkFeedLocationLayerOnMetal( obj, obj.FeedLocations );
            if isequal( size( obj.FeedLocations, 2 ), 4 )
                vias = [ obj.modifiedViaLocations;obj.modifiedFeedLocations ];
            else
                vias = obj.modifiedViaLocations;
            end

            viaHeight = findViaHeights( obj, vias, layer_heights );
            viaGeom = [  ];
            stackHeight = findPcbStackHeight( obj );
            [ ~, tf ] = checkEdgeFeed( obj );
            tv = [  ];
            if ~isempty( obj.ViaLocations )
                [ ~, tv ] = checkEdgeVia( obj );
            end

            for i = 1:size( vias, 1 )
                if i <= numVias
                    dia = obj.ViaDiameter;
                    if ~isempty( tv )
                        makeCylinderShape = ~tv( i );
                    else
                        makeCylinderShape = false;
                    end
                else
                    dia = obj.FeedDiameter;
                    makeCylinderShape = ~tf( i - numVias );
                end
                if makeCylinderShape
                    fl = vias( i, 3 ) > vias( i, 4 );
                    if fl
                        viaHeight( i ) = viaHeight( i ) *  - 1;
                    end
                    tempViaGeom{ i } = em.PCBStructures.makecylinder( dia / 2, viaHeight( i ), 50, [ vias( i, 1:2 ), layer_heights( vias( i, 4 ) ) ] );
                    g.BorderVertices = orientGeom( obj, tempViaGeom{ i }.vertices ).';
                    g.polygons = { tempViaGeom{ i }.faces };
                    g.BoundaryEdges = { tempViaGeom{ i }.BoundaryEdges };
                    g.doNotPlot = 0;
                    g.MaxFeatureSize = stackHeight;

                    g.SubstrateVertices = SubVertices;
                    g.SubstratePolygons = SubPolygons;
                    if ~isempty( SubBoundaryEdges )
                        g.SubstrateBoundary = SubBoundaryEdges;
                        g.SubstrateBoundaryVertices = SubBoundaryVertices;
                    end
                    viaGeom{ i } = g;
                end
            end


            if ~isempty( viaGeom )
                indx = cellfun( @( x )~isempty( x ), viaGeom );
                viaGeom = viaGeom( indx );
            end


            setFeedWidth( obj, feed_width );



            obj.MesherStruct.Geometry = [ temp, viaGeom ];
            obj.MesherStruct.Geometry{ 1 }.SubstrateVertices = SubVertices;
            obj.MesherStruct.Geometry{ 1 }.SubstratePolygons = SubPolygons;
            if ~isempty( SubBoundaryEdges )
                obj.MesherStruct.Geometry{ 1 }.SubstrateBoundary = SubBoundaryEdges;
                obj.MesherStruct.Geometry{ 1 }.SubstrateBoundaryVertices = SubBoundaryVertices;
            end
            saveLoad( obj );
            saveConductor( obj );
        end

        function meshGenerator( obj, varargin )


            createGeometry( obj );


            if isequal( size( obj.FeedLocations, 2 ), 4 )
                isProbeFed = true;
                Wf = obj.FeedDiameter * ones( obj.NumFeeds, 1 );
                Wv = obj.ViaDiameter * ones( size( obj.ViaLocations, 1 ), 1 );
                vias = [ obj.modifiedViaLocations, Wv;obj.modifiedFeedLocations, Wf ];
            else
                Wv = obj.ViaDiameter * size( obj.ViaLocations, 1 );
                vias = [ obj.modifiedViaLocations, Wv ];
                isProbeFed = false;
            end


            if ~isempty( obj.ViaLocations )
                [ ~, tv ] = checkEdgeVia( obj );
                isEdgeVia = tv;
            else
                isEdgeVia = false;
            end
            [ ~, tf ] = checkEdgeFeed( obj );
            isEdgeFed = tf;
            localConnModel = obj.FeedViaModel;



            if ( any( isEdgeFed ) || any( isEdgeVia ) ) && ( ~isa( obj.BoardShape, 'antenna.Rectangle' ) )
                if ~isEdgeFeedViaAlongXorY( obj )
                    error( message( 'rfpcb:rfpcberrors:InvalidFeedSpecifiedForPcbStackBoardShape' ) );
                end
            end


            if isequal( numel( obj.MetalLayers ), 1 ) || all( isEdgeFed )
                localConnModel = 'strip';
            end


            layer_heights = calculateLayerZCoords( obj );
            viaHeight = findViaHeights( obj, vias, layer_heights );

            tempMetalLayers = cellfun( @( x )copy( x ), obj.MetalLayers, 'UniformOutput', false );
            tr = cellfun( @( x )triangulation( x.InternalPolyShape ), tempMetalLayers, 'UniformOutput', false );
            for i = 1:numel( tr )
                p_temp{ i } = tr{ i }.Points;
            end

            p_tempchk = cellfun( @( x )x.', p_temp, 'UniformOutput', false );
            [ tf, ~, p_temp ] = isLayerWithinBoardLimits( obj, p_tempchk );
            if ~tf
                error( message( 'rfpcb:rfpcberrors:PcbStackLayersCrossBoardOutline' ) );
            end


            mesherInput.vias = vias;
            mesherInput.layer_heights = layer_heights;
            mesherInput.viaHeight = viaHeight;
            mesherInput.smoothing_iter = 10;
            mesherInput.refinecontours = false;
            mesherInput.EdgeConnStatus = [ { isProbeFed };{ isEdgeFed };{ isEdgeVia } ];
            mesherInput.ConnModel = localConnModel;

            Mesh = makeMetalDielectricMesh( obj, mesherInput );









            if ~isProbeFed && ~strcmpi( localConnModel, 'strip' )
                localConnModel = 'strip';
            elseif all( isEdgeFed ) && ~isequal( getNumFeedEdgesForSolidFeed( obj ), 1 )
                localConnModel = 'multi-strip';
            end


            setPcbComponentFeedType( obj, isEdgeFed, localConnModel, Mesh );

            saveMesh( obj, Mesh );

        end

        function setNumFeedEdgesForSolidFeed( obj, n )
            setNumFeedEdge( obj, n );
        end

        function n = getNumFeedEdgesForSolidFeed( obj )
            n = getNumFeedEdge( obj );
        end

        function rObj = superLoad( obj, s )
            if nargin > 1
                obj.Name = s.Name;
                obj.Revision = s.Revision;
                obj.BoardShape = s.BoardShape;
                obj.FeedDiameter = s.FeedDiameter;
                obj.ViaDiameter = s.ViaDiameter;
                obj.FeedViaModel = s.FeedViaModel;
                obj.IsRefiningPolygon = s.IsRefiningPolygon;
                rObj = superLoadPCBStructures( obj, s );
            end
        end
    end

    methods ( Access = protected )
        function group = getPropertyGroups( obj )
            title = '';
            propertyDisplayList = { 'Name', 'Revision', 'BoardShape',  ...
                'BoardThickness', 'Layers', 'FeedLocations', 'FeedDiameter',  ...
                'ViaLocations', 'ViaDiameter', 'FeedViaModel', 'FeedVoltage',  ...
                'FeedPhase', 'Conductor', 'Tilt', 'TiltAxis', 'Load' };
            group = objectProps( obj, propertyDisplayList, title );
        end

    end

    methods ( Static = true, Hidden )
        function r = loadobj( obj )
            if isobject( obj ) && isObjectFromCurrentVersion( obj )
                r = obj;
            else

                newpcbStack = rfComponent;

                r = superLoad( newpcbStack, obj );
            end
            r = loadobj@em.EmStructures( r );
        end
    end

    methods
        function S = sparameters( obj, freq, z0, options )
            arguments
                obj( 1, 1 )
                freq( 1, : ){ mustBeFinite, mustBeNonnegative }
                z0( 1, 1 ){ mustBeFinite, mustBePositive } = 50
                options.Behavioral( 1, 1 ){ mustBeNumericOrLogical } = false
            end
            validateattributes( freq, { 'double' }, { 'increasing' }, 2 )

            if options.Behavioral
                behavioralS = "rfpcb.internal.behavioral." + class( obj.Layers{ 1 } ) + "S";
                w = which( behavioralS );
                if isempty( w )
                    error( message( 'rfpcb:rfpcberrors:BehavioralUnsupported', class( obj.Layers{ 1 } ) ) )
                end
                S = feval( behavioralS, obj, freq, z0 );
            else
                S = sparameters@em.SharedPortAnalysis( obj, freq, z0 );
            end
        end
    end
end

