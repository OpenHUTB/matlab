function isRunning=advance(scenario)
















































%#codegen

    coder.allowpcode("plain");


    coder.internal.errorIf(scenario.Simulator.SimulationMode==2,...
    'shared_orbit:orbitPropagator:InvalidManualSimAccess','advance');


    isFirstCall=scenario.Simulator.SimulationStatus==0;


    simulationStatus=scenario.Simulator.SimulationStatus;



    coder.internal.errorIf(simulationStatus==2,'shared_orbit:orbitPropagator:NonRunningSimulation');




    if~isFirstCall
        time=scenario.pSimulationTime+seconds(scenario.SampleTime);
    else
        time=scenario.StartTime;
        scenario.Simulator.SimulationStatus=1;
    end

    if time>scenario.StopTime



        isRunning=false;
        scenario.Simulator.SimulationStatus=2;
    else

        advance(scenario.Simulator,time);


        updateStateHistory(scenario.Simulator);


        isRunning=true;

        if coder.target('MATLAB')

            for idx=1:numel(scenario.Viewers)
                if scenario.Viewers(idx).IsDynamic
                    makeViewStatic(scenario.Viewers(idx));
                end
                scenario.Viewers(idx).pCurrentTime=time;
            end
        end
    end


    scenario.pSimulationTime=time;
end

