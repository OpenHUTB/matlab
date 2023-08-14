classdef SimulinkSimulator<driving.internal.scenarioApp.Simulator



    methods
        function l=addSampleChangedListener(~,cb)
            l=[];
        end

        function l=addStateChangedListener(~,cb)
            l=[];
        end

        function s=getCurrentSample(~)
            s=1;
        end

        function t=getCurrentTime(~)
            t=0;
        end

        function t=getStopTime(~)
            t=10;
        end

        function b=canRun(~)
            b=false;
        end

        function b=isPaused(~)
            b=false;
        end

        function b=isStopped(~)
            b=true;
        end

        function b=isRunning(~)
            b=false;
        end

        function pause(~)
        end

        function stop(~)
        end

        function run(~)
        end

        function i=getIcon(~)
            i=matlab.ui.internal.toolstrip.Icon.SIMULINK_24;
        end

        function str=getAgentModelString(this)
            str='None';
        end
    end

    methods(Access=protected)
        function s=getSections(this)

            icon=matlab.ui.internal.toolstrip.Icon(fullfile(this.Designer.getPathToIcons,'GamingEngine24.png'));
            fidelity=matlabshared.application.SimulationFidelitySection(icon);
            agent=Simulink.application.AgentModelSection();
            simulate=Simulink.application.SimulateSection();

            s=[fidelity,agent,simulate];

        end
    end
end
