function restart(scenario)





























































%#codegen

    coder.allowpcode("plain");


    coder.internal.errorIf(scenario.Simulator.SimulationMode==2,...
    'shared_orbit:orbitPropagator:InvalidManualSimAccess','restart');


    reset(scenario);
end

