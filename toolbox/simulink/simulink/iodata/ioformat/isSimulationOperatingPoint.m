function outBool=isSimulationOperatingPoint(inVar)




    outBool=isa(inVar,'Simulink.op.ModelOperatingPoint')&&isscalar(inVar);
end
