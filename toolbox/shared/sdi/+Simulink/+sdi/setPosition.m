function setPosition(pos)


















    try
        validateattributes(pos,"numeric",{'size',[1,4],'finite','real'});

        if~Simulink.sdi.Instance.isSDIRunning()
            error(message('SDI:sdi:SetPositionClosed'))
        end

        gui=Simulink.sdi.Instance.gui;
        if~isempty(gui.Dialog.CEFWindow)
            gui.Dialog.CEFWindow.Position=pos;
        end
    catch me
        me.throwAsCaller
    end
end
