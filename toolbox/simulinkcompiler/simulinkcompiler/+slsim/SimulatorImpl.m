classdef(Hidden=true)SimulatorImpl<handle





    methods(Abstract)
        initializeImpl(this);
        startImpl(this)
        pauseImpl(this);
        isPaused=stepImpl(this)
        resumeImpl(this);
        stopImpl(this);
        simulationOutput=simImpl(this)
        simulationStatus=statusImpl(this);
        simTime=simulationTimeImpl(this);
    end
end
