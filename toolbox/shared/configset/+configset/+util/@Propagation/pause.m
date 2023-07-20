function pause(h)

    if h.Mode==1||h.Mode==2
        h.Mode=h.Mode+2;
    end

    if h.GUI
        h.Dialog.setEnabled('pauseButton',false);
    end
