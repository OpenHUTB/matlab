function updateDiagram(bdH)
    try
        set_param(bdH,'SimulationCommand','update');
    catch me
        Simulink.output.error(me);
    end
end
