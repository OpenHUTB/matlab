function updateDesignStudyNumSimulations(childElement)






    parameterSpace=simulink.multisim.internal.getParentContainer(...
    childElement,"CombinatorialParameterSpace");

    simulink.multisim.internal.utils.CombinatorialParameterSpace.updateNumDesignPoints(parameterSpace);

    if isa(parameterSpace.Container,"simulink.multisim.mm.design.CombinatorialParameterSpace")
        simulink.multisim.internal.updateDesignStudyNumSimulations(parameterSpace.Container);
    elseif isa(parameterSpace.Container,"simulink.multisim.mm.design.DesignStudy")
        designStudy=parameterSpace.Container;
        designStudy.NumSimulations=parameterSpace.NumDesignPoints;
        simulink.multisim.internal.updateDesignStudyErrorText(designStudy);
    end
end
