function[position,velocity]=propagate(weekNum,toa,data,time)%#codegen






    coder.allowpcode('plain');

    coder.extrinsic('matlabshared.internal.gnss.GPSTime.getGPSTime');

    if~isempty(coder.target)&&~coder.target('MEX')

        position=nan(3,numel(time));
        velocity=nan(3,numel(time));
        return
    end


    gpsWeek=zeros(1,numel(time));%#ok<PREALL> 
    tow=zeros(1,numel(time));%#ok<PREALL> 
    [gpsWeek,tow]=matlabshared.internal.gnss.GPSTime.getGPSTime(time);


    inclination=deg2rad(54);
    mu=3.986005e+14;
    OmegaEDot=7.2921151467e-05;


    sqrtA=vertcat(data.SqrtOfSemiMajorAxis);
    ARef=sqrtA.^2;
    deltaA=vertcat(data.SemiMajorAxisDifference);
    ADot=vertcat(data.RateOfSemiMajorAxis);
    deltan0=vertcat(data.MeanMotionDifference)*pi;
    deltan0Dot=vertcat(data.RateOfMeanMotionDifference)*pi;
    e0=vertcat(data.Eccentricity);
    omega0=vertcat(data.ArgumentOfPerigee)*pi;
    M0=vertcat(data.MeanAnomaly)*pi;
    inclinationOffset=vertcat(data.InclinationOffset)*pi;
    i0=inclination+inclinationOffset;
    iDot=vertcat(data.RateOfInclination)*pi;
    Cis=vertcat(data.InclinationSineHarmonicCorrectionAmplitude)*pi;
    Cic=vertcat(data.InclinationCosineHarmonicCorrectionAmplitude)*pi;
    Crs=vertcat(data.OrbitRadiusSineHarmonicCorrectionAmplitude);
    Crc=vertcat(data.OrbitRadiusCosineHarmonicCorrectionAmplitude);
    Cus=vertcat(data.ArgumentOfLatitudeSineHarmonicCorrectionAmplitude)*pi;
    Cuc=vertcat(data.ArgumentOfLatitudeCosineHarmonicCorrectionAmplitude)*pi;
    OmegaRefDot=vertcat(data.RateOfRightAscension)*pi;
    Omega0=vertcat(data.GeographicLongitudeOfOrbitalPlane)*pi;
    deltaOmegaDot=vertcat(data.RateOfRightAscensionDifference)*pi;


    [satPos,satVel]=matlabshared.internal.gnss.orbitParametersToECEF(...
    gpsWeek,tow,weekNum,toa,...
    ARef,deltaA,ADot,...
    mu,deltan0,deltan0Dot,...
    M0,e0,omega0,...
    i0,iDot,...
    Cis,Cic,Crs,Crc,Cus,Cuc,...
    OmegaEDot,OmegaRefDot,Omega0,deltaOmegaDot);

    numSamples=numel(time);
    position=reshape(satPos,numSamples,3)';
    velocity=reshape(satVel,numSamples,3)';
end
