function loadTransmitters(simObj,s)




    coder.allowpcode('plain');


    txStruct=matlabshared.satellitescenario.internal.Simulator.transmitterStruct;


    tx=s.Transmitters;



    simObj.Transmitters=repmat(txStruct,1,numel(tx));


    for idx=1:simObj.NumTransmitters
        simObj.Transmitters(idx).ID=tx(idx).ID;
        simObj.Transmitters(idx).Position=tx(idx).Position;
        simObj.Transmitters(idx).PositionHistory=tx(idx).PositionHistory;
        simObj.Transmitters(idx).PositionITRF=tx(idx).PositionITRF;
        simObj.Transmitters(idx).PositionITRFHistory=tx(idx).PositionITRFHistory;
        if isfield(tx,'Velocity')

            simObj.Transmitters(idx).Velocity=tx(idx).Velocity;
        end
        if isfield(tx,'VelocityHistory')

            simObj.Transmitters(idx).VelocityHistory=tx(idx).VelocityHistory;
        end
        if isfield(tx,'VelocityITRF')

            simObj.Transmitters(idx).VelocityITRF=tx(idx).VelocityITRF;
        end
        if isfield(tx,'VelocityITRFHistory')

            simObj.Transmitters(idx).VelocityITRFHistory=tx(idx).VelocityITRFHistory;
        end
        simObj.Transmitters(idx).Latitude=tx(idx).Latitude;
        simObj.Transmitters(idx).Longitude=tx(idx).Longitude;
        simObj.Transmitters(idx).Altitude=tx(idx).Altitude;
        simObj.Transmitters(idx).Attitude=tx(idx).Attitude;
        if isfield(tx,'LatitudeHistory')

            simObj.Transmitters(idx).LatitudeHistory=tx(idx).LatitudeHistory;
        end
        if isfield(tx,'LongitudeHistory')

            simObj.Transmitters(idx).LongitudeHistory=tx(idx).LongitudeHistory;
        end
        if isfield(tx,'AltitudeHistory')

            simObj.Transmitters(idx).AltitudeHistory=tx(idx).AltitudeHistory;
        end
        simObj.Transmitters(idx).AttitudeHistory=tx(idx).AttitudeHistory;
        simObj.Transmitters(idx).Itrf2BodyTransform=tx(idx).Itrf2BodyTransform;
        simObj.Transmitters(idx).Itrf2BodyTransformHistory=tx(idx).Itrf2BodyTransformHistory;
        simObj.Transmitters(idx).MountingLocation=tx(idx).MountingLocation;
        simObj.Transmitters(idx).MountingAngles=tx(idx).MountingAngles;
        simObj.Transmitters(idx).Frequency=tx(idx).Frequency;
        simObj.Transmitters(idx).BitRate=tx(idx).BitRate;
        simObj.Transmitters(idx).Power=tx(idx).Power;
        simObj.Transmitters(idx).SystemLoss=tx(idx).SystemLoss;
        simObj.Transmitters(idx).Antenna=tx(idx).Antenna;
        if isfield(tx(idx),'AntennaType')

            simObj.Transmitters(idx).AntennaType=tx(idx).AntennaType;
        else
            antenna=tx(idx).Antenna;
            if isa(antenna,'satcom.satellitescenario.GaussianAntenna')
                simObj.Transmitters(idx).AntennaType=0;
            elseif isa(antenna,'em.Antenna')||isa(antenna,'em.Array')||...
                isa(antenna,'installedAntenna')||isa(antenna,'customAntennaStl')||...
                isa(antenna,'phased.internal.AbstractAntennaElement')||...
                isa(antenna,'phased.internal.AbstractSubArray')||...
                isa(antenna,'arrayConfig')
                simObj.Transmitters(idx).AntennaType=1;
            else
                simObj.Transmitters(idx).AntennaType=2;
            end
        end
        if isfield(tx(idx),'PhasedArrayWeightsDefault')

            simObj.Transmitters(idx).PhasedArrayWeightsDefault=tx(idx).PhasedArrayWeightsDefault;
        elseif simObj.Transmitters(idx).AntennaType==2
            simObj.Transmitters(idx).PhasedArrayWeightsDefault=simObj.Transmitters(idx).Antenna.Taper;
        end
        if isfield(tx(idx),'PhasedArrayWeights')

            simObj.Transmitters(idx).PhasedArrayWeights=tx(idx).PhasedArrayWeights;
        end
        if isfield(tx(idx),'PointingMode')

            simObj.Transmitters(idx).PointingMode=tx(idx).PointingMode;
        end
        if isfield(tx(idx),'PointingTargetID')

            simObj.Transmitters(idx).PointingTargetID=tx(idx).PointingTargetID;
        end
        if isfield(tx(idx),'PointingCoordinates')

            simObj.Transmitters(idx).PointingCoordinates=tx(idx).PointingCoordinates;
        end
        if isfield(tx(idx),'PointingDirection')

            simObj.Transmitters(idx).PointingDirection=tx(idx).PointingDirection;
        end
        if isfield(tx(idx),'PointingDirectionHistory')

            simObj.Transmitters(idx).PointingDirectionHistory=tx(idx).PointingDirectionHistory;
        end
        if isfield(tx(idx),'AntennaPattern')

            simObj.Transmitters(idx).AntennaPattern=tx(idx).AntennaPattern;
        end
        if isfield(tx(idx),'AntennaPatternResolution')

            simObj.Transmitters(idx).AntennaPatternResolution=tx(idx).AntennaPatternResolution;
        end
        if isfield(tx(idx),'AntennaPatternFrequency')

            simObj.Transmitters(idx).AntennaPatternFrequency=tx(idx).AntennaPatternFrequency;
        end
        if isfield(tx,'DishDiameter')

            simObj.Transmitters(idx).DishDiameter=tx(idx).DishDiameter;
        end
        if isfield(tx,'ApertureEfficiency')

            simObj.Transmitters(idx).ApertureEfficiency=tx(idx).ApertureEfficiency;
        end
        simObj.Transmitters(idx).ParentSimulatorID=tx(idx).ParentSimulatorID;
        simObj.Transmitters(idx).Type=tx(idx).Type;
        simObj.Transmitters(idx).ParentType=tx(idx).ParentType;
        simObj.Transmitters(idx).GrandParentSimulatorID=tx(idx).GrandParentSimulatorID;
        simObj.Transmitters(idx).GrandParentType=tx(idx).GrandParentType;
    end
end

