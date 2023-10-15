function addCombinatorialParameterSpace( dataModel, parameterSpace, ~, combinationType, selectedParameterIDs )

arguments
    dataModel( 1, 1 )mf.zero.Model
    parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
    ~
    combinationType( 1, 1 )simulink.multisim.mm.design.ParameterSpaceCombinationType
    selectedParameterIDs = {  }
end

txn = dataModel.beginTransaction(  );
combiParameterSpace = simulink.multisim.mm.design.CombinatorialParameterSpace( dataModel );
combiParameterSpace.CombinationType = combinationType;
combiParameterSpace.Label = simulink.multisim.internal.utils.CombinatorialParameterSpace.getUniqueParameterLabel(  ...
    parameterSpace, message( "multisim:SetupGUI:ParameterSetLabelPrefix" ).getString(  ) );

if isempty( selectedParameterIDs )
    parentParameter = parameterSpace;
else
    parentParameter = dataModel.findElement( selectedParameterIDs{ 1 } ).Container;
    for parameterIndex = 1:length( selectedParameterIDs )
        selectedParameter = dataModel.findElement( selectedParameterIDs{ parameterIndex } );

        combiParameterSpace.ParameterSpaces.add( selectedParameter );
    end
end

parentParameter.ParameterSpaces.add( combiParameterSpace );
txn.commit(  );

simulink.multisim.internal.updateDesignStudyNumSimulations( combiParameterSpace );
end


