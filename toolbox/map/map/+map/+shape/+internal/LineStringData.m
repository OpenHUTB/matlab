classdef LineStringData < map.shape.internal.HomogeneousData

    properties
        NumVertexSequences uint32 = 0
        IndexOfLastVertex( 1, : )uint32 = [  ]
        RingType( 1, : )uint8 = [  ]
    end


    methods ( Access = protected )
        function data = defaultObject( ~ )
            data = map.shape.internal.LineStringData;
        end
    end


    methods
        function geometry = geometry( ~ )
            geometry = "line";
        end


        function type = geometryType( ~ )
            type = uint8( 2 );
        end


        function data = LineStringData( sz )









            arguments
                sz = [ 1, 1 ];
            end
            data.NumVertices = zeros( sz, 'uint32' );
            data.NumVertexSequences = zeros( sz, 'uint32' );
        end


        function data = fromStructInput( data, S,  ...
                vertexCoordinateField1, vertexCoordinateField2 )

            data.NumVertices = S.NumVertices;
            data.NumVertexSequences = S.NumVertexSequences;
            data.IndexOfLastVertex = S.IndexOfLastVertex;
            data.RingType = S.RingType;
            data.VertexCoordinate1 = S.( vertexCoordinateField1 );
            data.VertexCoordinate2 = S.( vertexCoordinateField2 );
        end


        function S = toStructOutput( data,  ...
                vertexCoordinateField1, vertexCoordinateField2 )



            S = struct(  ...
                "NumVertexSequences", [  ],  ...
                "NumVertices", [  ],  ...
                "IndexOfLastVertex", [  ],  ...
                "RingType", [  ],  ...
                "Coordinate1", [  ],  ...
                "Coordinate2", [  ],  ...
                "GeometryType", [  ] );

            sz = size( data.NumVertices );
            S.GeometryType = geometryType( data ) + zeros( sz, "uint8" );
            S.NumVertexSequences = data.NumVertexSequences;
            S.NumVertices = data.NumVertices;
            S.IndexOfLastVertex = data.IndexOfLastVertex;
            S.RingType = data.RingType;
            S.( vertexCoordinateField1 ) = data.VertexCoordinate1;
            S.( vertexCoordinateField2 ) = data.VertexCoordinate2;
        end


        function data = fromNumericVectors( data, v1, v2 )



            [ first, last ] = internal.map.findFirstLastNonNan( v1 );
            n = isnan( v1 );
            data.VertexCoordinate1 = v1( ~n );
            data.VertexCoordinate2 = v2( ~n );
            data.NumVertices = length( data.VertexCoordinate1 );
            data.IndexOfLastVertex = cumsum( last' - first' + 1 );
            m = length( data.IndexOfLastVertex );
            data.NumVertexSequences = uint32( m );
            data.RingType = zeros( 1, m, "uint8" );
        end


        function data = fromCellArrays( data, c1, c2 )







            n = zeros( size( c1 ), "uint32" );
            data.NumVertexSequences = n;
            data.NumVertices = n;
            for k = 1:numel( c1 )
                [ first, last ] = internal.map.findFirstLastNonNan( c1{ k } );
                data.NumVertexSequences( k ) = numel( first );
                data.NumVertices( k ) = sum( last' - first' + 1 );
            end




            m = sum( data.NumVertexSequences, "all" );
            data.IndexOfLastVertex = zeros( 1, m, "uint32" );
            data.RingType = zeros( 1, m, "uint8" );
            v = zeros( 1, sum( data.NumVertices, "all" ) );
            data.VertexCoordinate1 = v;
            data.VertexCoordinate2 = v;
            ei = 0;
            ev = 0;
            for k = 1:numel( c1 )
                v1 = c1{ k };
                v2 = c2{ k };
                if ~isempty( v1 )
                    [ first, last ] = internal.map.findFirstLastNonNan( v1 );
                    c = cumsum( last' - first' + 1 );
                    si = ei + 1;
                    ei = ei + length( c );
                    data.IndexOfLastVertex( si:ei ) = c;
                    n = isnan( v1 );
                    v1( n ) = [  ];
                    v2( n ) = [  ];
                    sv = ev + 1;
                    ev = ev + c( end  );
                    data.VertexCoordinate1( sv:ev ) = v1;
                    data.VertexCoordinate2( sv:ev ) = v2;
                end
            end
        end


        function [ c1, c2 ] = toCellArrays( data )







            sz = size( data.NumVertexSequences );
            c1 = cell( sz );
            c2 = cell( sz );
            es = cumsum( data.NumVertexSequences( : )' );
            ss = 1 + [ 0, es( 1:end  - 1 ) ];
            ec = cumsum( data.NumVertices( : )' );
            sc = 1 + [ 0, ec( 1:end  - 1 ) ];
            for k = 1:numel( c1 )
                indexOfLastVertex = data.IndexOfLastVertex( ss( k ):es( k ) );
                [ v1, v2 ] = map.shape.internal.LineStringData.insertNanDelimiters(  ...
                    data.VertexCoordinate1( sc( k ):ec( k ) ),  ...
                    data.VertexCoordinate2( sc( k ):ec( k ) ),  ...
                    indexOfLastVertex );
                c1{ k } = v1;
                c2{ k } = v2;
            end
        end


        function tf = isSelfConsistent( data )

            arguments
                data( 1, 1 )map.shape.internal.Data
            end
            tf = isequal( size( data.NumVertexSequences ),  ...
                size( data.NumVertices ) ) ...
                && isequal( sum( data.NumVertexSequences( : ) ),  ...
                length( data.IndexOfLastVertex ), length( data.RingType ) ) ...
                && isequal( sum( data.NumVertices( : ) ),  ...
                length( data.VertexCoordinate1 ),  ...
                length( data.VertexCoordinate2 ) );
        end


        function data = transposeArray( data )
            arguments
                data( 1, 1 )map.shape.internal.Data
            end
            if isvector( data.NumVertices )
                data.NumVertices = transpose( data.NumVertices );
                data.NumVertexSequences = transpose( data.NumVertexSequences );
            else
                data = transposeArray@map.shape.internal.Data( data );
            end
        end


        function data = catArray( dim, dataIn )
            arguments
                dim( 1, 1 )double{ mustBeInteger, mustBePositive }
            end
            arguments( Repeating )
                dataIn( 1, 1 )map.shape.internal.Data
            end




            numVertices = cellfun( @( obj )obj.NumVertices, dataIn, "UniformOutput", false );
            numVertices = cat( dim, numVertices{ : } );
            if dim > 1 || iscolumn( numVertices )

                data = dataIn{ 1 }.defaultObject(  );
                data.NumVertices = numVertices;
                n = cellfun( @( obj )obj.NumVertexSequences, dataIn, "UniformOutput", false );
                data.NumVertexSequences = cat( dim, n{ : } );
                ilv = cellfun( @( obj )obj.IndexOfLastVertex, dataIn, "UniformOutput", false );
                data.IndexOfLastVertex = horzcat( ilv{ : } );
                rt = cellfun( @( obj )obj.RingType, dataIn, "UniformOutput", false );
                data.RingType = horzcat( rt{ : } );
                c1 = cellfun( @( obj )obj.VertexCoordinate1, dataIn, "UniformOutput", false );
                c2 = cellfun( @( obj )obj.VertexCoordinate2, dataIn, "UniformOutput", false );
                data.VertexCoordinate1 = horzcat( c1{ : } );
                data.VertexCoordinate2 = horzcat( c2{ : } );
            else








                arrayIn = cellfun( @( obj )split( obj ), dataIn, "UniformOutput", false );
                data = merge( cat( dim, arrayIn{ : } ) );
            end
        end


        function data = reshapeArray( data, sz )
            arguments
                data( 1, 1 )map.shape.internal.Data
                sz( 1, : )cell
            end
            data.NumVertexSequences = reshape( data.NumVertexSequences, sz{ : } );
            data.NumVertices = reshape( data.NumVertices, sz{ : } );
        end


        function data = parenReferenceArray( data, subs )
            if ~isemptyArray( data )
                [ numParts, indexOfLastVertex, ringType ] = parenReferenceParts( data, subs );
                [ numVertices, c1, c2 ] = parenReferenceVertices( data, subs );
                data.NumVertexSequences = numParts;
                data.IndexOfLastVertex = indexOfLastVertex;
                data.RingType = ringType;
                data.NumVertices = numVertices;
                data.VertexCoordinate1 = c1;
                data.VertexCoordinate2 = c2;
            end
        end


        function data = parenDeleteArray( data, subs )
            [ numParts, indexOfLastVertex, ringType ] = parenDeleteParts( data, subs );
            [ nvertices, c1, c2 ] = parenDeleteVertices( data, subs );
            data.NumVertexSequences = numParts;
            data.IndexOfLastVertex = indexOfLastVertex;
            data.RingType = ringType;
            data.NumVertices = nvertices;
            data.VertexCoordinate1 = c1;
            data.VertexCoordinate2 = c2;
        end
    end


    methods ( Access = protected )
        function array = split( data )



            arguments
                data( 1, 1 )map.shape.internal.Data
            end
            sz = num2cell( size( data.NumVertices ) );
            if isempty( data.NumVertices )
                array = data.empty( sz{ : } );
            else
                array( sz{ : } ) = data.defaultObject(  );
            end



            ev = 0;
            for k = 1:numel( array )
                n = data.NumVertices( k );
                sv = ev + 1;
                ev = ev + n;
                array( k ).NumVertices = n;
                array( k ).VertexCoordinate1 = data.VertexCoordinate1( sv:ev );
                array( k ).VertexCoordinate2 = data.VertexCoordinate2( sv:ev );
            end

            ei = 0;
            for k = 1:numel( array )
                n = data.NumVertexSequences( k );
                si = ei + 1;
                ei = ei + n;
                array( k ).NumVertexSequences = n;
                array( k ).IndexOfLastVertex = data.IndexOfLastVertex( si:ei );
                array( k ).RingType = data.RingType( si:ei );
            end
        end


        function data = merge( array )




            assert( all( arrayfun( @( obj )isscalar( obj.NumVertices ), array ), "all" ) )

            data = array.defaultObject(  );
            n = zeros( size( array ), "uint32" );
            data.NumVertices = n;
            data.NumVertexSequences = n;
            for k = 1:numel( array )
                data.NumVertices( k ) = array( k ).NumVertices;
                data.NumVertexSequences( k ) = array( k ).NumVertexSequences;
            end



            n = sum( data.NumVertices, "all" );
            v = zeros( 1, n );
            data.VertexCoordinate1 = v;
            data.VertexCoordinate2 = v;
            ev = 0;
            for k = 1:numel( array )
                sv = ev + 1;
                ev = ev + data.NumVertices( k );
                data.VertexCoordinate1( sv:ev ) = array( k ).VertexCoordinate1;
                data.VertexCoordinate2( sv:ev ) = array( k ).VertexCoordinate2;
            end

            n = sum( data.NumVertexSequences, "all" );
            data.IndexOfLastVertex = zeros( 1, n, "uint32" );
            data.RingType = zeros( 1, n, "uint8" );
            ei = 0;
            for k = 1:numel( array )
                si = ei + 1;
                ei = ei + data.NumVertexSequences( k );
                data.IndexOfLastVertex( si:ei ) = array( k ).IndexOfLastVertex;
                data.RingType( si:ei ) = array( k ).RingType;
            end
        end
    end


    methods ( Access = private )
        function [ numParts, indexOfLastVertex, ringType ] = parenReferenceParts( data, subs )
            numParts = data.NumVertexSequences( subs{ : } );
            [ s, e ] = map.shape.internal.HomogeneousData.startAndEnd( data.NumVertexSequences, subs );
            sSub = 1;
            m = sum( numParts, "all" );
            indexOfLastVertex = zeros( 1, m, "uint32" );
            ringType = zeros( 1, m, "uint8" );
            for k = 1:length( e )
                ilvk = data.IndexOfLastVertex( 1, s( k ):e( k ) );
                eSub = sSub + length( ilvk ) - 1;
                indexOfLastVertex( 1, sSub:eSub ) = ilvk;
                ringType( 1, sSub:eSub ) = data.RingType( 1, s( k ):e( k ) );
                sSub = eSub + 1;
            end
        end


        function [ numParts, indexOfLastVertex, ringType ] = parenDeleteParts( data, subs )
            numParts = data.NumVertexSequences;
            numParts( subs{ : } ) = [  ];
            remove = map.shape.internal.HomogeneousData.removalIndex( data.NumVertexSequences, subs );
            indexOfLastVertex = data.IndexOfLastVertex;
            indexOfLastVertex( remove ) = [  ];
            ringType = data.RingType;
            ringType( remove ) = [  ];
        end
    end


    methods
        function [ vertexData, stripData, shapeIndices ] = lineStripData( data )















            arguments
                data( 1, 1 )map.shape.internal.Data
            end
            if isempty( data.NumVertexSequences ) || numel( data.VertexCoordinate1 ) < 2
                vertexData = zeros( 0, 2 );
                stripData = zeros( 1, 0, "uint32" );
                shapeIndices = zeros( 1, 0, "uint32" );
            else
                vertexData = [ data.VertexCoordinate1( : ), data.VertexCoordinate2( : ) ];
                c = data.IndexOfLastVertex;
                if isscalar( data.NumVertexSequences )

                    m = sum( diff( [ 0, c ] ) - 1 );
                    shapeIndices = ones( 1, m, "uint32" );
                else

                    n = sum( data.NumVertexSequences( : ) );
                    shapeIndices = zeros( 1, 2 * n, "uint32" );
                    p = uint32( 0 );
                    e = 0;
                    ei = 0;
                    for k = 1:numel( data.NumVertexSequences )
                        n = data.NumVertexSequences( k );
                        if n > 0
                            s = e + 1;
                            e = e + n;
                            m = sum( diff( [ 0, c( s:e ) ] ) - 1 );
                            si = ei + 1;
                            ei = ei + m;
                            shapeIndices( si:ei ) = k;
                            c( s:e ) = c( s:e ) + p;
                            p = c( e );
                        end
                    end
                    shapeIndices( :, ( ei + 1 ):end  ) = [  ];
                end
                stripData = uint32( [ 1, 1 + c ] );
            end
        end


        function dataOut = clipToPolygon( dataIn, polygon )











            arguments
                dataIn( 1, 1 )map.shape.internal.LineStringData
                polygon( 1, 1 )polyshape
            end

            dataOut = map.shape.internal.LineStringData;
            dataOut.NumVertexSequences = zeros( size( dataIn.NumVertexSequences ), "uint32" );
            dataOut.NumVertices = zeros( size( dataIn.NumVertices ), "uint32" );
            dataOut.IndexOfLastVertex = zeros( 1, ceil( 1.1 * length( dataIn.IndexOfLastVertex ) ), "uint32" );



            vertexCoordinateAllocation = zeros( 1, ceil( 1.1 * sum( dataIn.NumVertices( : ) ) ) );
            dataOut.VertexCoordinate1 = vertexCoordinateAllocation;
            dataOut.VertexCoordinate2 = vertexCoordinateAllocation;



            eii = 0;
            eio = 0;
            ei = 0;
            eo = 0;
            for k = 1:numel( dataIn.NumVertexSequences )

                numSequencesOut = 0;
                numVerticesOut = 0;
                numSequencesIn = dataIn.NumVertexSequences( k );
                sii = eii + 1;
                eii = eii + numSequencesIn;
                indexOfLastVertexIn = dataIn.IndexOfLastVertex( sii:eii );
                lineStringLength = diff( [ 0, indexOfLastVertexIn ] );
                for j = 1:numSequencesIn

                    si = ei + 1;
                    ei = ei + lineStringLength( j );
                    x = dataIn.VertexCoordinate1( si:ei );
                    y = dataIn.VertexCoordinate2( si:ei );
                    if isscalar( x )

                        tf = isinterior( polygon, x, y );
                        x = x( tf );
                        y = y( tf );
                    else


                        in = intersect( polygon, [ x( : ), y( : ) ] );
                        x = in( :, 1 )';
                        y = in( :, 2 )';
                    end
                    if isempty( x )

                    elseif ~any( isnan( x ) )

                        sio = eio + 1;
                        eio = eio + 1;
                        dataOut.IndexOfLastVertex( sio:eio ) = numVerticesOut + length( x );
                        so = eo + 1;
                        eo = eo + length( x );
                        dataOut.VertexCoordinate1( so:eo ) = x;
                        dataOut.VertexCoordinate2( so:eo ) = y;
                        numSequencesOut = numSequencesOut + 1;
                        numVerticesOut = numVerticesOut + length( x );
                    else



                        [ first, last ] = internal.map.findFirstLastNonNan( x );
                        indexOfLastVertexOut = numVerticesOut + cumsum( last' - first' + 1 );
                        sio = eio + 1;
                        eio = eio + length( indexOfLastVertexOut );
                        dataOut.IndexOfLastVertex( sio:eio ) = indexOfLastVertexOut;
                        n = isnan( x );
                        x( n ) = [  ];
                        y( n ) = [  ];
                        so = eo + 1;
                        eo = eo + length( x );
                        dataOut.VertexCoordinate1( so:eo ) = x;
                        dataOut.VertexCoordinate2( so:eo ) = y;
                        numSequencesOut = numSequencesOut + length( indexOfLastVertexOut );
                        numVerticesOut = numVerticesOut + length( x );
                    end
                end
                dataOut.NumVertexSequences( k ) = numSequencesOut;
                dataOut.NumVertices( k ) = numVerticesOut;
            end


            dataOut.IndexOfLastVertex( eio + 1:end  ) = [  ];
            dataOut.VertexCoordinate1( eo + 1:end  ) = [  ];
            dataOut.VertexCoordinate2( eo + 1:end  ) = [  ];
            dataOut.RingType = zeros( size( dataOut.IndexOfLastVertex ), "uint8" );
        end
    end


    methods ( Static, Access = protected )
        function [ v1, v2 ] = insertNanDelimiters( c1, c2, indexOfLastVertex )
            numVertices = length( c1 );
            if numVertices >= 1
                len = numVertices + length( indexOfLastVertex ) - 1;
                v1 = NaN( 1, len );
                v2 = NaN( 1, len );
                sk = 1;
                sn = 1;
                for ek = indexOfLastVertex
                    en = sn + ( ek - sk );
                    v1( sn:en ) = c1( sk:ek );
                    v2( sn:en ) = c2( sk:ek );
                    sk = ek + 1;
                    sn = en + 2;
                end
            else
                v1 = double.empty( 1, 0 );
                v2 = double.empty( 1, 0 );
            end
        end
    end
end


