function addBlockParameter( dataModel, parameterSpace, ~, selectedParameterIDs )





R36
dataModel( 1, 1 )mf.zero.Model
parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
~
selectedParameterIDs( 1, : )cell = {  }
end 

txn = dataModel.beginTransaction(  );
singleParameterSpace = simulink.multisim.mm.design.SingleParameterSpace( dataModel );
blockParam = simulink.multisim.mm.design.BlockParameter( dataModel );
singleParameterSpace.Label = simulink.multisim.internal.utils.CombinatorialParameterSpace.getUniqueParameterLabel(  ...
parameterSpace, message( "multisim:SetupGUI:BlockParameterLabelPrefix" ).getString(  ) );
singleParameterSpace.Type = blockParam;
singleParameterSpace.ValueType = simulink.multisim.mm.design.ParameterValueType.Explicit;
singleParameterSpace.Values = simulink.multisim.mm.design.ExplicitValues( dataModel );

parentParameter = simulink.multisim.internal.utils.CombinatorialParameterSpace.getParentFromSelectedParameters(  ...
dataModel, parameterSpace, selectedParameterIDs );
parentParameter.ParameterSpaces.add( singleParameterSpace );
txn.commit(  );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpH9KaZB.p.
% Please follow local copyright laws when handling this file.

