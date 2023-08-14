function result=isComponentPlotTXVQuadrantDiagramSupported(componentPath)





    result=any(strcmp(componentPath,{
    'fluids.two_phase_fluid.valves_orifices.flow_control_valves.thermostatic_expansion_valve'}));
end