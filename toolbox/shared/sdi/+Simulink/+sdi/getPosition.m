function pos=getPosition()


















    pos=[0,0,0,0];
    if Simulink.sdi.Instance.isSDIRunning()
        gui=Simulink.sdi.Instance.gui;
        if~isempty(gui.Dialog.CEFWindow)
            pos=gui.Dialog.CEFWindow.Position;
        end
    end
end
