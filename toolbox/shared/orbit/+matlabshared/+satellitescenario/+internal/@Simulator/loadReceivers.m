function loadReceivers(simObj,s)




    coder.allowpcode('plain');


    rxStruct=matlabshared.satellitescenario.internal.Simulator.receiverStruct;


    rx=s.Receivers;



    simObj.Receivers=repmat(rxStruct,1,numel(rx));


    for idx=1:simObj.NumReceivers
        simObj.Receivers(idx).ID=rx(idx).ID;
        simObj.Receivers(idx).Position=rx(idx).Position;
        simObj.Receivers(idx).PositionHistory=rx(idx).PositionHistory;
        simObj.Receivers(idx).PositionITRF=rx(idx).PositionITRF;
        simObj.Receivers(idx).PositionITRFHistory=rx(idx).PositionITRFHistory;
        if isfield(rx,'Velocity')

            simObj.Receivers(idx).Velocity=rx(idx).Velocity;
        end
        if isfield(rx,'VelocityHistory')

            simObj.Receivers(idx).VelocityHistory=rx(idx).VelocityHistory;
        end
        if isfield(rx,'VelocityITRF')

            simObj.Receivers(idx).VelocityITRF=rx(idx).VelocityITRF;
        end
        if isfield(rx,'VelocityITRFHistory')

            simObj.Receivers(idx).VelocityITRFHistory=rx(idx).VelocityITRFHistory;
        end
        simObj.Receivers(idx).Latitude=rx(idx).Latitude;
        simObj.Receivers(idx).Longitude=rx(idx).Longitude;
        simObj.Receivers(idx).Altitude=rx(idx).Altitude;
        simObj.Receivers(idx).Attitude=rx(idx).Attitude;
        if isfield(rx,'LatitudeHistory')

            simObj.Receivers(idx).LatitudeHistory=rx(idx).LatitudeHistory;
        end
        if isfield(rx,'LongitudeHistory')

            simObj.Receivers(idx).LongitudeHistory=rx(idx).LongitudeHistory;
        end
        if isfield(rx,'AltitudeHistory')

            simObj.Receivers(idx).AltitudeHistory=rx(idx).AltitudeHistory;
        end
        simObj.Receivers(idx).AttitudeHistory=rx(idx).AttitudeHistory;
        simObj.Receivers(idx).Itrf2BodyTransform=rx(idx).Itrf2BodyTransform;
        simObj.Receivers(idx).Itrf2BodyTransformHistory=rx(idx).Itrf2BodyTransformHistory;
        simObj.Receivers(idx).MountingLocation=rx(idx).MountingLocation;
        simObj.Receivers(idx).MountingAngles=rx(idx).MountingAngles;
        simObj.Receivers(idx).GainToNoiseTemperatureRatio=rx(idx).GainToNoiseTemperatureRatio;
        simObj.Receivers(idx).RequiredEbNo=rx(idx).RequiredEbNo;
        simObj.Receivers(idx).SystemLoss=rx(idx).SystemLoss;
        if isfield(rx(idx),'PreReceiverLoss')

            simObj.Receivers(idx).PreReceiverLoss=rx(idx).PreReceiverLoss;
        end
        simObj.Receivers(idx).Antenna=rx(idx).Antenna;
        if isfield(rx(idx),'AntennaType')

            simObj.Receivers(idx).AntennaType=rx(idx).AntennaType;
        else
            antenna=rx(idx).Antenna;
            if isa(antenna,'satcom.satellitescenario.GaussianAntenna')
                simObj.Receivers(idx).AntennaType=0;
            elseif isa(antenna,'em.Antenna')||isa(antenna,'em.Array')||...
                isa(antenna,'installedAntenna')||isa(antenna,'customAntennaStl')||...
                isa(antenna,'phased.internal.AbstractAntennaElement')||...
                isa(antenna,'phased.internal.AbstractSubArray')||...
                isa(antenna,'arrayConfig')
                simObj.Receivers(idx).AntennaType=1;
            else
                simObj.Receivers(idx).AntennaType=2;
            end
        end
        if isfield(rx(idx),'PhasedArrayWeightsDefault')

            simObj.Receivers(idx).PhasedArrayWeightsDefault=rx(idx).PhasedArrayWeightsDefault;
        elseif simObj.Receivers(idx).AntennaType==2
            simObj.Receivers(idx).PhasedArrayWeightsDefault=simObj.Receivers(idx).Antenna.Taper;
        end
        if isfield(rx(idx),'PhasedArrayWeights')

            simObj.Receivers(idx).PhasedArrayWeights=rx(idx).PhasedArrayWeights;
        end
        if isfield(rx(idx),'PointingMode')

            simObj.Receivers(idx).PointingMode=rx(idx).PointingMode;
        end
        if isfield(rx(idx),'PointingTargetID')

            simObj.Receivers(idx).PointingTargetID=rx(idx).PointingTargetID;
        end
        if isfield(rx(idx),'PointingCoordinates')

            simObj.Receivers(idx).PointingCoordinates=rx(idx).PointingCoordinates;
        end
        if isfield(rx(idx),'PointingDirection')

            simObj.Receivers(idx).PointingDirection=rx(idx).PointingDirection;
        end
        if isfield(rx(idx),'PointingDirectionHistory')

            simObj.Receivers(idx).PointingDirectionHistory=rx(idx).PointingDirectionHistory;
        end
        if isfield(rx(idx),'AntennaPattern')

            simObj.Receivers(idx).AntennaPattern=rx(idx).AntennaPattern;
        end
        if isfield(rx(idx),'AntennaPatternResolution')

            simObj.Receivers(idx).AntennaPatternResolution=rx(idx).AntennaPatternResolution;
        end
        if isfield(rx(idx),'AntennaPatternFrequency')

            simObj.Receivers(idx).AntennaPatternFrequency=rx(idx).AntennaPatternFrequency;
        end
        if isfield(rx,'DishDiameter')

            simObj.Receivers(idx).DishDiameter=rx(idx).DishDiameter;
        end
        if isfield(rx,'ApertureEfficiency')

            simObj.Receivers(idx).ApertureEfficiency=rx(idx).ApertureEfficiency;
        end
        simObj.Receivers(idx).ParentSimulatorID=rx(idx).ParentSimulatorID;
        simObj.Receivers(idx).Type=rx(idx).Type;
        simObj.Receivers(idx).ParentType=rx(idx).ParentType;
        simObj.Receivers(idx).GrandParentSimulatorID=rx(idx).GrandParentSimulatorID;
        simObj.Receivers(idx).GrandParentType=rx(idx).GrandParentType;
    end
end

