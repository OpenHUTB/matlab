function setDsmBlock(this,dsms)



    blockParam=arrayfun(@(dsm)...
    Simulink.Simulation.BlockParameter(dsm.BlockPath,'DataLogging','on'),dsms);
    this.RunTestCfg.SimulationInput.BlockParameters=[this.RunTestCfg.SimulationInput.BlockParameters,blockParam];
end
