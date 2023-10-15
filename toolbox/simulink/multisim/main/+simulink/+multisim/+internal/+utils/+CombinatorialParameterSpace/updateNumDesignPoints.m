function updateNumDesignPoints( parameterSpace )

arguments
    parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
end

import simulink.multisim.mm.design.ParameterSpaceCombinationType
parameterSpaceArray = parameterSpace.ParameterSpaces.toArray(  );

if isempty( parameterSpaceArray )
    numDesignPoints = 0;
    parameterSpace.ErrorText = "";
else
    switch parameterSpace.CombinationType
        case "Exhaustive"
            numDesignPointsArray = [ parameterSpaceArray.NumDesignPoints ];
            anyPositiveDesignPoints = max( numDesignPointsArray ) > 0;
            if anyPositiveDesignPoints
                designPointsWithPositiveValues = numDesignPointsArray( numDesignPointsArray > 0 );
                numDesignPoints = prod( designPointsWithPositiveValues );
            else
                numDesignPoints = 0;
            end
            parameterSpace.ErrorText = "";

        case "Sequential"
            numDesignPoints = parameterSpaceArray( 1 ).NumDesignPoints;

            numDesignPointsArray = [ parameterSpaceArray.NumDesignPoints ];
            unequalNumDesignPointsArray = ( numDesignPointsArray ~= numDesignPointsArray( 1 ) );
            firstInvalidParameterSpaceIndex = find( unequalNumDesignPointsArray, 1 );
            if ~isempty( firstInvalidParameterSpaceIndex )
                firstInvalidParameterSpace = parameterSpaceArray( firstInvalidParameterSpaceIndex );
                parameterSpace.ErrorText = string( message( "multisim:SetupGUI:UnequalSimsInSequentialCombination",  ...
                    firstInvalidParameterSpace.Label, parameterSpaceArray( 1 ).Label ) );
            else
                parameterSpace.ErrorText = "";
            end

        case "SimulationGroup"
            numDesignPointsArray = [ parameterSpaceArray.NumDesignPoints ];
            selectedForRunArray = [ parameterSpaceArray.SelectedForRun ];
            numDesignPoints = sum( numDesignPointsArray( selectedForRunArray ) );
            parameterSpace.ErrorText = "";
    end
end
parameterSpace.NumDesignPoints = numDesignPoints;
end
