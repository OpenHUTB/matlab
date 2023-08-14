function updateVisualizations(gt,viewer)








    gtGraphicID=gt.getGraphicID;
    if(~viewer.graphicExists(gtGraphicID))
        viewer.addGraphic(gtGraphicID,true);
    end

    addGraphicToClutterMap(gt,viewer)

    isGtVisible=viewer.getGraphicVisibility(gtGraphicID);
    if(~isGtVisible)
        return
    end


    simulator=gt.Scenario.Simulator;
    scenario=gt.Scenario;
    originalTime=simulator.Time;



    sat=gt.Parent;


    leadTime=gt.LeadTime;
    trailTime=gt.TrailTime;
    lineWidth=gt.LineWidth;
    leadLineColor=gt.LeadLineColor;
    trailLineColor=gt.TrailLineColor;




    numLeadSamples=round(leadTime/gt.Scenario.SampleTime);


    times=linspace(simulator.Time,simulator.Time+...
    seconds(leadTime),numLeadSamples);
    indices=(times>=scenario.StartTime-seconds(1e-3))&(times<=scenario.StopTime+seconds(1e-3));
    time=times(indices);

    if leadTime>0&&~isempty(time)

        totalSamples=numel(time);


        switch sat.PropagatorType
        case 1

            positions=step(sat.PropagatorTBK,time);
        case 2

            positions=step(sat.PropagatorSGP4,time);
        case 3

            positions=step(sat.PropagatorSDP4,time);
        case 4

            positions=step(sat.PropagatorEphemeris,time);
        otherwise

            positions=step(sat.PropagatorGPS,time);
        end




        itrf2gcrfTransform=...
        matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(time);


        if sat.PropagatorType==1||sat.PropagatorType==4


            positionITRFCalc=pagemtimes(itrf2gcrfTransform,'transpose',reshape(positions,3,1,[]),'none');
            positionITRF=reshape(positionITRFCalc,3,[]);
        elseif sat.PropagatorType==2||sat.PropagatorType==3


            positionITRF=matlabshared.orbit.internal.Transforms.teme2itrf(...
            positions,time);
        else

            positionITRF=positions;
        end


        geographicCoordinates=...
        matlabshared.orbit.internal.Transforms.itrf2geographic(positionITRF);


        leadGroundTrack=...
        [geographicCoordinates(1,:)*180/pi;...
        geographicCoordinates(2,:)*180/pi;...
        zeros(1,totalSamples)];


        switch sat.PropagatorType
        case 1

            step(sat.PropagatorTBK,originalTime);
        case 2

            step(sat.PropagatorSGP4,originalTime);
        case 3

            step(sat.PropagatorSDP4,originalTime);
        case 4

            step(sat.PropagatorEphemeris,originalTime);
        otherwise

            step(sat.PropagatorGPS,originalTime);
        end


        lineCollection(viewer.GlobeViewer,...
        {leadGroundTrack'},...
        'Width',lineWidth,...
        'Color',leadLineColor,...
        'Animation','none',...
        'Indices',{{1}},...
        'Dashed',true,...
        'ID',gtGraphicID);
    else

        remove(viewer.GlobeViewer,gtGraphicID);
    end


    gtTrailID=getChildGraphicsIDs(gt);


    numTrailSamples=round(trailTime/gt.Scenario.SampleTime);


    times=linspace(simulator.Time-seconds(trailTime),...
    simulator.Time,numTrailSamples);
    indices=(times>=scenario.StartTime-seconds(1e-3))&(times<=scenario.StopTime+seconds(1e-3));
    time=times(indices);


    if trailTime>0&&~isempty(time)

        totalSamples=numel(time);


        switch sat.PropagatorType
        case 1

            positions=step(sat.PropagatorTBK,time);
        case 2

            positions=step(sat.PropagatorSGP4,time);
        case 3

            positions=step(sat.PropagatorSDP4,time);
        case 4

            positions=step(sat.PropagatorEphemeris,time);
        otherwise

            positions=step(sat.PropagatorGPS,time);
        end




        itrf2gcrfTransform=...
        matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(time);


        if sat.PropagatorType==1||sat.PropagatorType==4


            positionITRFCalc=pagemtimes(itrf2gcrfTransform,'transpose',reshape(positions,3,1,[]),'none');
            positionITRF=reshape(positionITRFCalc,3,[]);
        elseif sat.PropagatorType==2||sat.PropagatorType==3


            positionITRF=matlabshared.orbit.internal.Transforms.teme2itrf(...
            positions,time);
        else

            positionITRF=positions;
        end


        geographicCoordinates=...
        matlabshared.orbit.internal.Transforms.itrf2geographic(positionITRF);


        trailGroundTrack=...
        [geographicCoordinates(1,:)*180/pi;...
        geographicCoordinates(2,:)*180/pi;...
        zeros(1,totalSamples)];


        switch sat.PropagatorType
        case 1

            step(sat.PropagatorTBK,originalTime);
        case 2

            step(sat.PropagatorSGP4,originalTime);
        case 3

            step(sat.PropagatorSDP4,originalTime);
        case 4

            step(sat.PropagatorEphemeris,originalTime);
        otherwise

            step(sat.PropagatorGPS,originalTime);
        end


        lineCollection(viewer.GlobeViewer,...
        {trailGroundTrack'},...
        'Width',lineWidth,...
        'Color',trailLineColor,...
        'Animation','none',...
        'Indices',{{1}},...
        'Dashed',false,...
        'ID',gtTrailID);
    else

        remove(viewer.GlobeViewer,gtTrailID);
    end
end