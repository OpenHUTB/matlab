function architecturePort=getArchitecturePortInContext(compOrArchPort)




    if isa(compOrArchPort,'systemcomposer.architecture.model.design.ComponentPort')
        if compOrArchPort.getComponent.isSubsystemReferenceComponent
            architecturePort=compOrArchPort.getOwnedArchitecturePort;
        else
            architecturePort=compOrArchPort.getArchitecturePort;
        end
    else

        assert(isa(compOrArch,'systemcomposer.architecture.model.design.ArchitecturePort'),...
        "Input must be either be component or architecture port!");
        if compOrArchPort.getComponent.isSubsystemReferenceComponent

            architecturePort=compOrArchPort.getParentComponentPort.getOwnedArchitecturePort;
        else
            architecturePort=compOrArchPort;
        end
    end
end
