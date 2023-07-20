function close(blockId)

    gui=Simulink.playback.GUI.getSetGUI(blockId);
    if~isempty(gui)
        gui.close;
        Simulink.playback.GUI.getSetGUI(blockId,[]);
    end
end
