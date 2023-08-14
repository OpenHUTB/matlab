function elements=orbitalElements(sat)%#codegen





























































































    switch sat.PropagatorType
    case 1
        propagator=sat.PropagatorTBK;
    case 2
        propagator=sat.PropagatorSGP4;
    case 3
        propagator=sat.PropagatorSDP4;
    case 4
        propagator=sat.PropagatorEphemeris;
    otherwise
        propagator=sat.PropagatorGPS;
    end


    orbitPropProperties=info(propagator);


    switch sat.OrbitPropagator
    case "two-body-keplerian"
        elements.SemiMajorAxis=orbitPropProperties.SemiMajorAxis;
        elements.Eccentricity=orbitPropProperties.Eccentricity;
        elements.Inclination=orbitPropProperties.Inclination*180/pi;
        elements.RightAscensionOfAscendingNode=...
        orbitPropProperties.RightAscensionOfAscendingNode*180/pi;
        elements.ArgumentOfPeriapsis=...
        orbitPropProperties.ArgumentOfPeriapsis*180/pi;
        elements.TrueAnomaly=...
        mod(orbitPropProperties.TrueAnomaly,2*pi)*180/pi;
        standardGravitationalParameter=...
        matlabshared.orbit.internal.OrbitPropagationModel.StandardGravitationalParameter;
        elements.Period=2*pi*sqrt((elements.SemiMajorAxis^3)/...
        standardGravitationalParameter);
    case{"sgp4","sdp4"}
        elements.MeanMotion=orbitPropProperties.MeanMotion*180/pi;
        elements.Eccentricity=orbitPropProperties.Eccentricity;
        elements.Inclination=orbitPropProperties.Inclination*180/pi;
        elements.RightAscensionOfAscendingNode=...
        orbitPropProperties.RightAscensionOfAscendingNode*180/pi;
        elements.ArgumentOfPeriapsis=orbitPropProperties.ArgumentOfPeriapsis*180/pi;
        elements.MeanAnomaly=orbitPropProperties.MeanAnomaly*180/pi;
        elements.Period=orbitPropProperties.Period;
        elements.Epoch=orbitPropProperties.Epoch;
        elements.BStar=orbitPropProperties.BStar;
    case "ephemeris"
        elements.EphemerisStartTime=orbitPropProperties.StartTime;
        elements.EphemerisStopTime=orbitPropProperties.StopTime;
        elements.PositionTimeTable=orbitPropProperties.PositionTimeTable;
        elements.VelocityTimeTable=orbitPropProperties.VelocityTimeTable;
    case{"gps","galileo"}
        gnssSystem=orbitPropProperties.GNSSSystem;
        if gnssSystem==uint8(0)
            elements.PRN=orbitPropProperties.PRNNumber;
            elements.GPSWeekNumber=sat.PropagatorGPS.GPSWeekNumber;
            elements.GPSTimeOfApplicability=sat.PropagatorGPS.GPSTimeOfApplicability;
        else
            elements.SatelliteID=orbitPropProperties.PRNNumber;
            elements.GALWeekNumber=sat.PropagatorGPS.GPSWeekNumber;
            elements.TimeOfEphemeris=sat.PropagatorGPS.GPSTimeOfApplicability;
        end

        elements.SatelliteHealth=orbitPropProperties.SatelliteHealth;
        elements.SemiMajorAxis=orbitPropProperties.SqrtOfSemiMajorAxis^2;
        elements.Eccentricity=orbitPropProperties.Eccentricity;
        elements.Inclination=(orbitPropProperties.InclinationOffset*180)+54;
        elements.GeographicLongitudeOfOrbitalPlane=orbitPropProperties.GeographicLongitudeOfOrbitalPlane*180;
        elements.RateOfRightAscension=orbitPropProperties.RateOfRightAscension*180;
        elements.ArgumentOfPerigee=orbitPropProperties.ArgumentOfPerigee*180;
        elements.MeanAnomaly=orbitPropProperties.MeanAnomaly*180;
        elements.Period=orbitPropProperties.Period;
    end
end


