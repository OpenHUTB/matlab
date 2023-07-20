function VdynblksReplacements(obj)




    if isR2022aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('sim3dgroundtruthsensorlib/Simulation 3D Ray Tracer'));
        obj.removeLibraryLinksTo(sprintf('sim3dautolib/Simulation 3D Physics Vehicle'));
        obj.removeLibraryLinksTo(sprintf('vehdynlibsteering/Steering System'));
    end

    if isR2021bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('vehdynlibsuspension/Kinematics and Compliance Suspension'));
        obj.removeLibraryLinksTo(sprintf('sim3dgroundtruthsensorlib/Simulation 3D Terrain Sensor'));
    end

    if isR2021aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('vdynlib/Wheels and Tires/Combined Slip Wheel CPI'));
        obj.removeLibraryLinksTo(sprintf('vehdynlibtire/Combined Slip Wheel STI'));
        obj.removeLibraryLinksTo(sprintf('vdynlib/Wheels and Tires/Combined Slip Wheel STI'));
        obj.removeLibraryLinksTo(sprintf('autolibsharedmappedengines/Simple Engine'));
        obj.removeLibraryLinksTo(sprintf('autolibshared/Motorcycle Body Longitudinal In-Plane'));
        obj.removeLibraryLinksTo(sprintf('autolibshared/Motorcycle Chain'));
        obj.removeLibraryLinksTo(sprintf('sim3dautolib/Simulation 3D Motorcycle'));
        obj.removeLibraryLinksTo(sprintf('sim3dautolib/Simulation 3D Dolly'));
        obj.removeLibraryLinksTo('autolibshareddiff/Transfer Case');
    end

    if isR2020aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('sim3dautolib/Simulation 3D Tractor'));
        obj.removeLibraryLinksTo(sprintf('sim3dautolib/Simulation 3D Trailer'));
        obj.removeLibraryLinksTo(sprintf('vehdynlibviscommon/Vehicle XY Plot Configuration'));
        obj.removeLibraryLinksTo(sprintf('vehdynlibviscommon/Internal Vehicle XY Plotter'));
    end

    if isR2019bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('vehdynlibeom/Vehicle Body 3DOF Three Axles'));
        obj.removeLibraryLinksTo(sprintf('vehdynlibeom/Trailer Body 3DOF'));
        obj.removeLibraryLinksTo(sprintf('vehdynlibsens/Three-axis InertialMeasurement Unit'));
    end

    if isR2019aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('vdynlib/Vehicle Scenarios/Sim3D/Sim3D Vehicle/Components/Simulation 3D Vehicle with Ground Following'));
        obj.removeLibraryLinksTo(sprintf('sim3dautolib/Simulation 3D Vehicle'));
        obj.removeLibraryLinksTo(sprintf('sim3dlib/Simulation 3D Message Set'));
        obj.removeLibraryLinksTo(sprintf('sim3dlib/Simulation 3D Message Get'));
    end

    if isR2018bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('vehdynlibtire/Fiala Wheel 2DOF');
        obj.removeLibraryLinksTo('vdynlib/Wheels and Tires/Fiala Wheel 2DOF');
    end

    if isR2018aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('vdynlib/Powertrain/Drivetrain/Final Drive Unit/Active Differential');
        obj.removeLibraryLinksTo('autolibshareddiff/Active Differential');
    end

    if isR2017bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('vehdynlibsuspension/Independent Suspension - MacPherson');
        obj.removeLibraryLinksTo('vehdynlibsuspension/Independent Suspension - Double Wishbone');
        obj.removeLibraryLinksTo('vehdynlibsuspension/Independent Suspension - Mapped');
        obj.removeLibraryLinksTo('vehdynlibsuspension/Solid Axle Suspension');
        obj.removeLibraryLinksTo('vehdynlibsuspension/Solid Axle Suspension - Coil Spring');
        obj.removeLibraryLinksTo('vehdynlibsuspension/Solid Axle Suspension - Mapped');
        obj.removeLibraryLinksTo('vehdynlibsuspension/Solid Axle Suspension - Leaf Spring');
        obj.removeLibraryLinksTo('vehdynlibtire/Combined Slip Wheel 2DOF');
        obj.removeLibraryLinksTo('vehdynlibsteering/Kinematic Steering');
        obj.removeLibraryLinksTo('vehdynlibsteering/Dynamic Steering');
        obj.removeLibraryLinksTo('vehdynlibsteering/Mapped Steering');
        obj.removeLibraryLinksTo('autolibshared/Vehicle Body 3DOF Longitudinal');
        obj.removeLibraryLinksTo('autolibshared/Vehicle Body 3DOF Single Track');
        obj.removeLibraryLinksTo('autolibshared/Vehicle Body 3DOF Dual Track');
        obj.removeLibraryLinksTo('vehdynlibeom/Vehicle Body 6DOF');
        obj.removeLibraryLinksTo('vehdynlibdriver/Lateral Driver');
        obj.removeLibraryLinksTo('vehdynlibdriver/Predictive Driver');
        obj.removeLibraryLinksTo('sim3dlib/Simulation 3D Scene Configuration');
        obj.removeLibraryLinksTo('sim3dlib/View Control');
        obj.removeLibraryLinksTo('sim3dlib/Simulation 3D Actor Transform Get');
        obj.removeLibraryLinksTo('sim3dlib/Simulation 3D Actor Transform Set');
        obj.removeLibraryLinksTo('sim3dlib/Simulation 3D Actor Ray Trace Get');
        obj.removeLibraryLinksTo('sim3dlib/Simulation 3D Actor Ray Trace Set');
        obj.removeLibraryLinksTo('sim3dlib/Simulation 3D Camera Get');
        obj.removeLibraryLinksTo('sim3dlib/Vehicle Terrain Sensor');
    end

