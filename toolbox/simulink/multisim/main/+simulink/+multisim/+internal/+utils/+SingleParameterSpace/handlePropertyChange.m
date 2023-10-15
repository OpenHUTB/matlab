function handlePropertyChange( ~, parameterSpace, changedProperty, ~ )

arguments
    ~
    parameterSpace( 1, 1 )simulink.multisim.mm.design.SingleParameterSpace
    changedProperty( 1, 1 )string
    ~
end

switch changedProperty
    case "SelectedForRun"
        simulink.multisim.internal.updateDesignStudyNumSimulations( parameterSpace );
end
end


