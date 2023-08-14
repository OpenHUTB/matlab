function AutoBlksReplacements(obj)




    if isR2021aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo(sprintf('autolibsharedmappedengines/Simple Engine'));
        obj.removeLibraryLinksTo(sprintf('autolibshared/Motorcycle Body Longitudinal In-Plane'));
        obj.removeLibraryLinksTo(sprintf('autolibshared/Motorcycle Chain'));
        obj.removeLibraryLinksTo('autolibshareddiff/Transfer Case');
    end

    if isR2018bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('autolibpowerinfoutils/Power Accounting Bus Creator');
        obj.removeLibraryLinksTo('autolib/Utilities/Power Accounting');
        obj.removeLibraryLinksTo('autolibinverter/Three-Phase Voltage Source Inverter');
        obj.removeLibraryLinksTo('autolibemachines/Three-Phase Voltage Source Inverter');
    end

    if isR2018aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('autolibshareddiff/Active Differential');
    end

    if isR2017aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('autolibdcdc/Bidirectional DC-DC');
        obj.removeLibraryLinksTo('autolibfluxpmsm/Flux-Based PMSM');
        obj.removeLibraryLinksTo('autolibmotorctrlr/Flux-Based PM Controller');
        obj.removeLibraryLinksTo('autolibsharedcoupling/Split Torsional Compliance');
    end

    if isR2016bOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('autolibcoupling/Planetary Gear');
        obj.removeLibraryLinksTo('autolibcoupling/Gearbox');
        obj.removeLibraryLinksTo('autolibcoupling/Disc Clutch');
    end

    if isR2016aOrEarlier(obj.ver)
        obj.removeLibraryLinksTo('autolibfundflwcommon/Air Mass Fractions');
        obj.removeLibraryLinksTo('autolibrcnetworksystem/Estimation Equivalent Circuit Battery');
        obj.removeLibraryLinksTo('autolibrcnetworksystem/Equivalent Circuit Battery');
        obj.removeLibraryLinksTo('autolibdatasheetbattery/Datasheet Battery');
        obj.removeLibraryLinksTo('autolibstarter/Starter');
        obj.removeLibraryLinksTo('autolibalternator/Reduced Lundell Alternator');
        obj.removeLibraryLinksTo('autolibshareddiff/Open Differential');
        obj.removeLibraryLinksTo('autolibshareddiff/Limited Slip Differential');
        obj.removeLibraryLinksTo('autolibshared/Longitudinal Wheel');
        obj.removeLibraryLinksTo('autolibwheelslong/Longitudinal Wheel - Disk Brake');
        obj.removeLibraryLinksTo('autolibwheelslong/Longitudinal Wheel - Drum Brake');
        obj.removeLibraryLinksTo('autolibwheelslong/Longitudinal Wheel - Mapped Brake');
        obj.removeLibraryLinksTo('autolibsharedcoupling/Torsional Compliance');
        obj.removeLibraryLinksTo('autolibsharedcoupling/Rotational Inertia');
        obj.removeLibraryLinksTo('autolibenginesystems/Mapped SI Engine');
        obj.removeLibraryLinksTo('autolibenginesystems/Mapped CI Engine');
        obj.removeLibraryLinksTo(sprintf('autolibenginesystems/TEMPLATE HELP\nDynamic SI Engine'));
        obj.removeLibraryLinksTo(sprintf('autolibenginesystems/TEMPLATE HELP\nDynamic CI Engine'));
        obj.removeLibraryLinksTo('autolibfundflw/Flow Restriction');
        obj.removeLibraryLinksTo('autolibfundflw/Heat Exchanger');
        obj.removeLibraryLinksTo('autolibfundflw/Control Volume System');
        obj.removeLibraryLinksTo('autolibfundflw/Flow Boundary');
        obj.removeLibraryLinksTo('autolibboost/Turbine');
        obj.removeLibraryLinksTo('autolibboost/Boost Drive Shaft');
        obj.removeLibraryLinksTo('autolibboost/Compressor');
        obj.removeLibraryLinksTo('autolibcoreeng/SI Core Engine');
        obj.removeLibraryLinksTo('autolibcoreeng/CI Core Engine');
        obj.removeLibraryLinksTo('autolibsharedcoreengin/Mapped Core Engine');
        obj.removeLibraryLinksTo('autolibengctrlr/SI Controller');
        obj.removeLibraryLinksTo('autolibengctrlr/CI Controller');
        obj.removeLibraryLinksTo(sprintf('autolibpmsminterior/Interior PMSM\n'));
        obj.removeLibraryLinksTo('autolibpmsmexterior/Surface Mount PMSM');
        obj.removeLibraryLinksTo('autolibim/Induction Motor');
        obj.removeLibraryLinksTo('autolibmappedmotor/Mapped Motor');
        obj.removeLibraryLinksTo('autolibmotorctrlr/Interior PM Controller');
        obj.removeLibraryLinksTo('autolibmotorctrlr/Surface Mount PM Controller');
        obj.removeLibraryLinksTo('autolibmotorctrlr/IM Controller');
        obj.removeLibraryLinksTo('autolibsharedtransfixedgear/Ideal Fixed Gear Transmission');
        obj.removeLibraryLinksTo('autolibtransamt/Automated Manual Transmission');
        obj.removeLibraryLinksTo('autolibtranscvt/Continuously Variable Transmission');
        obj.removeLibraryLinksTo('autolibtransdct/Dual Clutch Transmission');
        obj.removeLibraryLinksTo('autolibtranscontrols/CVT Controller');
        obj.removeLibraryLinksTo('autolibtranscontrols/DCT Controller');
        obj.removeLibraryLinksTo('autolibtranscontrols/AMT Controller');
        obj.removeLibraryLinksTo('autolibtrqconv/Torque Converter');
        obj.removeLibraryLinksTo('autolibshared/Vehicle Body Total Road Load');
        obj.removeLibraryLinksTo('autolibshared/Vehicle Body 1DOF Longitudinal');
        obj.removeLibraryLinksTo('autolibshared/Vehicle Body 3DOF Longitudinal');
        obj.removeLibraryLinksTo('autolibshared/Drive Cycle Source');
        obj.removeLibraryLinksTo('autolibshared/Longitudinal Driver');
    end

