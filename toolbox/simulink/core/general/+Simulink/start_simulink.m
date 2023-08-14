function start_simulink

















    persistent isSimulinkStarted;
    if isempty(isSimulinkStarted)
        isSimulinkStarted=true;
        performance.productStats.logEventTime('SLStartup','startSimulinkBegin');
        cleanupObj=onCleanup(@()performance.productStats.logEventTime('SLStartup','startSimulinkEnd'));
        bdroot;
    end
end