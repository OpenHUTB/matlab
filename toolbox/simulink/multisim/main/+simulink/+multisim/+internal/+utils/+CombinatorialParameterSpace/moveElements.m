function moveElements( dataModel, targetParameterSpace, ~, sourceElementIDs )




R36
dataModel( 1, 1 )mf.zero.Model
targetParameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
~
sourceElementIDs( 1, : )string
end 

oldParent = [  ];
txn = dataModel.beginTransaction(  );
for elementID = sourceElementIDs
element = dataModel.findElement( elementID );

if isempty( oldParent )
oldParent = element.Container;
elseif oldParent ~= element.Container
simulink.multisim.internal.updateDesignStudyNumSimulations( oldParent );
oldParent = element.Container;
end 
targetParameterSpace.ParameterSpaces.add( element );
end 

simulink.multisim.internal.updateDesignStudyNumSimulations( oldParent );
newParent = element.Container;
simulink.multisim.internal.updateDesignStudyNumSimulations( newParent );
txn.commit(  );
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpv6qfFl.p.
% Please follow local copyright laws when handling this file.

