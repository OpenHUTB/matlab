function destroyElement( dataModel, parameterSpace, ~ )




R36
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
% Decoded using De-pcode utility v1.2 from file /tmp/tmpD2o09f.p.
% Please follow local copyright laws when handling this file.

