function parentParameter = getParentFromSelectedParameters( dataModel, rootParameterSpace, selectedParameterIDs )





R36
dataModel( 1, 1 )mf.zero.Model
rootParameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
selectedParameterIDs( 1, : )cell = {  }
end 

if isempty( selectedParameterIDs )
parentParameter = rootParameterSpace;
else 
selectedParameter = dataModel.findElement( selectedParameterIDs{ 1 } );



parentParameter = selectedParameter.Container;
if length( selectedParameterIDs ) == 1 && isa( selectedParameter, "simulink.multisim.mm.design.CombinatorialParameterSpace" )
parentParameter = selectedParameter;
end 
end 
end 
% Decoded using De-pcode utility v1.2 from file /tmp/tmpRDpRT4.p.
% Please follow local copyright laws when handling this file.

