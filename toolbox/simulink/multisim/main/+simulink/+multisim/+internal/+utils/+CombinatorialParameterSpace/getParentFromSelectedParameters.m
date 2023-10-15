function parentParameter = getParentFromSelectedParameters( dataModel, rootParameterSpace, selectedParameterIDs )

arguments
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
