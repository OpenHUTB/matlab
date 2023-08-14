function signal=getSignal(this,sigID)




    if this.isValidSignalID(sigID)
        signal=Simulink.sdi.Signal(this.Repo,sigID);
    else
        error(message('SDI:sdi:InvalidSignalID'));
    end
end
