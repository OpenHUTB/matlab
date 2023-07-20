classdef GPS<matlabshared.orbit.internal.OrbitPropagationModel %#codegen





    properties(SetAccess=private)
GPSWeekNumber
GPSTimeOfApplicability
AlmanacData
        GNSSSystem=uint8(0)
    end

    methods(Hidden,Static)
        function p=loadobj(p)


            if isstruct(p.AlmanacData)
                if isfield(p.AlmanacData,'PRNNumber')
                    gnssRecords.PRNNumber=p.AlmanacData.PRNNumber;
                else
                    gnssRecords.PRNNumber=1;
                end

                if isfield(p.AlmanacData,'SVN')
                    gnssRecords.SVN=p.AlmanacData.SVN;
                else
                    gnssRecords.SVN=63;
                end

                if isfield(p.AlmanacData,'AverageURANumber')
                    gnssRecords.AverageURANumber=p.AlmanacData.AverageURANumber;
                else
                    gnssRecords.AverageURANumber=0;
                end

                if isfield(p.AlmanacData,'Eccentricity')
                    gnssRecords.Eccentricity=p.AlmanacData.Eccentricity;
                else
                    gnssRecords.Eccentricity=0.0094;
                end

                if isfield(p.AlmanacData,'InclinationOffset')
                    gnssRecords.InclinationOffset=p.AlmanacData.InclinationOffset;
                else
                    gnssRecords.InclinationOffset=0.0362;
                end

                if isfield(p.AlmanacData,'RateOfInclination')
                    gnssRecords.RateOfInclination=p.AlmanacData.RateOfInclination;
                else
                    gnssRecords.RateOfInclination=0;
                end

                if isfield(p.AlmanacData,'InclinationSineHarmonicCorrectionAmplitude')
                    gnssRecords.InclinationSineHarmonicCorrectionAmplitude=p.AlmanacData.InclinationSineHarmonicCorrectionAmplitude;
                else
                    gnssRecords.InclinationSineHarmonicCorrectionAmplitude=0;
                end

                if isfield(p.AlmanacData,'InclinationCosineHarmonicCorrectionAmplitude')
                    gnssRecords.InclinationCosineHarmonicCorrectionAmplitude=p.AlmanacData.InclinationCosineHarmonicCorrectionAmplitude;
                else
                    gnssRecords.InclinationCosineHarmonicCorrectionAmplitude=0;
                end

                if isfield(p.AlmanacData,'OrbitRadiusSineHarmonicCorrectionAmplitude')
                    gnssRecords.OrbitRadiusSineHarmonicCorrectionAmplitude=p.AlmanacData.OrbitRadiusSineHarmonicCorrectionAmplitude;
                else
                    gnssRecords.OrbitRadiusSineHarmonicCorrectionAmplitude=0;
                end

                if isfield(p.AlmanacData,'OrbitRadiusCosineHarmonicCorrectionAmplitude')
                    gnssRecords.OrbitRadiusCosineHarmonicCorrectionAmplitude=p.AlmanacData.OrbitRadiusCosineHarmonicCorrectionAmplitude;
                else
                    gnssRecords.OrbitRadiusCosineHarmonicCorrectionAmplitude=0;
                end

                if isfield(p.AlmanacData,'ArgumentOfLatitudeSineHarmonicCorrectionAmplitude')
                    gnssRecords.ArgumentOfLatitudeSineHarmonicCorrectionAmplitude=p.AlmanacData.ArgumentOfLatitudeSineHarmonicCorrectionAmplitude;
                else
                    gnssRecords.ArgumentOfLatitudeSineHarmonicCorrectionAmplitude=0;
                end

                if isfield(p.AlmanacData,'ArgumentOfLatitudeCosineHarmonicCorrectionAmplitude')
                    gnssRecords.ArgumentOfLatitudeCosineHarmonicCorrectionAmplitude=p.AlmanacData.ArgumentOfLatitudeCosineHarmonicCorrectionAmplitude;
                else
                    gnssRecords.ArgumentOfLatitudeCosineHarmonicCorrectionAmplitude=0;
                end

                if isfield(p.AlmanacData,'RateOfRightAscension')
                    gnssRecords.RateOfRightAscension=p.AlmanacData.RateOfRightAscension;
                else
                    gnssRecords.RateOfRightAscension=-8.1261e-09;
                end

                if isfield(p.AlmanacData,'RateOfRightAscensionDifference')
                    gnssRecords.RateOfRightAscensionDifference=p.AlmanacData.RateOfRightAscensionDifference;
                else
                    gnssRecords.RateOfRightAscensionDifference=0;
                end

                if isfield(p.AlmanacData,'SqrtOfSemiMajorAxis')
                    gnssRecords.SqrtOfSemiMajorAxis=p.AlmanacData.SqrtOfSemiMajorAxis;
                else
                    gnssRecords.SqrtOfSemiMajorAxis=5.1536e+03;
                end

                if isfield(p.AlmanacData,'SemiMajorAxisDifference')
                    gnssRecords.SemiMajorAxisDifference=p.AlmanacData.SemiMajorAxisDifference;
                else
                    gnssRecords.SemiMajorAxisDifference=0;
                end

                if isfield(p.AlmanacData,'RateOfSemiMajorAxis')
                    gnssRecords.RateOfSemiMajorAxis=p.AlmanacData.RateOfSemiMajorAxis;
                else
                    gnssRecords.RateOfSemiMajorAxis=0;
                end

                if isfield(p.AlmanacData,'MeanMotionDifference')
                    gnssRecords.MeanMotionDifference=p.AlmanacData.MeanMotionDifference;
                else
                    gnssRecords.MeanMotionDifference=0;
                end

                if isfield(p.AlmanacData,'RateOfMeanMotionDifference')
                    gnssRecords.RateOfMeanMotionDifference=p.AlmanacData.RateOfMeanMotionDifference;
                else
                    gnssRecords.RateOfMeanMotionDifference=0;
                end

                if isfield(p.AlmanacData,'GeographicLongitudeOfOrbitalPlane')
                    gnssRecords.GeographicLongitudeOfOrbitalPlane=p.AlmanacData.GeographicLongitudeOfOrbitalPlane;
                else
                    gnssRecords.GeographicLongitudeOfOrbitalPlane=-1.4576;
                end

                if isfield(p.AlmanacData,'ArgumentOfPerigee')
                    gnssRecords.ArgumentOfPerigee=p.AlmanacData.ArgumentOfPerigee;
                else
                    gnssRecords.ArgumentOfPerigee=0.7555;
                end

                if isfield(p.AlmanacData,'MeanAnomaly')
                    gnssRecords.MeanAnomaly=p.AlmanacData.MeanAnomaly;
                else
                    gnssRecords.MeanAnomaly=-1.7346;
                end

                if isfield(p.AlmanacData,'ZerothOrderClockCorrection')
                    gnssRecords.ZerothOrderClockCorrection=p.AlmanacData.ZerothOrderClockCorrection;
                else
                    gnssRecords.ZerothOrderClockCorrection=-3.0231e-04;
                end

                if isfield(p.AlmanacData,'FirstOrderClockCorrection')
                    gnssRecords.FirstOrderClockCorrection=p.AlmanacData.FirstOrderClockCorrection;
                else
                    gnssRecords.FirstOrderClockCorrection=-1.0914e-11;
                end

                if isfield(p.AlmanacData,'SatelliteHealth')
                    gnssRecords.SatelliteHealth=p.AlmanacData.SatelliteHealth;
                else
                    gnssRecords.SatelliteHealth=0;
                end

                if isfield(p.AlmanacData,'SatelliteConfiguration')
                    gnssRecords.SatelliteConfiguration=p.AlmanacData.SatelliteConfiguration;
                else
                    gnssRecords.SatelliteConfiguration=11;
                end

                p.AlmanacData=gnssRecords;
            end
        end
    end

    methods
        function propagator=GPS(weekNum,toa,gnssSystem,data,initialTime)


            coder.allowpcode('plain');


            propagator.GPSWeekNumber=weekNum;
            propagator.GPSTimeOfApplicability=toa;
            propagator.AlmanacData=data;
            propagator.InitialTime=initialTime;
            propagator.GNSSSystem=gnssSystem;


            initialize(propagator);
        end

        function infoStruct=info(propagator)

































            coder.allowpcode('plain');

            infoStruct.GNSSSystem=propagator.GNSSSystem;
            infoStruct.PRNNumber=propagator.AlmanacData.PRNNumber;
            infoStruct.SVN=propagator.AlmanacData.SVN;
            infoStruct.AverageURANumber=propagator.AlmanacData.AverageURANumber;
            infoStruct.Eccentricity=propagator.AlmanacData.Eccentricity;
            infoStruct.InclinationOffset=propagator.AlmanacData.InclinationOffset;
            infoStruct.RateOfInclination=propagator.AlmanacData.RateOfInclination;
            infoStruct.RateOfRightAscension=propagator.AlmanacData.RateOfRightAscension;
            infoStruct.RateOfRightAscensionDifference=propagator.AlmanacData.RateOfRightAscensionDifference;
            infoStruct.SqrtOfSemiMajorAxis=propagator.AlmanacData.SqrtOfSemiMajorAxis;
            infoStruct.SemiMajorAxisDifference=propagator.AlmanacData.SemiMajorAxisDifference;
            infoStruct.RateOfSemiMajorAxis=propagator.AlmanacData.RateOfSemiMajorAxis;
            infoStruct.MeanMotionDifference=propagator.AlmanacData.MeanMotionDifference;
            infoStruct.RateOfMeanMotionDifference=propagator.AlmanacData.RateOfMeanMotionDifference;
            infoStruct.GeographicLongitudeOfOrbitalPlane=propagator.AlmanacData.GeographicLongitudeOfOrbitalPlane;
            infoStruct.ArgumentOfPerigee=propagator.AlmanacData.ArgumentOfPerigee;
            infoStruct.MeanAnomaly=propagator.AlmanacData.MeanAnomaly;
            infoStruct.InclinationSineHarmonicCorrectionAmplitude=propagator.AlmanacData.InclinationSineHarmonicCorrectionAmplitude;
            infoStruct.InclinationCosineHarmonicCorrectionAmplitude=propagator.AlmanacData.InclinationCosineHarmonicCorrectionAmplitude;
            infoStruct.OrbitRadiusSineHarmonicCorrectionAmplitude=propagator.AlmanacData.OrbitRadiusSineHarmonicCorrectionAmplitude;
            infoStruct.OrbitRadiusCosineHarmonicCorrectionAmplitude=propagator.AlmanacData.OrbitRadiusCosineHarmonicCorrectionAmplitude;
            infoStruct.ArgumentOfLatitudeSineHarmonicCorrectionAmplitude=propagator.AlmanacData.ArgumentOfLatitudeSineHarmonicCorrectionAmplitude;
            infoStruct.ArgumentOfLatitudeCosineHarmonicCorrectionAmplitude=propagator.AlmanacData.ArgumentOfLatitudeCosineHarmonicCorrectionAmplitude;
            infoStruct.ZerothOrderClockCorrection=propagator.AlmanacData.ZerothOrderClockCorrection;
            infoStruct.FirstOrderClockCorrection=propagator.AlmanacData.FirstOrderClockCorrection;
            infoStruct.SatelliteHealth=propagator.AlmanacData.SatelliteHealth;
            infoStruct.SatelliteConfiguration=propagator.AlmanacData.SatelliteConfiguration;
            infoStruct.Period=...
            2*pi*(propagator.AlmanacData.SqrtOfSemiMajorAxis^3)/...
            sqrt(matlabshared.orbit.internal.OrbitPropagationModel.StandardGravitationalParameter);
        end
    end

    methods(Access=protected)
        function initialize(propagator)


            coder.allowpcode('plain');

            step(propagator,propagator.InitialTime);
            propagator.InitialPosition=propagator.Position;
            propagator.InitialVelocity=propagator.Velocity;
        end

        function[position,velocity]=stepImpl(propagator,time)


            coder.allowpcode('plain');

            weekNum=propagator.GPSWeekNumber;
            toa=propagator.GPSTimeOfApplicability;
            data=propagator.AlmanacData;

            [position,velocity]=...
            matlabshared.orbit.internal.GPS.propagate(weekNum,toa,data,time);
        end
    end

    methods(Static)
        [position,velocity]=propagate(weekNum,toa,data,time);
    end
end

