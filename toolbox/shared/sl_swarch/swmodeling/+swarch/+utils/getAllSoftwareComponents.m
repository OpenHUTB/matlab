function swComponents=getAllSoftwareComponents(arch)





    allComponents=arch.getComponentsAcrossHierarchy();
    swComponents=[];
    for comp=allComponents
        if isa(comp,'systemcomposer.architecture.model.design.Component')&&...
            ~comp.isServiceComponent()
            swComponents=[swComponents,comp];%#ok<AGROW>
        end
    end
end


