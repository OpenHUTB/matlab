


function type=getSimulationMode(simmode)

    switch simmode
    case 'Normal'
        type=Advisor.component.SimulationMode.Normal;
    case 'Accelerator'
        type=Advisor.component.SimulationMode.Accelerator;
    case 'Software-in-the-loop (SIL)'
        type=Advisor.component.SimulationMode.SIL;
    case 'Processor-in-the-loop (PIL)'
        type=Advisor.component.SimulationMode.PIL;
    otherwise
        assert(false,'Unknown simulation mode');
    end
end