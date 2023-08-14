classdef satelliteScenario<handle&matlabshared.satellitescenario.internal.CustomDisplayBase %#codegen









































































































    properties(Dependent)


















StartTime












StopTime













SampleTime
    end

    properties(Dependent,SetAccess=private)





SimulationTime





















        SimulationStatus(1,1)matlabshared.satellitescenario.internal.SimulationStatus
    end

    properties(Dependent)








AutoSimulate
    end

    properties




        Viewers=matlabshared.satellitescenario.Viewer.empty
    end

    properties(SetAccess={?matlabshared.satellitescenario.Satellite,...
        ?matlabshared.satellitescenario.GroundStation,?matlabshared.satellitescenario.Access,...
        ?matlabshared.satellitescenario.internal.PrimaryAsset})





Satellites



GroundStations
    end

    properties(Access={?matlabshared.satellitescenario.Viewer,?matlabshared.satellitescenario.ScenarioGraphic})



Simulator
    end

    properties(Dependent,Access={?matlabshared.satellitescenario.ScenarioGraphic,?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.PrimaryAsset,?matlabshared.satellitescenario.internal.AttachedAsset,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.PrimaryAssetWrapper,...
        ?matlabshared.satellitescenario.internal.AttachedAssetWrapper})
NeedToSimulate
    end

    properties(Access=private)
pNeedToSimulate
        pSatellitesAddedBefore=false
        pGroundStationsAddedBefore=false
pSimulationTime
    end

    properties(Hidden)
        ScenarioGraphics={}



        Accesses={}



        Links={}
    end

    properties(Hidden,Dependent)


UpdatePhasedArrayTaper
    end

    properties(Access={?matlabshared.orbit.internal.Satellite})


UsingDefaultTimes
EarliestProvidedEpoch
    end

    properties(Hidden,Transient)





