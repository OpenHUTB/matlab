function out=isSDIRunning()


    gui=Simulink.sdi.Instance.gui('isGUIUp');
    out=~isempty(gui)&&isRunning(gui);
end
