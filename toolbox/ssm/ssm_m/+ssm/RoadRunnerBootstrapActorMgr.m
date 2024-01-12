function RoadRunnerBootstrapActorMgr(apiPortStr,coSimPortStr,requsted_client_id)
    try
        apiPort=str2double(apiPortStr);
        coSimPort=str2double(coSimPortStr);
        evalin('base','load(''rrScenarioSimTypes.mat'')');
        Simulink.BootstrapWorkflow(apiPort,coSimPort,requsted_client_id);
        disp('MATLAB exits...');
        quit;
    catch ME
        disp('Error occurred!');
        disp(ME.message);
        disp('MATLAB will be closed in 10s...');
        pause(10);
        quit;
    end

end