function destroyElement(~,parameterSpace,~)




    combinatorialParameterSpace=parameterSpace.Container;
    parameterSpace.destroy();
    simulink.multisim.internal.updateDesignStudyNumSimulations(combinatorialParameterSpace);
end
