classdef ( Hidden = true )SimulatorNormalAccel < slsim.SimulatorImpl




    properties ( Hidden )
        model_( 1, 1 )string
        simInput_( 1, 1 )Simulink.SimulationInput
        stepper_
    end
    properties ( Constant, Hidden )
        kPollingInteralSeconds = 0.3;
    end

    methods
        function obj = SimulatorNormalAccel( simIn )
            arguments
                simIn( 1, 1 )Simulink.SimulationInput
            end
            slsim.Simulator.checkModelNameNotEmpty( simIn );
            obj.simInput_ = simIn;
            obj.model_ = simIn.ModelName;
            obj.stepper_ = Simulink.SimulationStepper( obj.model_ );
        end
        function isPaused = stepImpl( this )
            this.stepper_.forward;
            time = get_param( this.model_, 'SimulationTime' );
            stopTime = get_param( this.model_, 'StopTime' );
            isPaused = stopTime > time;
        end
        function startImpl( this )
            set_param( this.model_, 'SimulationCommand', 'Start' );
            this.waitForStatus( slsim.SimStatus.Running );


        end
        function pauseImpl( this )
            set_param( this.model_, 'SimulationCommand', 'Pause' );
            this.waitForStatus( slsim.SimStatus.Paused );
        end
        function initializeImpl( this )
            this.simInput_.applyToModel( 'ApplyHidden', 'on' );
            this.stepper_.initialize;
        end
        function stopImpl( this )
            this.stepper_.stop;
            this.waitForStatus( slsim.SimStatus.Stopped );
        end
        function resumeImpl( this )
            this.stepper_.continue;
            this.waitForStatus( slsim.SimStatus.Running );
        end
        function simulationOutput = simImpl( this )
            simulationOutput = sim( this.simInput_ );
        end

        function SimStatus = statusImpl( this )
            statusString = get_param( this.model_, 'SimulationStatus' );
            SimStatus = slsim.SimStatus( statusString );
        end
        function simTime = simulationTimeImpl( this )
            simTime = get_param( this.model_, 'SimulationTime' );
        end
    end
    methods ( Access = private )
        function waitForStatus( this, desiredStatus )
            while this.statusImpl ~= desiredStatus
                pause( this.kPollingInteralSeconds );
            end
        end
    end
end


