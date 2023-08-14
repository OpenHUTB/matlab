function applyPrototype(elem,prototypeName)









    if isa(elem,'systemcomposer.architecture.model.design.Component')
        arch=elem.getArchitecture;


        if elem.isSubsystemReferenceComponent&&...
            systemcomposer.internal.isArchitectureLocked(arch)&&...
            ~systemcomposer.internal.isArchitectureLocked(elem.getOwnedArchitecture)
            arch=elem.getOwnedArchitecture;
        end
        elem=arch;
    end
    elem.applyPrototype(prototypeName);
