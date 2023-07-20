function disconnectMIDI(arg)















    narginchk(1,1);


    import matlab.internal.lang.capability.Capability;
    Capability.require(Capability.LocalClient);


    if~audioutil()
        errID='audio:audioutil:licenseNotFound';
        error(errID,getString(message(errID,'disconnectMIDI')));
    end

    MIDIInterface.checkObjectValidity(arg);
    privConfigureMIDI('disconnect',arg);

end
