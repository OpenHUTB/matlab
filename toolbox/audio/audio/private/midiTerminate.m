function terminated=midiTerminate



%#codegen
    coder.allowpcode('plain');

    if isempty(coder.target)

        terminated=midimexif('midiTerminate');
    else

        terminated=coder.nullcopy(false);
        terminated=coder.ceval('terminateIfNoDevicesCpp');
    end
end
