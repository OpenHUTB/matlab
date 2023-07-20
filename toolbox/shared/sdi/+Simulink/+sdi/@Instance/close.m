function close(filename)

    if Simulink.sdi.Instance.isSDIRunning()
        gui=Simulink.sdi.Instance.gui;
        if nargin>0
            Simulink.sdi.save(filename);
        end
        gui.Close;
    end
    Simulink.sdi.Instance.getSetGUI([]);
    Simulink.sdi.Instance.getSetGUIOpenningFlag(false);
end
