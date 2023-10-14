classdef Data




    methods ( Abstract )
        geometry = geometry( ~ )
        tf = isSelfConsistent( data )
        data = catArray( dim, dataIn )
        data = reshapeArray( data, sz )
        data = parenReferenceArray( data, subs )
        data = parenDeleteArray( data, subs )

        data = fromStructInput( data, S, vertexCoordinateField1, vertexCoordinateField2 )




























        S = toStructOutput( data, vertexCoordinateField1, vertexCoordinateField2 )


    end


    methods ( Abstract, Access = protected )
        array = split( data )
        data = merge( array )
    end


    methods
        function data = parenAssignArray( data, subs, rhs )


            dataArray = split( data );
            dataArray( subs{ : } ) = split( rhs );
            data = merge( dataArray );
        end


        function data = transposeArray( data )


            arguments
                data( 1, 1 )map.shape.internal.Data
            end
            dataArray = split( data );
            dataArray = transpose( dataArray );
            data = merge( dataArray );
        end


        function data = flipArray( data, dim )


            arguments
                data( 1, 1 )map.shape.internal.Data
                dim double{ mustBeScalarOrEmpty } = [  ]
            end
            dataArray = split( data );
            if isempty( dim )
                dataArray = flip( dataArray );
            else
                dataArray = flip( dataArray, dim );
            end
            data = merge( dataArray );
        end
    end
end


