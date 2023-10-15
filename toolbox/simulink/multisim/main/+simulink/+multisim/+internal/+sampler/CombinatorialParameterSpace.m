classdef CombinatorialParameterSpace < simulink.multisim.internal.sampler.ParameterSpaceSampler
    properties ( Access = private )
        Samplers = simulink.multisim.internal.sampler.SingleParameterSpace.empty
    end

    methods
        function obj = CombinatorialParameterSpace( parameterSpace )
            arguments
                parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
            end

            obj = obj@simulink.multisim.internal.sampler.ParameterSpaceSampler( parameterSpace );

            parameterSpaces = parameterSpace.ParameterSpaces;
            for parameterSpaceIdx = 1:parameterSpaces.Size
                childParameterSpace = parameterSpaces( parameterSpaceIdx );
                childParameterSpaceType = childParameterSpace.StaticMetaClass.name;
                obj.Samplers( parameterSpaceIdx ) = simulink.multisim.internal.sampler.( childParameterSpaceType )( childParameterSpace );
            end
        end

        function numDesignPoints = getNumDesignPoints( obj )
            import simulink.multisim.mm.design.*

            if isempty( obj.ParameterSpace.ParameterSpaces.toArray(  ) )
                error( message( "multisim:SetupGUI:EmptyCombinatorialParameterSpace", obj.ParameterSpace.Label ) );
            end

            switch ( obj.ParameterSpace.CombinationType )
                case ParameterSpaceCombinationType.Exhaustive
                    numDesignPoints = obj.getNumDesignPointsFromLevels( arrayfun( @( x )getNumDesignPoints( x ), obj.Samplers ) );

                case ParameterSpaceCombinationType.Sequential
                    numDesignPoints = obj.getSequentialNumDesignPoints(  );

                case ParameterSpaceCombinationType.SimulationGroup
                    numDesignPoints = obj.getSimulationGroupNumDesignPoints(  );
            end
        end

        function designPoints = createDesignPoints( obj )
            import simulink.multisim.mm.design.*

            designPoints = [  ];
            switch ( obj.ParameterSpace.CombinationType )
                case ParameterSpaceCombinationType.Exhaustive
                    designPoints = obj.createDesignPointsForExhaustiveParameterSpace(  );

                case ParameterSpaceCombinationType.Sequential
                    designPoints = obj.createDesignPointsForSequentialParameterSpace(  );

                case ParameterSpaceCombinationType.SimulationGroup
                    designPoints = obj.createDesignPointsForSimulationGroupParameterSpace(  );
            end
        end

        function designPoint = createDesignPointAtIndex( obj, index )
            import simulink.multisim.mm.design.*

            switch ( obj.ParameterSpace.CombinationType )
                case ParameterSpaceCombinationType.Exhaustive
                    designPoint = obj.createDesignPointForExhaustiveParameterSpaceAtIndex( index );

                case ParameterSpaceCombinationType.Sequential
                    designPoint = obj.createDesignPointForSequentialParameterSpaceAtIndex( index );
            end
        end
    end

    methods ( Access = private )
        function designPoints = createDesignPointsForExhaustiveParameterSpace( obj )
            parameterSpaces = obj.ParameterSpace.ParameterSpaces;

            levels = arrayfun( @( x )getNumDesignPoints( x ), obj.Samplers );

            numDesignPoints = obj.getNumDesignPointsFromLevels( levels );
            designPoints( 1:numDesignPoints ) = simulink.multisim.internal.DesignPoint;

            numCycles = numDesignPoints;
            for parameterSpaceIdx = 1:parameterSpaces.Size
                childDesignPoints = obj.Samplers( parameterSpaceIdx ).createDesignPoints(  );

                numRepeats = numDesignPoints / numCycles;
                numCycles = numCycles / levels( parameterSpaceIdx );
                childDesignPointIndices = obj.createDesignPointIndices(  ...
                    levels( parameterSpaceIdx ), numRepeats, numCycles );

                for designPointIdx = 1:numDesignPoints
                    designPoints( designPointIdx ).ParameterSamples =  ...
                        [ designPoints( designPointIdx ).ParameterSamples, childDesignPoints( childDesignPointIndices( designPointIdx ) ).ParameterSamples ];
                end
            end
        end

        function designPoints = createDesignPointsForSequentialParameterSpace( obj )
            numDesignPoints = obj.Samplers( 1 ).getNumDesignPoints(  );
            parameterSpaces = obj.ParameterSpace.ParameterSpaces;

            designPoints( 1:numDesignPoints ) = simulink.multisim.internal.DesignPoint;
            for parameterSpaceIdx = 1:parameterSpaces.Size
                childDesignPoints = obj.Samplers( parameterSpaceIdx ).createDesignPoints(  );

                for designPointIdx = 1:numDesignPoints
                    designPoints( designPointIdx ).ParameterSamples =  ...
                        [ designPoints( designPointIdx ).ParameterSamples, childDesignPoints( designPointIdx ).ParameterSamples ];
                end
            end
        end

        function designPoints = createDesignPointsForSimulationGroupParameterSpace( obj )
            numDesignPoints = obj.getNumDesignPoints(  );
            designPoints( 1:numDesignPoints ) = simulink.multisim.internal.DesignPoint;

            designPointIdx = 1;
            for sampler = obj.Samplers
                if sampler.ParameterSpace.SelectedForRun
                    childDesignPoints = sampler.createDesignPoints(  );
                    designPoints( designPointIdx:designPointIdx + length( childDesignPoints ) - 1 ) = childDesignPoints;
                    designPointIdx = designPointIdx + length( childDesignPoints );
                end
            end
        end

        function numDesignPoints = getSequentialNumDesignPoints( obj )
            levels = arrayfun( @( x )getNumDesignPoints( x ), obj.Samplers );
            if isempty( levels )
                numDesignPoints = 0;
                return ;
            end

            unequalNumDesignPointsArray = ( levels ~= levels( 1 ) );
            firstInvalidParameterSpaceIndex = find( unequalNumDesignPointsArray, 1 );
            if ~isempty( firstInvalidParameterSpaceIndex )
                firstInvalidParameterSpace = obj.Samplers( firstInvalidParameterSpaceIndex ).ParameterSpace;
                error( message( "multisim:SetupGUI:UnequalSimsInSequentialCombination",  ...
                    firstInvalidParameterSpace.Label, obj.Samplers( 1 ).ParameterSpace.Label ) );
            end

            numDesignPoints = levels( 1 );
        end

        function numDesignPoints = getSimulationGroupNumDesignPoints( obj )
            parameterSpaceArray = obj.ParameterSpace.ParameterSpaces.toArray(  );
            numDesignPointsArray = arrayfun( @( x )getNumDesignPoints( x ), obj.Samplers );
            selectedForRunArray = [ parameterSpaceArray.SelectedForRun ];
            numDesignPoints = sum( numDesignPointsArray( selectedForRunArray ) );

            if ~isempty( parameterSpaceArray ) && ~any( selectedForRunArray )
                error( message( "multisim:SetupGUI:NoChildItemsSelectedForRun", obj.ParameterSpace.Label ) );
            end
        end

        function designPoint = createDesignPointForExhaustiveParameterSpaceAtIndex( obj, index )
            parameterSpaces = obj.ParameterSpace.ParameterSpaces;

            levels = arrayfun( @( x )x.getNumDesignPoints, obj.Samplers );

            numDesignPoints = obj.getNumDesignPointsFromLevels( levels );
            designPoint = simulink.multisim.internal.DesignPoint;

            numCycles = numDesignPoints;
            for parameterSpaceIdx = 1:parameterSpaces.Size
                numRepeats = numDesignPoints / numCycles;
                numCycles = numCycles / levels( parameterSpaceIdx );
                childDesignPointIndices = obj.createDesignPointIndices(  ...
                    levels( parameterSpaceIdx ), numRepeats, numCycles );

                childDesignPointIndex = childDesignPointIndices( index );
                childDesignPoint = obj.Samplers( parameterSpaceIdx ).createDesignPointAtIndex( childDesignPointIndex );

                designPoint.ParameterSamples =  ...
                    [ designPoint.ParameterSamples, childDesignPoint.ParameterSamples ];
            end
        end

        function designPoint = createDesignPointForSequentialParameterSpaceAtIndex( obj, index )
            parameterSpaces = obj.ParameterSpace.ParameterSpaces;

            designPoint = simulink.multisim.internal.DesignPoint;
            for parameterSpaceIdx = 1:parameterSpaces.Size
                childDesignPoints = obj.Samplers( parameterSpaceIdx ).createDesignPointAtIndex( index );

                designPoint.ParameterSamples =  ...
                    [ designPoints.ParameterSamples, childDesignPoints( index ).ParameterSamples ];
            end
        end
    end

    methods ( Static, Access = private )
        function designPointIndices = createDesignPointIndices( numPoints, numRepeats, numCycles )
            designPointIndices = 1:numPoints;
            designPointIndices = designPointIndices( ones( 1, numRepeats ), : );
            designPointIndices = designPointIndices( : );
            designPointIndices = designPointIndices( :, ones( 1, numCycles ) );
            designPointIndices = designPointIndices( : );
        end

        function numDesignPoints = getNumDesignPointsFromLevels( levels )
            if isempty( levels )
                numDesignPoints = 0;
            else
                numDesignPoints = prod( levels );
            end
        end
    end
end