CurrentViewer
    end

    properties(Constant,Hidden)

        InputParserOptions=struct('PartialMatching','unique');


        DateStringFormat='dd-mmm-yyyy'
    end

    properties(Constant,Access={?matlabshared.orbit.internal.Satellite})


        DefaultNumSamples=100
        DatetimeComparisonTolerance=1e-9
    end

    properties




        AutoShow(1,1)logical=true
    end

    methods
        function scenario=satelliteScenario(varargin)


            coder.allowpcode('plain');


            coder.internal.errorIf(~(nargin==0||nargin==2||nargin==3||nargin==5),...
            'shared_orbit:orbitPropagator:SatelliteScenarioInvalidNargin');



            switch nargin
            case{0,2}

                paramNames={'AutoSimulate'};
                pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{:});
                autoSimulate=coder.internal.getParameterValue(pstruct.AutoSimulate,true,varargin{:});
                validateattributes(autoSimulate,{'logical'},{'nonempty','scalar'},'satelliteScenario','AutoSimulate');



                if isempty(coder.target)
                    startTime=datetime("now","TimeZone","UTC");
                else
                    startTime=datetime;
                end
                stopTime=startTime;
                sampleTime=60;



                scenario.UsingDefaultTimes=true;
            otherwise



                paramNames={'AutoSimulate'};
                pstruct=coder.internal.parseParameterInputs(paramNames,satelliteScenario.InputParserOptions,varargin{4:end});
                autoSimulate=coder.internal.getParameterValue(pstruct.AutoSimulate,true,varargin{4:end});
                validateattributes(autoSimulate,{'logical'},{'nonempty','scalar'},'satelliteScenario','AutoSimulate');


                startTime=varargin{1};
                stopTime=varargin{2};
                sampleTime=varargin{3};


                validateStartTime(startTime);
                validateStopTime(stopTime);
                validateSampleTime(sampleTime);


                if isempty(coder.target)
                    startTime.TimeZone="UTC";
                    stopTime.TimeZone="UTC";
                end



                scenario.UsingDefaultTimes=false;
            end


            scenario.pSimulationTime=startTime;


            scenario.Satellites=matlabshared.satellitescenario.Satellite;


            scenario.GroundStations=matlabshared.satellitescenario.GroundStation;


            scenario.Simulator=matlabshared.satellitescenario.internal.Simulator(...
            startTime,stopTime,sampleTime);


            if isempty(coder.target)
                scenario.EarliestProvidedEpoch=datetime("NaT","TimeZone","UTC");
            else
                scenario.EarliestProvidedEpoch=NaT;
            end


            if~autoSimulate
                scenario.Simulator.SimulationMode=1;
            else
                scenario.Simulator.SimulationMode=2;
            end
        end

        function delete(scenario)





            coder.allowpcode('plain');

            if isempty(coder.target)


                if~isempty(scenario.Satellites)
                    satHandles=scenario.Satellites.Handles;
                    numSats=numel(satHandles);
                else
                    numSats=0;
                end
                for idx=1:numSats
                    if isvalid(satHandles{idx})
                        delete(satHandles{idx});
                    end
                end



                if~isempty(scenario.GroundStations)
                    gsHandles=scenario.GroundStations.Handles;
                    numGSes=numel(gsHandles);
                else
                    numGSes=0;
                end
                for idx=1:numGSes
                    if isvalid(gsHandles{idx})
                        delete(gsHandles{idx});
                    end
                end


                for viewer=scenario.Viewers
                    if(isvalid(viewer))
                        delete(viewer);
                    end
                end
            end
        end

        function set.StartTime(scenario,startTime)


            coder.allowpcode('plain');


            coder.internal.errorIf(scenario.Simulator.SimulationMode==1&&scenario.Simulator.SimulationStatus~=0,...
            'shared_orbit:orbitPropagator:UnablePropertySetIncorrectSimStatus',...
            'StartTime');


            validateStartTime(startTime)


            if isempty(coder.target)
                startTime.TimeZone="UTC";
            end


            oldStartTime=scenario.Simulator.StartTime;


            scenario.Simulator.StartTime=startTime;


            scenario.UsingDefaultTimes=false;



            if oldStartTime~=startTime
                scenario.Simulator.NeedToSimulate=true;




                if scenario.Simulator.StartTime>scenario.Simulator.StopTime
                    scenario.Simulator.StopTime=scenario.Simulator.StartTime;
                end

                if isempty(coder.target)
                    scenario.NeedToSimulate=true;
                    waitForResponse=false;


                    for k=1:numel(scenario.Viewers)
                        viewer=scenario.Viewers(k);
                        viewer.GlobeViewer.setClockBounds(startTime,scenario.StopTime);



                        if viewer.IsDynamic
                            makeViewStatic(viewer);
                        end

                        if(k==numel(scenario.Viewers))
                            waitForResponse=true;
                        end





                        if viewer.CurrentTime<scenario.Simulator.StartTime
                            viewer.pCurrentTime=scenario.Simulator.StartTime;
                        else
                            show(scenario,"Viewer",viewer,"WaitForResponse",waitForResponse,"Animation",'none');
                        end
                    end
                end
            end
        end

        function set.StopTime(scenario,stopTime)


            coder.allowpcode('plain');


            coder.internal.errorIf(scenario.Simulator.SimulationMode==1&&scenario.Simulator.SimulationStatus~=0,...
            'shared_orbit:orbitPropagator:UnablePropertySetIncorrectSimStatus',...
            'StopTime');


            validateStopTime(stopTime)


            if isempty(coder.target)
                stopTime.TimeZone="UTC";
            end


            oldStopTime=scenario.Simulator.StopTime;


            scenario.Simulator.StopTime=stopTime;


            scenario.UsingDefaultTimes=false;



            if oldStopTime~=stopTime
                scenario.Simulator.NeedToSimulate=true;




                if scenario.Simulator.StopTime<scenario.Simulator.StartTime
                    scenario.Simulator.StartTime=scenario.Simulator.StopTime;
                end

                if isempty(coder.target)
                    scenario.NeedToSimulate=true;
                    waitForResponse=false;

                    for k=1:numel(scenario.Viewers)
                        viewer=scenario.Viewers(k);
                        viewer.GlobeViewer.setClockBounds(scenario.StartTime,stopTime);



                        if viewer.IsDynamic
                            makeViewStatic(viewer);
                        end

                        if(k==numel(scenario.Viewers))
                            waitForResponse=true;
                        end





                        if viewer.CurrentTime>scenario.Simulator.StopTime
                            viewer.pCurrentTime=scenario.Simulator.StopTime;
                        else
                            show(scenario,"Viewer",viewer,"WaitForResponse",waitForResponse,"Animation",'none');
                        end
                    end
                end
            end
        end

        function set.SampleTime(scenario,sampleTime)


            coder.allowpcode('plain');


            coder.internal.errorIf(scenario.Simulator.SimulationMode==1&&scenario.Simulator.SimulationStatus~=0,...
            'shared_orbit:orbitPropagator:UnablePropertySetIncorrectSimStatus',...
            'SampleTime');


            validateSampleTime(sampleTime)


            oldSampleTime=scenario.Simulator.SampleTime;


            scenario.Simulator.SampleTime=double(sampleTime);


            scenario.UsingDefaultTimes=false;



            if oldSampleTime~=sampleTime
                scenario.Simulator.NeedToSimulate=true;

                if isempty(coder.target)
                    scenario.NeedToSimulate=true;
                    waitForResponse=false;
                    for k=1:numel(scenario.Viewers)
                        viewer=scenario.Viewers(k);



                        if viewer.IsDynamic
                            makeViewStatic(viewer);
                        end

                        if(k==numel(scenario.Viewers))
                            waitForResponse=true;
                        end


                        show(scenario,"Viewer",viewer,"WaitForResponse",waitForResponse,"Animation",'none');
                    end
                end
            end
        end

        function startTime=get.StartTime(scenario)


            coder.allowpcode('plain');

            startTime=scenario.Simulator.StartTime;
        end

        function stopTime=get.StopTime(scenario)


            coder.allowpcode('plain');

            stopTime=scenario.Simulator.StopTime;
        end

        function sampleTime=get.SampleTime(scenario)


            coder.allowpcode('plain');

            sampleTime=scenario.Simulator.SampleTime;
        end

        function simulationTime=get.SimulationTime(scenario)


            coder.allowpcode('plain');

            coder.internal.errorIf(scenario.Simulator.SimulationMode~=1,...
            'shared_orbit:orbitPropagator:InvalidManualSimAccess',...
            'SimulationTime');

            simulationTime=scenario.Simulator.Time;
        end

        function s=get.SimulationStatus(scenario)


            coder.allowpcode('plain');

            coder.internal.errorIf(scenario.Simulator.SimulationMode~=1,...
            'shared_orbit:orbitPropagator:InvalidManualSimAccess',...
            'SimulationStatus');

            switch scenario.Simulator.SimulationStatus
            case 0
                s=matlabshared.satellitescenario.SimulationStatus.NotStarted;
            case 1
                s=matlabshared.satellitescenario.SimulationStatus.InProgress;
            otherwise
                s=matlabshared.satellitescenario.SimulationStatus.Completed;
            end
        end

        function tf=get.AutoSimulate(scenario)


            coder.allowpcode('plain');

            tf=scenario.Simulator.SimulationMode~=1;
        end

        function set.AutoSimulate(scenario,tf)


            coder.allowpcode('plain');


            validateattributes(tf,{'logical'},{'nonempty','scalar'},'set.SimulationMode');

            if tf~=scenario.AutoSimulate

                reset(scenario);



                if tf
                    scenario.Simulator.SimulationMode=2;
                    showAnimationAndTimelineWidget=true;
                else
                    scenario.Simulator.SimulationMode=1;
                    showAnimationAndTimelineWidget=false;
                end


                for idx=1:numel(scenario.Viewers)
                    scenario.Viewers(idx).GlobeViewer.setAnimationWidget(showAnimationAndTimelineWidget);
                    scenario.Viewers(idx).GlobeViewer.setTimelineWidget(showAnimationAndTimelineWidget);
                end
            end
        end

        function NeedToSimulate=get.NeedToSimulate(scenario)

            coder.allowpcode('plain');

            NeedToSimulate=scenario.pNeedToSimulate;
        end

        function set.NeedToSimulate(scenario,NeedToSimulate)




            coder.allowpcode('plain');

            if NeedToSimulate
                numViewers=numel(scenario.Viewers);
                for k=1:numViewers
                    scenario.Viewers(k).NeedToSimulate=NeedToSimulate;
                end
            end
            scenario.pNeedToSimulate=NeedToSimulate;
        end

        function tf=get.UpdatePhasedArrayTaper(scenario)


            tf=scenario.Simulator.UpdateTaper;
        end

        function set.UpdatePhasedArrayTaper(scenario,tf)


            scenario.Simulator.UpdateTaper=tf;
        end
    end

    methods(Access={?matlabshared.satellitescenario.ScenarioGraphic,...
        ?matlabshared.satellitescenario.internal.PrimaryAsset,...
        ?matlabshared.satellitescenario.internal.AttachedAsset,?matlabshared.satellitescenario.Viewer,...
        ?matlabshared.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?satcom.satellitescenario.internal.AddAssetsAndAnalyses,...
        ?matlabshared.satellitescenario.internal.PrimaryAssetWrapper,...
        ?matlabshared.satellitescenario.internal.AttachedAssetWrapper})

        function addToScenarioGraphics(scenario,objs)




            if~isempty(objs)&&isprop(objs(1),"Handles")
                objHandles=objs.Handles;
                numObjs=numel(objs);
                for k=1:numObjs
                    scenario.ScenarioGraphics{end+1}=objHandles{k};
                end
            else
                for k=1:numel(objs)
                    scenario.ScenarioGraphics{end+1}=objs(k);
                end
            end
        end

        function removeFromScenarioGraphics(scenario,obj)
            if(isvalid(scenario))
                numGraphics=numel(scenario.ScenarioGraphics);
                for k=1:numGraphics

                    if scenario.ScenarioGraphics{k}==obj
                        scenario.ScenarioGraphics(k)=[];
                        break;
                    end
                end
            end
        end

        function removeFromAccesses(scenario,ac)
            if(isvalid(scenario))
                numAccesses=numel(scenario.Accesses);
                for k=1:numAccesses
                    if scenario.Accesses{k}==ac
                        scenario.Accesses(k)=[];
                        break;
                    end
                end
            end
        end

        function removeFromLinks(scenario,lnk)
            if(isvalid(scenario))
                numLinks=numel(scenario.Links);
                for k=1:numLinks
                    if scenario.Links{k}==lnk
                        scenario.Links(k)=[];
                        break;
                    end
                end
            end
        end

        function updateTimeline(scenario,startTime,stopTime)
            for k=1:numel(scenario.Viewers)
                scenario.Viewers(k).GlobeViewer.setClockBounds(startTime,stopTime);


                scenario.Viewers(k).pCurrentTime=startTime;
            end
        end
        show(scenario,varargin)
    end

    methods(Static)
        function s=loadobj(scenario)


            coder.allowpcode('plain');



            [~,wID]=lastwarn;
            needToInitializeScenarioGraphics=false;
            if strcmp(wID,'MATLAB:class:loadInconsistentClass')
                needToInitializeScenarioGraphics=true;
            end


            s=scenario;










            needToCustomLoad=~iscell(scenario.ScenarioGraphics)||...
            isa(scenario.Satellites,'double')||...
            isa(scenario.GroundStations,'double');



            if needToCustomLoad
                if isa(scenario.Satellites,'double')



                    sat=matlabshared.satellitescenario.Satellite;
                else






                    handles=[scenario.Satellites.Handles];
                    if~isempty(handles)
                        handles=reshape(handles,1,[]);
                    end


                    sat=matlabshared.satellitescenario.Satellite;
                    sat.Handles=handles;
                end



                if~isempty(sat)
                    scenario.pSatellitesAddedBefore=true;
                    gimSat=sat.Gimbals;
                    sensorSat=sat.ConicalSensors;
                    acSat=sat.Accesses;
                    txSat=sat.Transmitters;
                    rxSat=sat.Receivers;
                else
                    gimSat=matlabshared.satellitescenario.Gimbal;
                    sensorSat=matlabshared.satellitescenario.ConicalSensor;
                    acSat=matlabshared.satellitescenario.Access;
                    txSat=satcom.satellitescenario.Transmitter;
                    rxSat=satcom.satellitescenario.Receiver;
                end


                scenario.Satellites=sat;

                if isa(scenario.GroundStations,'double')




                    gs=matlabshared.satellitescenario.GroundStation;
                else






                    handles=[scenario.GroundStations.Handles];
                    if~isempty(handles)
                        handles=reshape(handles,1,[]);
                    end



                    gs=matlabshared.satellitescenario.GroundStation;
                    gs.Handles=handles;
                end




                if~isempty(gs)
                    scenario.pGroundStationsAddedBefore=true;
                    gimGs=gs.Gimbals;
                    sensorGs=gs.ConicalSensors;
                    acGs=gs.Accesses;
                    txGs=gs.Transmitters;
                    rxGs=gs.Receivers;
                else
                    gimGs=matlabshared.satellitescenario.Gimbal;
                    sensorGs=matlabshared.satellitescenario.ConicalSensor;
                    acGs=matlabshared.satellitescenario.Access;
                    txGs=satcom.satellitescenario.Transmitter;
                    rxGs=satcom.satellitescenario.Receiver;
                end


                scenario.GroundStations=gs;



                gim=[gimSat,gimGs];
                if~isempty(gim)
                    sensorGim=gim.ConicalSensors;
                    txGim=gim.Transmitters;
                    rxGim=gim.Receivers;
                else
                    sensorGim=matlabshared.satellitescenario.ConicalSensor;
                    txGim=satcom.satellitescenario.Transmitter;
                    rxGim=satcom.satellitescenario.Receiver;
                end



                sensor=[sensorSat,sensorGs,sensorGim];
                if~isempty(sensor)
                    acSensor=sensor.Accesses;
                else
                    acSensor=matlabshared.satellitescenario.Access;
                end


                ac=[acSat,acGs,acSensor];



                tx=[txSat,txGs,txGim];
                if~isempty(tx)
                    lnk=tx.Links;
                else
                    lnk=satcom.satellitescenario.Link;
                end


                rx=[rxSat,rxGs,rxGim];


                if needToInitializeScenarioGraphics


                    if~isempty(sat)
                        addToScenarioGraphics(scenario,sat);
                        addToScenarioGraphics(scenario,sat.Orbit);
                        addToScenarioGraphics(scenario,sat.GroundTrack);
                    end


                    addToScenarioGraphics(scenario,gs);


                    addToScenarioGraphics(scenario,gim);



                    if~isempty(sensor)
                        addToScenarioGraphics(scenario,sensor);
                        addToScenarioGraphics(scenario,sensor.FieldOfView);
                    end


                    addToScenarioGraphics(scenario,ac);


                    addToScenarioGraphics(scenario,tx);


                    addToScenarioGraphics(scenario,rx);


                    addToScenarioGraphics(scenario,lnk);
                end
            end

            if isempty(coder.target)
                if needToCustomLoad


                    scenario.Accesses=cell(1,numel(ac));
                    for idx=1:numel(ac)

                        numNodesAfterSource=numel(ac(idx).Sequence)-1;
                        sequenceAfterSource=ac(idx).Sequence(2:end);
                        nodeTypeAfterSource=ac(idx).NodeType(2:end);
                        ac(idx).SequenceHandle=cell(1,numNodesAfterSource);
                        for idx2=1:numNodesAfterSource
                            nodeType=nodeTypeAfterSource(idx2);
                            switch nodeType
                            case 1
                                ac(idx).SequenceHandle{idx2}=sat(sat.ID==sequenceAfterSource(idx2));
                            case 2
                                ac(idx).SequenceHandle{idx2}=gs(gs.ID==sequenceAfterSource(idx2));
                            otherwise
                                ac(idx).SequenceHandle{idx2}=sensor(sensor.ID==sequenceAfterSource(idx2));
                            end
                        end


                        scenario.Accesses{idx}=ac(idx);
                    end



                    scenario.Links=cell(1,numel(lnk));
                    for idx=1:numel(lnk)

                        numNodesAfterSource=numel(lnk(idx).Sequence)-1;
                        sequenceAfterSource=lnk(idx).Sequence(2:end);
                        nodeTypeAfterSource=lnk(idx).NodeType(2:end);
                        lnk(idx).SequenceHandle=cell(1,numNodesAfterSource);
                        for idx2=1:numNodesAfterSource
                            nodeType=nodeTypeAfterSource(idx2);
                            switch nodeType
                            case 5
                                lnk(idx).SequenceHandle{idx2}=tx(tx.ID==sequenceAfterSource(idx2));
                            otherwise
                                lnk(idx).SequenceHandle{idx2}=rx(rx.ID==sequenceAfterSource(idx2));
                            end
                        end


                        scenario.Links{idx}=lnk(idx);
                    end
                end



                for graphic=scenario.ScenarioGraphics
                    graphic{1}.Scenario=scenario;
                end


                for viewer=s.Viewers
                    if(~isempty(viewer)&&~isempty(viewer.GlobeViewer))
                        show(s,'Viewer',viewer);
                    end
                end
            end
        end
    end

    methods(Access=protected)
        function propgrp=getPropertyGroups(scenario)
            if scenario.AutoSimulate
                proplist={'StartTime','StopTime','SampleTime',...
                'AutoSimulate','Satellites','GroundStations',...
                'Viewers','AutoShow'};
            else
                proplist={'StartTime','StopTime','SampleTime',...
                'SimulationTime','SimulationStatus','AutoSimulate',...
                'Satellites','GroundStations','Viewers','AutoShow'};
            end
            propgrp=matlab.mixin.util.PropertyGroup(proplist);
        end
    end

    methods(Access=private)
        reset(scenario)
    end

    methods
        sat=satellite(scenario,varargin)
        gs=groundStation(scenario,varargin)
        play(scenario,varargin)
        viewer=satelliteScenarioViewer(scenario,varargin)
        sat=walkerDelta(scenario,varargin)
        isRunning=advance(scenario)
        restart(scenario)
    end
end

function validateStartTime(startTime)


    coder.allowpcode('plain');

    validateattributes(startTime,{'datetime'},...
    {'nonempty','finite','scalar'},'satelliteScenario','STARTTIME');
end

function validateStopTime(stopTime)


    coder.allowpcode('plain');

    validateattributes(stopTime,{'datetime'},...
    {'nonempty','finite','scalar'},'satelliteScenario','STOPTIME');
end

function validateSampleTime(sampleTime)


    coder.allowpcode('plain');

    validateattributes(sampleTime,{'double'},...
    {'nonempty','finite','real','positive','scalar'},...
    'satelliteScenario','SampleTime');
end


