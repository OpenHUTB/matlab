function engineName=startEngine














    if~matlab.engine.isEngineShared
        matlab.engine.shareEngine;
    end
    engineName=matlab.engine.engineName;
    setenv("com_mathworks_si_toolbox_engine_name",engineName)
end


