function instanceModel=newArchitectureInstance(specification,model,name)


    instanceModel=systemcomposer.internal.analysis.ArchitectureInstance(model);
    if nargin<3
        instanceModel.setName(specification.getName);
    else
        instanceModel.setName(name);
    end
    instanceModel.specification=specification;

    instanceModel.createListener(specification);
    instanceModel.startListener(specification);
end

