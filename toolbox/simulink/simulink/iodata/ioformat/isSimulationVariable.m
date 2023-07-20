function outBool=isSimulationVariable(inVar)




    outBool=isa(inVar,'Simulink.Simulation.Variable');
end
