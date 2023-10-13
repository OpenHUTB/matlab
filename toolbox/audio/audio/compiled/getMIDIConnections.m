function param=getMIDIConnections(obj)

    narginchk(1,1);

    import matlab.internal.lang.capability.Capability;
    Capability.require(Capability.LocalClient);


    if~audioutil()
        errID='audio:audioutil:licenseNotFound';
        error(errID,getString(message(errID,'getMIDIConnections')));
    end

    MIDIInterface.checkObjectValidity(obj);
    param=privConfigureMIDI('getConnections',obj);
