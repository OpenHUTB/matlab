function handlePropertyChange( ~, parameterSpace, ~, ~ )

arguments
    ~
    parameterSpace( 1, 1 )simulink.multisim.mm.design.CombinatorialParameterSpace
    ~
    ~
end

simulink.multisim.internal.updateDesignStudyNumSimulations( parameterSpace );
end

