function architecture=getArchitectureInContext(compOrArch)


    if isa(compOrArch,'systemcomposer.architecture.model.design.BaseComponent')
        if compOrArch.isSubsystemReferenceComponent
            architecture=compOrArch.getOwnedArchitecture;
        else
            architecture=compOrArch.getArchitecture;
        end
    else
        architecture=compOrArch;
    end
end
