function deselectAllItems( dataModel, combinatorialParameterSpace, ~ )


R36
dataModel( 1, 1 )mf.zero.Model
combinatorialParameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
~
end 

txn = dataModel.beginTransaction(  );
childParameterSpaces = combinatorialParameterSpace.ParameterSpaces.toArray(  );
for parameterSpace = childParameterSpaces
parameterSpace.SelectedForRun = false;
end 
txn.commit(  );

simulink.multisim.internal.updateDesignStudyNumSimulations( combinatorialParameterSpace );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpmwYVwz.p.
% Please follow local copyright laws when handling this file.

