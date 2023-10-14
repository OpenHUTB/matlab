classdef ( Sealed )GridToGridMapper < FunctionApproximation.internal.gridcreator.GridMapper

    properties ( SetAccess = private )
        GridMapperStrategy FunctionApproximation.internal.gridcreator.GridMapperStrategy = FunctionApproximation.internal.gridcreator.RoundingGridMapperStrategy.empty(  );
        KeyGrid( 1, : )double
        ValueGrid( 1, : )double
    end

    methods
        function this = GridToGridMapper( gridMapperStrategy )
            arguments
                gridMapperStrategy = FunctionApproximation.internal.gridcreator.RoundingGridMapperStrategy( 'previous' );
            end
            this.GridMapperStrategy = gridMapperStrategy;
        end

        function setKeyGrid( this, grid )
            this.KeyGrid = grid;
        end

        function setValueGrid( this, grid )
            this.ValueGrid = grid;
        end

        function constructMap( this )
            this.GridMapperStrategy.mapGrid( this.KeyGrid, this.ValueGrid );
        end

        function indices = getIndices( this, keyPair )
            indices = this.GridMapperStrategy.getIndices( keyPair );
        end

        function values = getValues( this, keyPair )
            indices = this.GridMapperStrategy.getIndices( keyPair );
            values = this.ValueGrid( indices );
        end

        function indices = getKeyGridIndicesWithMapping( this )
            indices = this.GridMapperStrategy.getKeyGridIndicesWithMapping(  );
        end
    end
end

