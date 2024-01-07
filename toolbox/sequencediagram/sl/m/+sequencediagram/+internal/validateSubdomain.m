function validateSubdomain(model)
    isSupported=Simulink.internal.isArchitectureModel(model);

    if~isSupported
        MSLException('sequencediagram:SequenceDiagramMain:SequenceDiagramOnlySupportedForArchitectures').throw();
    end

end


