function out=isTestOrSDIRunning()
    out=Simulink.sdi.Instance.isSDIRunning();
    if~out
        gui=Simulink.sdi.Instance.getSetTestGUI();
        out=~isempty(gui)&&isRunning(gui);
    end
end
