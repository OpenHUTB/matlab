function moveOut(parameterSpace)



    currentParentParameterSpace=parameterSpace.Container;
    newParentParameterSpace=currentParentParameterSpace.Container;
    newParentParameterSpace.ParameterSpaces.add(parameterSpace);

    simulink.multisim.internal.updateDesignStudyNumSimulations(currentParentParameterSpace);

end