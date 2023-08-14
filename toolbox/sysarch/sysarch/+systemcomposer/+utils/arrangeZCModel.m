function arrangeZCModel(model)





    if~isempty(model)

        Simulink.BlockDiagram.arrangeSystem(model.SimulinkHandle,'FullLayout','true');

        components=model.Architecture.Components;
        for itr=1:numel(components)
            component=components(itr);

            if~systemcomposer.internal.isAdapter(component.SimulinkHandle)&&~(component.isReference)
                systemcomposer.utils.arrangeZCModel(component);
            end
        end
    end
end

