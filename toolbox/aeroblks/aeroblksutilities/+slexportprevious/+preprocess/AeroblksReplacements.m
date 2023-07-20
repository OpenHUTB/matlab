function AeroblksReplacements(obj)




    if isR2021aOrEarlier(obj.ver)
        obj.removeBlocksOfType('SpacecraftDynamics');
    end

    if isR2020bOrEarlier(obj.ver)
        obj.removeBlocksOfType('RefPointMass');
    end

    if isR2020aOrEarlier(obj.ver)
        obj.removeBlocksOfType('OrbitPropagator');
        obj.removeLibraryLinksTo(sprintf('aerolibsatdyn/Attitude Profile\n(Nadir Pointing)'));
        obj.removeLibraryLinksTo(sprintf('aerolibcubesatveh/CubeSat Vehicle (Nadir Pointing)'));
    end

    if isR2018aOrEarlier(obj.ver)
        obj.removeBlocksOfType('EOParameters');
    end

    if isR2017aOrEarlier(obj.ver)
        obj.removeBlocksOfType('DeltaUT1');
    end

    if isR2016bOrEarlier(obj.ver)
        obj.removeBlocksOfType('Angle2Rod');
        obj.removeBlocksOfType('Dcm2Rod');
        obj.removeBlocksOfType('Quat2Rod');
        obj.removeBlocksOfType('Rod2Angle');
        obj.removeBlocksOfType('Rod2Dcm');
        obj.removeBlocksOfType('Rod2Quat');
    end

    if isR2016aOrEarlier(obj.ver)
        obj.removeBlocksOfType('WindHWM14');
    end

    if isR2015bOrEarlier(obj.ver)
        obj.removeBlocksOfType('QuatInterp');
    end

    if isR2015aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibgravity2/International Geomagnetic Reference Field 12');
    end

    if isR2014bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibtransform2/ECI Position to AER');
        obj.removeLibraryLinksTo('aerolibobsolete/World Magnetic Model 2015');
    end

    if isR2014aOrEarlier(obj.ver)
        obj.removeBlocksOfType('WindHWM07');
    end

    if isR2013bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibtransform2/ECI Position to LLA');
        obj.removeLibraryLinksTo('aerolibtransform2/LLA to ECI Position');
        obj.removeLibraryLinksTo('aerolib6dof2/Simple Variable Mass 6DOF (Euler Angles)');
        obj.removeLibraryLinksTo('aerolib6dof2/Custom Variable Mass 6DOF (Euler Angles)');
        obj.removeLibraryLinksTo('aerolib6dof2/6DOF (Quaternion)');
        obj.removeLibraryLinksTo('aerolib6dof2/Simple Variable Mass 6DOF (Quaternion)');
        obj.removeLibraryLinksTo('aerolib6dof2/Custom Variable Mass 6DOF (Quaternion)');
        obj.removeLibraryLinksTo('aerolib6dof2/6DOF Wind (Wind Angles)');
        obj.removeLibraryLinksTo('aerolib6dof2/Simple Variable Mass 6DOF Wind (Wind Angles)');
        obj.removeLibraryLinksTo('aerolib6dof2/Custom Variable Mass 6DOF Wind (Wind Angles)');
        obj.removeLibraryLinksTo('aerolib6dof2/6DOF Wind (Quaternion)');
        obj.removeLibraryLinksTo('aerolib6dof2/Simple Variable Mass 6DOF Wind (Quaternion)');
        obj.removeLibraryLinksTo('aerolib6dof2/Custom Variable Mass 6DOF Wind (Quaternion)');
        obj.removeLibraryLinksTo('aerolib6dof2/6DOF ECEF (Quaternion)');
        obj.removeLibraryLinksTo(sprintf('aerolib6dof2/Simple Variable Mass 6DOF\nECEF (Quaternion)'));
        obj.removeLibraryLinksTo(sprintf('aerolib6dof2/Custom Variable Mass 6DOF\nECEF (Quaternion)'));
        obj.removeLibraryLinksTo('aerolib3dof2/3DOF (Wind Axes)');
        obj.removeLibraryLinksTo(sprintf('aerolib3dof2/Simple Variable Mass 3DOF \n(Body Axes)'));
        obj.removeLibraryLinksTo(sprintf('aerolib3dof2/Custom Variable Mass 3DOF \n(Body Axes)'));
        obj.removeLibraryLinksTo(sprintf('aerolib3dof2/Custom Variable Mass 3DOF\n(Wind Axes)'));
        obj.removeLibraryLinksTo(sprintf('aerolib3dof2/Simple Variable Mass 3DOF\n(Wind Axes)'));
    end

    if isR2013aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibconvert2/Julian Date Conversion');
        obj.removeLibraryLinksTo(sprintf('aerolibtransform2/Direction Cosine Matrix\nECI to ECEF'));
    end

    if isR2012bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibcelestial/Planetary Ephemeris');
        obj.removeLibraryLinksTo('aerolibcelestial/Earth Nutation');
        obj.removeLibraryLinksTo('aerolibcelestial/Moon Libration');
    end

    if isR2012aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibpilot/Tustin Pilot Model');
        obj.removeLibraryLinksTo('aerolibpilot/Crossover Pilot Model');
        obj.removeLibraryLinksTo('aerolibpilot/Precision Pilot Model');
    end

    if isR2011bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibactuator/Nonlinear Second-Order Actuator');
        obj.removeLibraryLinksTo('aerolibactuator/Linear Second-Order Actuator');
        obj.removeLibraryLinksTo(sprintf('aerolibfltsims/Receive net_ctrl\nPacket from FlightGear'));
        obj.removeLibraryLinksTo(sprintf('aerolibfltsims/Unpack\nnet_ctrl Packet\nfrom FlightGear'));
    end

    if isR2010bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibtransform2/LLA to Flat Earth');
        obj.removeLibraryLinksTo('aerolibobsolete/International Geomagnetic Reference Field 11');
    end

    if isR2010aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibgravity2/Geoid Height');
    end

    if isR2009bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibgravity2/Centrifugal Effect Model');
        obj.removeLibraryLinksTo('aerolibgravity2/Spherical Harmonic Gravity Model');
        obj.removeLibraryLinksTo('aerolibobsolete/World Magnetic Model 2010');
    end

    if isR2009aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibgravity2/Zonal Harmonic Gravity Model');
    end

    if isR2007aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('aerolibobsolete/EGM96 Geoid');
        obj.removeLibraryLinksTo('aerolibatmos2/CIRA-86 Atmosphere Model');
        obj.removeLibraryLinksTo(sprintf('aerolibatmos2/NRLMSISE-00\nAtmosphere Model'));
    end

    if isR2006bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('aerolibanim/MATLAB\nAnimation'));
        obj.removeLibraryLinksTo('aerolibobsolete/WGS84 Gravity Model ');
    end

    if isR2006aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('aerolibadyn/Digital DATCOM\nForces and Moments'));
        obj.removeLibraryLinksTo(sprintf('aerolibadyn/Aerodynamic\nForces and Moments '));
        obj.removeLibraryLinksTo(sprintf('aerolibschedule/Interpolate\nMatrix(x,y,z) '));
    end
