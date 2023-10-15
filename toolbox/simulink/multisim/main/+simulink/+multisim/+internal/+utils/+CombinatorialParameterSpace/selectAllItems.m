function selectAllItems( dataModel, combinatorialParameterSpace, ~ )

arguments
    dataModel( 1, 1 )mf.zero.Model
    combinatorialParameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
    ~
end

txn = dataModel.beginTransaction(  );
childParameterSpaces = combinatorialParameterSpace.ParameterSpaces.toArray(  );
for parameterSpace = childParameterSpaces
    parameterSpace.SelectedForRun = true;
end
txn.commit(  );

simulink.multisim.internal.updateDesignStudyNumSimulations( combinatorialParameterSpace );
end

