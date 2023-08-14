function reset(scenario)




%#codegen

    coder.allowpcode("plain");


    scenario.Simulator.NeedToSimulate=true;


    scenario.Simulator.SimulationStatus=0;


    advance(scenario.Simulator,scenario.StartTime);


    resetStateHistory(scenario.Simulator);

    if coder.target('MATLAB')

        updateAntennaPatterns(scenario.Simulator);


        for idx=1:numel(scenario.Viewers)

            if scenario.Viewers(idx).IsDynamic
                makeViewStatic(scenario.Viewers(idx));
            end


            scenario.Viewers(idx).pCurrentTime=scenario.StartTime;



            if scenario.Simulator.SimulationMode==1
                tf=false;
            else
                tf=true;
            end
            scenario.Viewers(idx).GlobeViewer.setTimelineWidget(tf);
            scenario.Viewers(idx).GlobeViewer.setAnimationWidget(tf);
        end
    end
end

