function deleteSignal(~,signalID)

    if numel(signalID)>1||Simulink.sdi.isValidSignalID(signalID)
        Simulink.sdi.Instance.engine.deleteSignal(signalID);
    else
        error(message('SDI:sdi:InvalidSignalID'));
    end
end
