function updateVisualizations(orb,viewer)





    scenario=orb.Scenario;







    orbitGraphicID=orb.getGraphicID;
    if(~viewer.graphicExists(orbitGraphicID))
        viewer.addGraphic(orbitGraphicID,true);
    end

    addGraphicToClutterMap(orb,viewer);

    isOrbitVisible=viewer.getGraphicVisibility(orbitGraphicID);
    if(~isOrbitVisible)
        return
    end



    orbitLineWidth=orb.LineWidth;
    orbitLineColor=orb.LineColor;




    sat=orb.Parent;

    if sat.OrbitPropagator~="ephemeris"


        elements=orbitalElements(sat);
        period=elements.Period;

        numSamples=round(period/scenario.SampleTime)+1;
    else

        period=seconds(scenario.StopTime-scenario.StartTime);
        numSamples=round(period/scenario.SampleTime)+1;
    end


    timeFuture=linspace(scenario.Simulator.Time,...
    scenario.Simulator.Time+seconds(period),numSamples);
    timeHistory=linspace(scenario.Simulator.Time-seconds(period),...
    scenario.Simulator.Time,numSamples);
    times=[timeHistory(1:end-1),timeFuture];
    indices=(times>=scenario.StartTime-seconds(1e-3))&(times<=scenario.StopTime+seconds(1e-3));
    time=times(indices);
    totalSamples=numel(time);

    if~isempty(time)


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


        itrf2gcrfTransform=matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(scenario.Simulator.Time);




        if sat.PropagatorType==2||sat.PropagatorType==3


            itrf=matlabshared.orbit.internal.Transforms.teme2itrf(...
            positions,repmat(scenario.Simulator.Time,1,totalSamples));
        elseif sat.PropagatorType==1||sat.PropagatorType==4


            itrf=itrf2gcrfTransform'*positions;
        else


            position=reshape(pagemtimes(matlabshared.orbit.internal.Transforms.itrf2gcrfTransform(time),...
            reshape(positions,3,1,[])),3,[]);



            itrf=itrf2gcrfTransform'*position;
        end


        geographicCoordinates=...
        matlabshared.orbit.internal.Transforms.itrf2geographic(itrf);


        locations=[geographicCoordinates(1,:)'*180/pi,...
        geographicCoordinates(2,:)'*180/pi,geographicCoordinates(3,:)'];


        switch sat.PropagatorType
        case 1

            step(sat.PropagatorTBK,scenario.Simulator.Time);
        case 2

            step(sat.PropagatorSGP4,scenario.Simulator.Time);
        case 3

            step(sat.PropagatorSDP4,scenario.Simulator.Time);
        case 4

            step(sat.PropagatorEphemeris,scenario.Simulator.Time);
        otherwise

            step(sat.PropagatorGPS,scenario.Simulator.Time);
        end



        lineCollection(viewer.GlobeViewer,{locations},...
        'Width',orbitLineWidth,...
        'Color',orbitLineColor,...
        'Animation','none',...
        'Indices',{{1}},...
        'Dashed',false,...
        'ID',orbitGraphicID);
    else

        remove(viewer.GlobeViewer,orbitGraphicID);
    end


