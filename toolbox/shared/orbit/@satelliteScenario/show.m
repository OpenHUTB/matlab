function show(scenario,varargin)









    validateattributes(scenario,{'satelliteScenario'},{'scalar'},...
    'show','SCENARIO',1);
    if~isvalid(scenario)
        msg=message(...
        'shared_orbit:orbitPropagator:SatelliteScenarioInvalidObject',...
        'SCENARIO');
        error(msg);
    end

    p=inputParser;
    p.addParameter('Viewer',scenario.CurrentViewer);
    p.addParameter('Time',[]);
    p.addParameter('Animation','fly');
    p.addParameter('WaitForResponse',true);
    p.parse(varargin{:});
    viewer=p.Results.Viewer;
    animation=p.Results.Animation;
    waitForResponse=p.Results.WaitForResponse;


    if isempty(viewer)||~isvalid(viewer.GlobeViewer)
        viewer=satelliteScenarioViewer(scenario);
    end
    time=p.Results.Time;
    if(isempty(time))
        time=viewer.CurrentTime;
    end





    myTimer=timer('TimerFcn',@(~,~)addWaitBar(viewer,'plotting'),'StartDelay',1);
    start(myTimer);



    try

        advance(scenario.Simulator,time);

        setDate(viewer.GlobeViewer,time);


        queuePlots(viewer.GlobeViewer);


        sat=scenario.Satellites;



        if~isempty(sat)
            satGimbals=[sat.Gimbals];
            satSensors=[sat.ConicalSensors];
            satAccesses=[sat.Accesses];
            satTx=[sat.Transmitters];
        else
            satGimbals=[];
            satSensors=[];
            satAccesses=[];
            satTx=[];
        end


        gs=scenario.GroundStations;



        if~isempty(gs)
            gsGimbals=[gs.Gimbals];
            gsSensors=[gs.ConicalSensors];
            gsAccesses=[gs.Accesses];
            gsTx=[gs.Transmitters];
        else
            gsGimbals=[];
            gsSensors=[];
            gsAccesses=[];
            gsTx=[];
        end


        gim=[satGimbals,gsGimbals];


        if~isempty(gim)
            gimSensors=[gim.ConicalSensors];
            gimTx=[gim.Transmitters];
        else
            gimSensors=[];
            gimTx=[];
        end


        sensor=[satSensors,gsSensors,gimSensors];


        if~isempty(sensor)
            sensorAc=[sensor.Accesses];
        else
            sensorAc=[];
        end


        tx=[satTx,gsTx,gimTx];


        if~isempty(tx)
            links=[tx.Links];
        else
            links=[];
        end


        accesses=[satAccesses,gsAccesses,sensorAc];


        numCameraGraphics=numel(sat)+numel(gs);


        numPlots=0;
        if~isempty(sat)
            sat=sat.Handles;
        end
        numSats=numel(sat);
        for k=1:numSats
            updateVisualizations(sat{k},viewer);
            numPlots=numPlots+1;


            if mod(numPlots,10000)==0
                submitPlots(viewer.GlobeViewer,'Animation','none');
                queuePlots(viewer.GlobeViewer);
            end
        end


        if~isempty(gs)
            gs=gs.Handles;
        end
        numGS=numel(gs);
        for k=1:numGS
            updateVisualizations(gs{k},viewer);
            numPlots=numPlots+1;

            if mod(numPlots,10000)==0
                submitPlots(viewer.GlobeViewer,'Animation','none');
                queuePlots(viewer.GlobeViewer);
            end
        end


        for k=1:numel(accesses)
            updateVisualizations(accesses(k),viewer);
        end


        for k=1:numel(links)
            updateVisualizations(links(k),viewer);
        end


        submitPlots(viewer.GlobeViewer,'Animation','none','WaitForResponse',waitForResponse);




        if~strcmp(animation,'none')
            if~isempty(sat)
                matlabshared.satellitescenario.ScenarioGraphic.flyToGraphic(viewer,sat{1});
            elseif~isempty(gs)
                matlabshared.satellitescenario.ScenarioGraphic.flyToGraphic(viewer,gs{1});
            end
        end

        if isvalid(myTimer)
            stop(myTimer);
            delete(myTimer);
        end


        figure(viewer.UIFigure);
    catch ME
        if isvalid(myTimer)
            stop(myTimer);
            delete(myTimer);
        end


        removeWaitBar(viewer);

        rethrow(ME);
    end


    removeWaitBar(viewer);
end


