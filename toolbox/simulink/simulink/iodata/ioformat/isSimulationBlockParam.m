function outBool=isSimulationBlockParam(inVar)




    outBool=isa(inVar,'Simulink.Simulation.BlockParameter');
end
