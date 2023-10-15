function addVariable( dataModel, parameterSpace, ~, selectedParameterIDs )

arguments
    dataModel( 1, 1 )mf.zero.Model
    parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
    ~
    selectedParameterIDs( 1, : )cell = {  }
end

txn = dataModel.beginTransaction(  );
singleParameterSpace = simulink.multisim.mm.design.SingleParameterSpace( dataModel );
var = simulink.multisim.mm.design.Variable( dataModel );
singleParameterSpace.Label = simulink.multisim.internal.utils.CombinatorialParameterSpace.getUniqueParameterLabel(  ...
    parameterSpace, message( "multisim:SetupGUI:VariableLabelPrefix" ).getString(  ) );
singleParameterSpace.Type = var;
singleParameterSpace.ValueType = simulink.multisim.mm.design.ParameterValueType.Explicit;
singleParameterSpace.Values = simulink.multisim.mm.design.ExplicitValues( dataModel );

parentParameter = simulink.multisim.internal.utils.CombinatorialParameterSpace.getParentFromSelectedParameters(  ...
    dataModel, parameterSpace, selectedParameterIDs );
parentParameter.ParameterSpaces.add( singleParameterSpace );
txn.commit(  );
end
