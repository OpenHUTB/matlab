function destroyElement( dataModel, parameterSpace, ~ )

arguments
    dataModel( 1, 1 )mf.zero.Model
    parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
    ~
end

txn = dataModel.beginTransaction(  );

parentParameterSpace = parameterSpace.Container;
childParameterSpaces = parameterSpace.ParameterSpaces.toArray(  );
for childParameterSpace = childParameterSpaces
    parentParameterSpace.ParameterSpaces.add( childParameterSpace );
end

parameterSpace.destroy(  );

txn.commit(  );

simulink.multisim.internal.updateDesignStudyNumSimulations( parentParameterSpace );
end
